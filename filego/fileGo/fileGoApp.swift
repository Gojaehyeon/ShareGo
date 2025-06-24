//
//  fileGoApp.swift
//  fileGo
//
//  Created by Gojaehyun on 6/24/25.
//

import SwiftUI
import AppKit
import HotKey
import ServiceManagement

@main
struct FileGoApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        Settings {}
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    let bookmarkManager = FileBookmarkManager()
    var statusItem: NSStatusItem?
    var popoverPanel: NSPanel?
    var escKeyMonitor: Any?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "folder.fill", accessibilityDescription: "FileGo")
            button.action = #selector(showPopover)
            button.target = self
        }
        HotKeyManager.shared.registerDefaultHotKey(target: self, action: #selector(showPopover))
    }

    @objc func showPopover() {
        if let panel = popoverPanel, panel.isVisible {
            panel.close()
            popoverPanel = nil
            if let monitor = escKeyMonitor {
                NSEvent.removeMonitor(monitor)
                escKeyMonitor = nil
            }
            return
        }
        let contentView = FileHistoryPopover(bookmarkManager: bookmarkManager)
        let hosting = NSHostingController(rootView: contentView)
        let panel = NSPanel(contentViewController: hosting)
        hosting.view.registerForDraggedTypes([.fileURL])
        panel.styleMask = [.titled, .nonactivatingPanel, .fullSizeContentView]
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        panel.hasShadow = true
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.standardWindowButton(.closeButton)?.isHidden = true
        panel.standardWindowButton(.miniaturizeButton)?.isHidden = true
        panel.standardWindowButton(.zoomButton)?.isHidden = true
        NotificationCenter.default.addObserver(forName: NSWindow.didResignKeyNotification, object: panel, queue: .main) { [weak self] _ in
            self?.popoverPanel?.close()
            self?.popoverPanel = nil
            if let monitor = self?.escKeyMonitor {
                NSEvent.removeMonitor(monitor)
                self?.escKeyMonitor = nil
            }
        }
        let mouseLocation = NSEvent.mouseLocation
        if let screen = NSScreen.screens.first(where: { NSMouseInRect(mouseLocation, $0.frame, false) }) {
            let width = screen.frame.width
            let height: CGFloat = 420
            let x: CGFloat = screen.frame.minX
            let y: CGFloat = screen.frame.minY
            let size = NSSize(width: width, height: height)
            let origin = NSPoint(x: x, y: y)
            panel.setFrame(NSRect(origin: origin, size: size), display: true)
            hosting.view.frame = NSRect(origin: .zero, size: size)
            hosting.view.autoresizingMask = [.width, .height]
        }
        NSApp.activate(ignoringOtherApps: true)
        panel.makeKeyAndOrderFront(nil)
        popoverPanel = panel
        escKeyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.keyCode == 53 { // ESC
                self?.popoverPanel?.close()
                self?.popoverPanel = nil
                if let monitor = self?.escKeyMonitor {
                    NSEvent.removeMonitor(monitor)
                    self?.escKeyMonitor = nil
                }
                return nil
            }
            return event
        }
    }
}
