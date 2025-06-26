import Cocoa
import HotKey

class HotKeyPopoverViewController: NSViewController {
    private var isKorean: Bool {
        Locale.current.language.languageCode?.identifier == "ko"
    }
    private let currentHotKeyLabel = NSTextField(labelWithString: "")
    private let changeButton = NSButton(title: "", target: nil, action: nil)
    private let saveButton = NSButton(title: "", target: nil, action: nil)
    private var keyMonitor: Any?
    private var capturedKey: Key?
    private var capturedModifiers: NSEvent.ModifierFlags?
    private var isCapturing = false
    private var currentHotKeyPrefix: String { isKorean ? "현재 단축키: " : "Current Hotkey: " }
    private var inputGuideText: String { isKorean ? "새 단축키를 입력하세요..." : "Enter new hotkey..." }
    private var changeButtonTitle: String { isKorean ? "변경" : "Change" }
    private var saveButtonTitle: String { isKorean ? "저장" : "Save" }
    private var unsupportedKeyText: String { isKorean ? "지원하지 않는 키입니다. 다시 시도하세요." : "Unsupported key. Try again." }

    override func loadView() {
        self.view = NSView(frame: NSRect(x: 0, y: 0, width: 240, height: 120))
        currentHotKeyLabel.alignment = .center
        currentHotKeyLabel.font = NSFont.systemFont(ofSize: 15, weight: .medium)
        currentHotKeyLabel.translatesAutoresizingMaskIntoConstraints = false
        changeButton.setButtonType(.momentaryPushIn)
        saveButton.setButtonType(.momentaryPushIn)
        changeButton.font = NSFont.systemFont(ofSize: 13)
        saveButton.font = NSFont.systemFont(ofSize: 13)
        changeButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        changeButton.title = changeButtonTitle
        saveButton.title = saveButtonTitle
        // 버튼 그룹 StackView
        let buttonStack = NSStackView(views: [changeButton, saveButton])
        buttonStack.orientation = .horizontal
        buttonStack.spacing = 16
        buttonStack.alignment = .centerX
        buttonStack.distribution = .equalCentering
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        // 전체 StackView
        let mainStack = NSStackView(views: [currentHotKeyLabel, buttonStack])
        mainStack.orientation = .vertical
        mainStack.spacing = 18
        mainStack.alignment = .centerX
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainStack)
        NSLayoutConstraint.activate([
            mainStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mainStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            mainStack.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9)
        ])
        updateHotKeyLabel()
        changeButton.target = self
        changeButton.action = #selector(beginKeyCapture)
        saveButton.target = self
        saveButton.action = #selector(saveHotKey)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(hotKeyChanged), name: HotKeyManager.hotKeyChangedNotification, object: nil)
    }

    private func updateHotKeyLabel() {
        currentHotKeyLabel.stringValue = currentHotKeyPrefix + HotKeyManager.shared.currentHotKeyDescription()
        currentHotKeyLabel.alignment = .center
    }

    @objc private func beginKeyCapture() {
        isCapturing = true
        currentHotKeyLabel.stringValue = inputGuideText
        currentHotKeyLabel.alignment = .center
        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self = self else { return event }
            if let monitor = self.keyMonitor {
                NSEvent.removeMonitor(monitor)
                self.keyMonitor = nil
            }
            if let key = Key(carbonKeyCode: UInt32(event.keyCode)) {
                let modifiers = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
                self.capturedKey = key
                self.capturedModifiers = modifiers
                self.currentHotKeyLabel.stringValue = self.currentHotKeyPrefix + self.describeHotKey(key: key, modifiers: modifiers)
            } else {
                self.currentHotKeyLabel.stringValue = self.unsupportedKeyText
            }
            self.isCapturing = false
            return nil
        }
    }

    @objc private func saveHotKey() {
        guard let key = capturedKey, let modifiers = capturedModifiers else { return }
        HotKeyManager.shared.updateHotKey(key: key, modifiers: modifiers, target: NSApp.delegate as AnyObject, action: #selector(AppDelegate.showPopover))
        print("💾 Hotkey saved")
        self.view.window?.close()
    }

    @objc private func hotKeyChanged() {
        updateHotKeyLabel()
    }

    private func describeHotKey(key: Key, modifiers: NSEvent.ModifierFlags) -> String {
        var parts: [String] = []
        if modifiers.contains(.command) { parts.append("⌘") }
        if modifiers.contains(.option) { parts.append("⌥") }
        if modifiers.contains(.shift) { parts.append("⇧") }
        if modifiers.contains(.control) { parts.append("⌃") }
        parts.append(key.description)
        return parts.joined(separator: " + ")
    }
} 