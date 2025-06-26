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
    var statusItem: NSStatusItem?
    var popoverPanel: NSPanel?
    var escKeyMonitor: Any?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "square.and.arrow.up", accessibilityDescription: "Share")
            button.action = #selector(statusBarButtonClicked)
            button.target = self
        }
        statusItem?.menu = makeMenu()
        HotKeyManager.shared.registerDefaultHotKey(target: self, action: #selector(showPopover))
    }

    @objc func statusBarButtonClicked() {
        statusItem?.menu = makeMenu()
        statusItem?.button?.performClick(nil)
    }

    func makeMenu() -> NSMenu {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "About Airgo", action: #selector(showAbout), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Open Airgo", action: #selector(showPopover), keyEquivalent: ""))
        let currentHotkey = HotKeyManager.shared.currentHotKeyDescription()
        menu.addItem(NSMenuItem(title: "Change Hotkey (\(currentHotkey))", action: #selector(changeHotkey), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q"))
        return menu
    }

    @objc func showAbout() {
        let aboutView = AboutView()
        let hosting = NSHostingController(rootView: aboutView)
        let panel = NSPanel(contentViewController: hosting)
        panel.styleMask = [.titled, .closable]
        panel.title = "About Airgo"
        panel.setFrame(NSRect(x: 0, y: 0, width: 400, height: 460), display: true)
        panel.center()
        panel.isReleasedWhenClosed = false
        panel.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc func changeHotkey() {
        let vc = HotKeyPopoverViewController()
        let popover = NSPopover()
        popover.contentViewController = vc
        popover.behavior = .transient
        popover.contentSize = NSSize(width: 260, height: 140)
        if let button = statusItem?.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .maxY)
        }
    }

    @objc func quitApp() {
        NSApp.terminate(nil)
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
        let contentView = AirDropMiniPopover()
        let hosting = NSHostingController(rootView: contentView)
        let panel = NSPanel(contentViewController: hosting)
        hosting.view.registerForDraggedTypes([.fileURL])
        panel.styleMask = [.borderless, .nonactivatingPanel, .fullSizeContentView]
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        panel.hasShadow = false
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.standardWindowButton(.closeButton)?.isHidden = true
        panel.standardWindowButton(.miniaturizeButton)?.isHidden = true
        panel.standardWindowButton(.zoomButton)?.isHidden = true
        if let screen = NSScreen.main {
            let width: CGFloat = 300
            let height: CGFloat = 300
            let x: CGFloat = screen.frame.midX - width/2
            let y: CGFloat = screen.frame.midY - height/2
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
