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
    }
}
