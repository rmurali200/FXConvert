import SwiftUI
import AppKit

struct ConverterView: View {
    @EnvironmentObject var store: CurrencyStore
    @State private var didCopy = false

    private var resultFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = min(2, store.decimalPrecision)
        formatter.maximumFractionDigits = store.decimalPrecision
        return formatter
    }

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("FXConvert")
                .font(.headline)

            Grid(alignment: .leading, horizontalSpacing: 8, verticalSpacing: 12) {
                GridRow {
                    TextField("Amount", text: $store.amountText)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 100)
                        .onChange(of: store.amountText) { _, newValue in
                            let filtered = ConversionMath.filterAmountInput(newValue)
                            if filtered != newValue {
                                store.amountText = filtered
                            }
                        }

                    Picker("", selection: $store.fromCurrency) {
                        ForEach(store.favoriteCurrencyCodes.sorted(), id: \.self) { code in
                            Text(code).tag(code)
                        }
                    }
                    .labelsHidden()
                    .frame(width: 90)
                }

                GridRow {
                    Button {
                        store.swapCurrencies()
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                    }
                    .buttonStyle(.borderless)
                }

                GridRow {
                    Text(resultText)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .frame(width: 100, alignment: .leading)

                    Picker("", selection: $store.toCurrency) {
                        ForEach(store.favoriteCurrencyCodes.sorted(), id: \.self) { code in
                            Text(code).tag(code)
                        }
                    }
                    .labelsHidden()
                    .frame(width: 90)

                    Button {
                        copyResultToClipboard()
                    } label: {
                        Image(systemName: didCopy ? "checkmark" : "doc.on.doc")
                    }
                    .buttonStyle(.borderless)
                    .disabled(store.result == nil)
                }
            }

            Divider()

            HStack {
                if store.isOffline {
                    Image(systemName: "wifi.slash")
                        .foregroundStyle(.secondary)
                }
                Text(statusText)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                Button("Refresh") {
                    Task { await store.refresh() }
                }
                .font(.caption)

                SettingsLink {
                    Image(systemName: "gearshape")
                }
                .buttonStyle(.borderless)
            }
        }
        .padding()
        .frame(width: 260)
    }

    private var resultText: String {
        guard let result = store.result else { return "—" }
        return resultFormatter.string(from: NSNumber(value: result)) ?? "—"
    }

    private var statusText: String {
        guard let lastUpdated = store.lastUpdated else { return "No rates yet" }
        let prefix = store.isOffline ? "Offline · last updated " : "Updated "
        return prefix + Self.timeFormatter.string(from: lastUpdated)
    }

    private func copyResultToClipboard() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(resultText, forType: .string)
        didCopy = true
        Task {
            try? await Task.sleep(for: .seconds(1.2))
            didCopy = false
        }
    }
}
