# FileGo

**FileGo** is a minimal and intuitive menu bar app for macOS that gives you quick access to your frequently used files and folders. Just hit a shortcut and your favorite files are right there — no more digging through Finder.

> Think of it as your personal quick-launch dock, but floating and flexible.

---

## 🚀 Features

- 🧲 **Global Hotkey** to instantly open the FileGo popover from anywhere
- 📂 **Drag & Drop Support** to easily add files or folders
- ⚡️ **One-Click Open**: Open registered files/folders in Finder with a single click
- 💾 **Persistent Storage**: Keeps your shortcuts even after reboot
- 🔐 **macOS Sandbox Friendly**: Uses security-scoped bookmarks to access user-selected files

---

## 🔧 Sandbox Considerations

FileGo is sandboxed for Mac App Store compatibility. To maintain access to files:
- Files/folders **must be added via drag & drop** from the user
- FileGo uses **security-scoped bookmarks** to persist access between launches

No file data is uploaded. Everything is stored **locally and securely** using Apple’s recommended APIs.

---

## ⌨️ Default Shortcut

```text
Command (⌘) + Shift (⇧) + F