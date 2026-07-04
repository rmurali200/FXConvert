import SwiftUI

struct PreferencesView: View {
    @EnvironmentObject var store: CurrencyStore
    @StateObject private var launchAtLogin = LaunchAtLoginManager()

    var body: some View {
        TabView {
            GeneralPreferencesTab(store: store, launchAtLogin: launchAtLogin)
                .tabItem { Label("General", systemImage: "gearshape") }
            FavoritesPreferencesTab(store: store)
                .tabItem { Label("Favorites", systemImage: "star") }
        }
        .frame(width: 380, height: 320)
        .onAppear { launchAtLogin.refreshStatus() }
    }
}

private struct GeneralPreferencesTab: View {
    @ObservedObject var store: CurrencyStore
    @ObservedObject var launchAtLogin: LaunchAtLoginManager

    private let refreshIntervalOptions: [(label: String, hours: Double)] = [
        ("Every hour", 1),
        ("Every 4 hours", 4),
        ("Every 12 hours", 12),
        ("Once a day", 24)
    ]

    private let decimalPrecisionOptions = [0, 2, 3, 4, 6]

    var body: some View {
        Form {
            Picker("Refresh rates", selection: $store.refreshIntervalHours) {
                ForEach(refreshIntervalOptions, id: \.hours) { option in
                    Text(option.label).tag(option.hours)
                }
            }

            Picker("Decimal precision", selection: $store.decimalPrecision) {
                ForEach(decimalPrecisionOptions, id: \.self) { digits in
                    Text("\(digits) digits").tag(digits)
                }
            }

            Toggle("Launch at Login", isOn: Binding(
                get: { launchAtLogin.isEnabled },
                set: { launchAtLogin.setEnabled($0) }
            ))
        }
        .padding()
    }
}

private struct FavoritesPreferencesTab: View {
    @ObservedObject var store: CurrencyStore
    @State private var filterText = ""

    private var filteredCodes: [String] {
        let all = store.sortedCurrencyCodes
        guard !filterText.isEmpty else { return all }
        return all.filter { $0.localizedCaseInsensitiveContains(filterText) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField("Filter currencies", text: $filterText)
                .textFieldStyle(.roundedBorder)

            List(filteredCodes, id: \.self) { code in
                Toggle(code, isOn: Binding(
                    get: { store.favoriteCurrencyCodes.contains(code) },
                    set: { isOn in
                        var favorites = store.favoriteCurrencyCodes
                        if isOn {
                            favorites.append(code)
                        } else {
                            favorites.removeAll { $0 == code }
                        }
                        store.favoriteCurrencyCodes = favorites
                    }
                ))
            }
        }
        .padding()
    }
}
