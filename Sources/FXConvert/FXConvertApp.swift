import SwiftUI
import AppKit

@main
struct FXConvertApp: App {
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
