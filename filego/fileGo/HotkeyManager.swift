import Foundation
import KeyboardShortcuts
import HotKey
import AppKit

extension KeyboardShortcuts.Name {
    static let showClipboard = Self("showClipboard")
}

final class HotKeyManager {
    static let shared = HotKeyManager()
    static let hotKeyChangedNotification = Notification.Name("HotKeyManagerHotKeyChanged")

    private var hotKey: HotKey?
    private(set) var keyCombo: KeyCombo? = nil

    func registerDefaultHotKey(target: AnyObject, action: Selector) {
        let combo = KeyCombo(key: .f, modifiers: [.option])
        keyCombo = combo
        hotKey = HotKey(keyCombo: combo)
        hotKey?.keyDownHandler = { [weak target] in
            _ = target?.perform(action)
        }
    }
    
    func updateHotKey(key: Key, modifiers: NSEvent.ModifierFlags, target: AnyObject, action: Selector) {
        let combo = KeyCombo(key: key, modifiers: modifiers)
        keyCombo = combo
        hotKey = HotKey(keyCombo: combo)
        hotKey?.keyDownHandler = { [weak target] in
            _ = target?.perform(action)
        }
        NotificationCenter.default.post(name: HotKeyManager.hotKeyChangedNotification, object: nil)
    }
    
    func currentHotKeyDescription() -> String {
        guard let combo = keyCombo else { return "⌘ + ⇧ + V" }
        var parts: [String] = []
        if combo.modifiers.contains(.command) { parts.append("⌘") }
        if combo.modifiers.contains(.option) { parts.append("⌥") }
        if combo.modifiers.contains(.shift) { parts.append("⇧") }
        if combo.modifiers.contains(.control) { parts.append("⌃") }
        if let key = combo.key {
            parts.append(key.description)
        } else {
            parts.append("?")
        }
        return parts.joined(separator: " + ")
    }
}