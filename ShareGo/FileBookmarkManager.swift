import Foundation
import AppKit

class FileBookmarkManager: ObservableObject {
    @Published var fileURLs: [URL] = []
    private let bookmarksKey = "fileBookmarks"
    private var bookmarkDataList: [Data] = []
    
    init() {
        loadBookmarks()
    }
    
    func addFile(url: URL) {
        do {
            let bookmark = try url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
            bookmarkDataList.append(bookmark)
            saveBookmarks()
            resolveBookmarks()
        } catch {
            print("[FileBookmarkManager] Failed to create bookmark: \(error)")
        }
    }
    
    func removeFile(at index: Int) {
        guard bookmarkDataList.indices.contains(index) else { return }
        bookmarkDataList.remove(at: index)
        saveBookmarks()
        resolveBookmarks()
    }
    
    private func saveBookmarks() {
        UserDefaults.standard.set(bookmarkDataList, forKey: bookmarksKey)
    }
    
    private func loadBookmarks() {
        if let saved = UserDefaults.standard.array(forKey: bookmarksKey) as? [Data] {
            bookmarkDataList = saved
            resolveBookmarks()
        }
    }
    
    private func resolveBookmarks() {
        fileURLs.removeAll()
        for data in bookmarkDataList {
            var isStale = false
            if let url = try? URL(resolvingBookmarkData: data, options: [.withSecurityScope], relativeTo: nil, bookmarkDataIsStale: &isStale) {
                if url.startAccessingSecurityScopedResource() {
                    fileURLs.append(url)
                }
            }
        }
    }
} 