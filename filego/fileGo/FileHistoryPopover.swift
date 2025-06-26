import SwiftUI
import AppKit

struct FileHistoryPopover: View {
    @ObservedObject var bookmarkManager: FileBookmarkManager
    var body: some View {
        VStack(spacing: 0) {
            FinderStyleFileList(urls: bookmarkManager.fileURLs, bookmarkManager: bookmarkManager) { index in
                bookmarkManager.removeFile(at: index)
            }
            .frame(maxWidth: .infinity, minHeight: 420, maxHeight: 420)
        }
        .background(.ultraThinMaterial)
        .cornerRadius(25)
    }
}

struct FinderStyleFileList: NSViewRepresentable {
    let urls: [URL]
    let bookmarkManager: FileBookmarkManager
    let onRemove: (Int) -> Void

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        let collectionView = context.coordinator.collectionView
        scrollView.documentView = collectionView
        return scrollView
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        context.coordinator.update(urls: urls)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(urls: urls, bookmarkManager: bookmarkManager, onRemove: onRemove)
    }

    class Coordinator: NSObject, NSCollectionViewDataSource, NSCollectionViewDelegate {
        let collectionView: NSCollectionView
        var urls: [URL]
        let bookmarkManager: FileBookmarkManager
        let onRemove: (Int) -> Void

        init(urls: [URL], bookmarkManager: FileBookmarkManager, onRemove: @escaping (Int) -> Void) {
            self.urls = urls
            self.bookmarkManager = bookmarkManager
            self.onRemove = onRemove
            let layout = NSCollectionViewFlowLayout()
            layout.itemSize = NSSize(width: 100, height: 110)
            layout.minimumLineSpacing = 16
            layout.minimumInteritemSpacing = 8
            layout.sectionInset = NSEdgeInsets(top: 16, left: 24, bottom: 16, right: 24)
            layout.scrollDirection = .vertical
            collectionView = NSCollectionView()
            super.init()
            collectionView.collectionViewLayout = layout
            collectionView.register(FileItemCell.self, forItemWithIdentifier: .init("FileItemCell"))
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.backgroundColors = [.clear]
            collectionView.isSelectable = true
            collectionView.allowsMultipleSelection = true
            collectionView.registerForDraggedTypes([.fileURL])
            collectionView.setDraggingSourceOperationMask(.every, forLocal: false)
        }

        func update(urls: [URL]) {
            self.urls = urls
            collectionView.reloadData()
        }

        func numberOfSections(in collectionView: NSCollectionView) -> Int { 1 }
        func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
            urls.count
        }
        func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
            let item = collectionView.makeItem(withIdentifier: .init("FileItemCell"), for: indexPath) as! FileItemCell
            let url = urls[indexPath.item]
            item.setFile(url: url)
            item.onRemove = { [weak self] in self?.onRemove(indexPath.item) }
            return item
        }
        // Finder-style drag out
        func collectionView(_ collectionView: NSCollectionView, pasteboardWriterForItemAt indexPath: IndexPath) -> NSPasteboardWriting? {
            return urls[indexPath.item] as NSURL
        }
        // Finder-style drag in
        func collectionView(_ collectionView: NSCollectionView, acceptDrop info: NSDraggingInfo, indexPath: IndexPath, dropOperation: NSCollectionView.DropOperation) -> Bool {
            let pb = info.draggingPasteboard
            if let items = pb.readObjects(forClasses: [NSURL.self], options: nil) as? [URL] {
                for url in items {
                    bookmarkManager.addFile(url: url)
                }
                return true
            }
            return false
        }
        func collectionView(_ collectionView: NSCollectionView, validateDrop info: NSDraggingInfo, proposedIndexPath: AutoreleasingUnsafeMutablePointer<NSIndexPath>, dropOperation: UnsafeMutablePointer<NSCollectionView.DropOperation>) -> NSDragOperation {
            return .copy
        }
    }
}

class FileItemCell: NSCollectionViewItem {
    var onRemove: (() -> Void)?
    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    override func loadView() {
        self.view = NSView(frame: NSRect(x: 0, y: 0, width: 100, height: 110))
        view.wantsLayer = true
        view.layer?.cornerRadius = 8
        view.layer?.backgroundColor = NSColor.clear.cgColor
    }
    override var isSelected: Bool {
        didSet {
            view.layer?.backgroundColor = isSelected ? NSColor.selectedControlColor.withAlphaComponent(0.18).cgColor : NSColor.clear.cgColor
        }
    }
    func setFile(url: URL) {
        view.subviews.forEach { $0.removeFromSuperview() }
        let icon = NSImageView(image: NSWorkspace.shared.icon(forFile: url.path))
        icon.frame = NSRect(x: 20, y: 38, width: 60, height: 60)
        icon.imageScaling = .scaleProportionallyUpOrDown
        let label = NSTextField(labelWithString: url.lastPathComponent)
        label.frame = NSRect(x: 4, y: 8, width: 92, height: 24)
        label.font = .systemFont(ofSize: 11)
        label.alignment = .center
        label.lineBreakMode = .byTruncatingMiddle
        let removeBtn = NSButton(title: "✕", target: self, action: #selector(removeTapped))
        removeBtn.frame = NSRect(x: 76, y: 80, width: 16, height: 16)
        removeBtn.bezelStyle = .inline
        removeBtn.isBordered = false
        view.addSubview(icon)
        view.addSubview(label)
        view.addSubview(removeBtn)
    }
    @objc func removeTapped() {
        onRemove?()
    }
} 