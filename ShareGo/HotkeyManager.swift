import Foundation
import KeyboardShortcuts
import HotKey
import AppKit

extension KeyboardShortcuts.Name {
    static let showShareGo = Self("showShareGo")
}

final class HotKeyManager {
    static let shared = HotKeyManager()
    static let hotKeyChangedNotification = Notification.Name("HotKeyChanged")

    private var hotKey: HotKey?
    private(set) var keyCombo: KeyCombo? = nil
    private let hotKeyUserDefaultsKey = "userHotKey"

    // 앱 실행 시 호출: 저장된 핫키가 있으면 등록, 없으면 기본값
    func registerSavedOrDefaultHotKey(target: AnyObject, action: Selector) {
        if let (key, modifiers) = loadHotKeyFromUserDefaults() {
            registerHotKey(key: key, modifiers: modifiers, target: target, action: action)
        } else {
            registerDefaultHotKey(target: target, action: action)
        }
    }

    // 핫키 변경 시 저장
    func saveHotKeyToUserDefaults(key: Key, modifiers: NSEvent.ModifierFlags) {
        let dict: [String: Any] = [
            "key": key.description,
            "modifiers": modifiers.rawValue
        ]
        UserDefaults.standard.set(dict, forKey: hotKeyUserDefaultsKey)
    }

    // 저장된 핫키 불러오기
    func loadHotKeyFromUserDefaults() -> (Key, NSEvent.ModifierFlags)? {
        guard let dict = UserDefaults.standard.dictionary(forKey: hotKeyUserDefaultsKey),
              let keyString = dict["key"] as? String,
              let modifiersRaw = dict["modifiers"] as? UInt,
              let key = Key(string: keyString) else { return nil }
        let modifiers = NSEvent.ModifierFlags(rawValue: modifiersRaw)
        return (key, modifiers)
    }

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
        saveHotKeyToUserDefaults(key: key, modifiers: modifiers)
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
