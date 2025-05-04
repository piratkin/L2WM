import Cocoa
import Carbon
import SwiftUI

@main
struct LayoutWatcherApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    let statusItem = NSStatusBar.system.statusItem(
        withLength: NSStatusItem.variableLength)
    var layoutObserver: Any?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        updateLayout()

        statusItem.menu = NSMenu()
        statusItem.menu?.addItem(
            NSMenuItem(
                title: "Quit",
                action: #selector(quitApp),
                keyEquivalent: "q"))

        NSWorkspace.shared.notificationCenter.addObserver(self,
            selector: #selector(applicationLaunched(_:)),
            name: NSWorkspace.didLaunchApplicationNotification,
            object: nil)

        layoutObserver = DistributedNotificationCenter.default().addObserver(
            forName: Notification.Name(kTISNotifySelectedKeyboardInputSourceChanged as String),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateLayout()
        }
    }

    @objc func applicationLaunched(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let app = userInfo[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication {
            if app.bundleIdentifier == "com.apple.Music" {
                let script = """
                tell application "Music"
                    quit
                end tell
                """
                var error: NSDictionary?
                if let scriptObject = NSAppleScript(source: script) {
                    scriptObject.executeAndReturnError(&error)
                }
            }
        }
    }

    func updateLayout() {
        guard let layout = TISCopyCurrentKeyboardInputSource()?.takeUnretainedValue(),
              let ptr = TISGetInputSourceProperty(layout, kTISPropertyInputSourceLanguages) else {
            statusItem.button?.title = "--"
            return
        }

        let cfArray = unsafeBitCast(ptr, to: CFArray.self)
        let langs = cfArray as NSArray as? [String]

        statusItem.button?.title = langs?.first?.uppercased() ?? "--"
    }

    @objc func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}



