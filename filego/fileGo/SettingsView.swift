import SwiftUI
import KeyboardShortcuts
import AppKit

struct SettingsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Button(action: {
                showHotKeyPopover()
            }) {
                HStack {
                    Text("Change Hotkey (")
                    Text(HotKeyManager.shared.currentHotKeyDescription())
                        .font(.system(.body, design: .monospaced))
                    Text(")")
                }
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 20)
            Spacer()
        }
        .frame(width: 320, height: 120)
    }
}

func showHotKeyPopover() {
    let popover = NSPopover()
    popover.contentSize = NSSize(width: 260, height: 140)
    popover.behavior = .transient
    popover.contentViewController = HotKeyPopoverViewController()
    if let keyWindow = NSApp.keyWindow, let contentView = keyWindow.contentView {
        popover.show(relativeTo: contentView.bounds, of: contentView, preferredEdge: .maxY)
    } else if let mainWindow = NSApp.mainWindow, let contentView = mainWindow.contentView {
        popover.show(relativeTo: contentView.bounds, of: contentView, preferredEdge: .maxY)
    } else if let window = NSApp.windows.first, let contentView = window.contentView {
        popover.show(relativeTo: contentView.bounds, of: contentView, preferredEdge: .maxY)
    }
} 