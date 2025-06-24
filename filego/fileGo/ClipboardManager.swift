import Foundation
import AppKit

enum ClipboardItemType: Equatable {
    case text(String)
    case image(NSImage, name: String?)

    static func == (lhs: ClipboardItemType, rhs: ClipboardItemType) -> Bool {
        switch (lhs, rhs) {
        case let (.text(a), .text(b)):
            return a == b
        case let (.image(a, _), .image(b, _)):
            // 이미지 데이터가 같으면 true (간단히 tiffRepresentation 비교)
            return a.tiffRepresentation == b.tiffRepresentation
        default:
            return false
        }
    }
}

struct ClipboardItem: Identifiable, Equatable {
    let id: UUID
    let type: ClipboardItemType
    var isFavorite: Bool
    var name: String? {
        switch type {
        case .image(_, let name): return name
        default: return nil
        }
    }
    
    init(type: ClipboardItemType, isFavorite: Bool = false) {
        self.id = UUID()
        self.type = type
        self.isFavorite = isFavorite
    }
    
    static func == (lhs: ClipboardItem, rhs: ClipboardItem) -> Bool {
        lhs.id == rhs.id && lhs.type == rhs.type && lhs.isFavorite == rhs.isFavorite
    }
}

class ClipboardManager: ObservableObject {
    @Published var history: [ClipboardItem] = []
    private var timer: Timer?
    private let pasteboard = NSPasteboard.general
    private var lastChangeCount: Int
    private let maxHistory = 100
    var movePastedToTop: Bool = false

    init() {
        lastChangeCount = pasteboard.changeCount
        startMonitoring()
    }

    private func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.checkPasteboard()
        }
    }

    private func checkPasteboard() {
        if pasteboard.changeCount != lastChangeCount {
            lastChangeCount = pasteboard.changeCount
            var newItem: ClipboardItem? = nil
            if let newString = pasteboard.string(forType: .string), !newString.isEmpty {
                newItem = ClipboardItem(type: .text(newString))
            } else if let imageData = pasteboard.data(forType: .tiff), let image = NSImage(data: imageData) {
                newItem = ClipboardItem(type: .image(image, name: nil))
            }
            if let item = newItem {
                if let existIdx = history.firstIndex(where: { $0.type == item.type }) {
                    if movePastedToTop {
                        let exist = history.remove(at: existIdx)
                        history.insert(exist, at: 0)
                    } else {
                        // 기존 항목이면 순서 유지(아무것도 안함)
                    }
                } else {
                    history.insert(item, at: 0)
                    history = Array(history.prefix(maxHistory))
                }
            }
        }
    }

    func copyToPasteboard(_ item: ClipboardItem, paste: Bool = false) {
        pasteboard.clearContents()
        switch item.type {
        case .text(let string):
            pasteboard.setString(string, forType: .string)
        case .image(let image, let name):
            if let tiff = image.tiffRepresentation {
                pasteboard.setData(tiff, forType: .tiff)
            }
        }
        if paste {
            simulatePaste()
        }
    }

    private func simulatePaste() {
        let src = CGEventSource(stateID: .combinedSessionState)
        let cmdVDown = CGEvent(keyboardEventSource: src, virtualKey: 0x09, keyDown: true) // 'v'
        let cmdVUp = CGEvent(keyboardEventSource: src, virtualKey: 0x09, keyDown: false)
        cmdVDown?.flags = .maskCommand
        cmdVDown?.post(tap: .cghidEventTap)
        cmdVUp?.flags = .maskCommand
        cmdVUp?.post(tap: .cghidEventTap)
    }

    func addImageToClipboard(_ image: NSImage, name: String? = nil) {
        pasteboard.clearContents()
        pasteboard.writeObjects([image])
        let item = ClipboardItem(type: .image(image, name: name))
        if let existIdx = history.firstIndex(where: { $0.type == item.type }) {
            history.remove(at: existIdx)
        }
        history.insert(item, at: 0)
        history = Array(history.prefix(maxHistory))
    }
} 