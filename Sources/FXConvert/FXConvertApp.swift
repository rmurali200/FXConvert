import SwiftUI
import AppKit

@main
struct FXConvertApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var store = CurrencyStore()

    private static let statusIcon: NSImage = {
        let config = NSImage.SymbolConfiguration(pointSize: 16, weight: .heavy)
            .applying(.init(scale: .medium))
        let image = NSImage(systemSymbolName: "dollarsign.circle.fill", accessibilityDescription: "FXConvert")?
            .withSymbolConfiguration(config)
        image?.isTemplate = true
        return image ?? NSImage()
    }()

    var body: some Scene {
        MenuBarExtra {
            ConverterView()
                .environmentObject(store)
        } label: {
            Image(nsImage: Self.statusIcon)
        }
        .menuBarExtraStyle(.window)

        // A dedicated Window (not the Settings scene / SettingsLink) — SettingsLink is
        // unreliable from a MenuBarExtra popover on an accessory (LSUIElement) app, since
        // the app often fails to activate and bring the window forward. Window + an explicit
        // NSApp.activate before openWindow (see ConverterView) works reliably instead.
        Window("Preferences", id: "preferences") {
            PreferencesView()
                .environmentObject(store)
        }
        .windowResizability(.contentSize)
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    /// Only one copy may run at a time. A second launch (e.g. the build-folder copy and the
    /// /Applications copy, which share a bundle identifier) would otherwise add a second
    /// menu bar icon. The newcomer hands off to the instance already running and exits.
    func applicationWillFinishLaunching(_ notification: Notification) {
        guard let bundleID = Bundle.main.bundleIdentifier else { return }
        let others = NSRunningApplication.runningApplications(withBundleIdentifier: bundleID)
            .filter { $0 != NSRunningApplication.current }
        if let existing = others.first {
            existing.activate()
            exit(0)
        }
    }
}
