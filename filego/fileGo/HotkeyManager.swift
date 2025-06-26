import Foundation
import KeyboardShortcuts
import HotKey
import AppKit

extension KeyboardShortcuts.Name {
    static let showFileGo = Self("showFileGo")
}

final class HotKeyManager {
    static let shared = HotKeyManager()
    static let hotKeyChangedNotification = Notification.Name("HotKeyChanged")

    private var hotKey: HotKey?
    private(set) var keyCombo: KeyCombo? = nil

    func registerDefaultHotKey(target: AnyObject, action: Selector) {
        // 기본값: ⌥ + A
        let key: Key = .a
        let modifiers: NSEvent.ModifierFlags = [.option]
        registerHotKey(key: key, modifiers: modifiers, target: target, action: action)
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
    
    func registerHotKey(key: Key, modifiers: NSEvent.ModifierFlags, target: AnyObject, action: Selector) {
        let combo = KeyCombo(key: key, modifiers: modifiers)
        keyCombo = combo
        hotKey = HotKey(keyCombo: combo)
        hotKey?.keyDownHandler = { [weak target] in
            _ = target?.perform(action)
        }
        NotificationCenter.default.post(name: HotKeyManager.hotKeyChangedNotification, object: nil)
    }
    
    func currentHotKeyDescription() -> String {
        if let combo = keyCombo {
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
        } else {
            // 기본값: ⌥ + A
            return "⌥ + A"
        }
    }
} 
