# FXConvert

A tiny, native macOS menu bar app for quick currency conversion. Click the icon, type an amount, pick two currencies, see the converted result instantly — no browser tab, no separate app window.

## Features

- Lives in the menu bar only (no Dock icon, no app switcher clutter)
- Live exchange rates, cached locally so it still works offline
- Remembers your last-used amount and currency pair between launches
- Zero third-party dependencies — pure SwiftUI + Foundation + AppKit
- No Xcode.app required to build — just the Swift toolchain

## Requirements

- macOS 13 (Ventura) or later
- Swift toolchain (Xcode Command Line Tools are enough — full Xcode.app is not required)

## Installing from source

```bash
git clone https://github.com/rmurali200/FXConvert.git
cd FXConvert
./Scripts/build-app.sh
open FXConvert.app
```

This builds a release binary via Swift Package Manager and wraps it into a standard `.app` bundle. The app is unsigned, so on first launch macOS Gatekeeper may block it — right-click (or Control-click) `FXConvert.app` and choose **Open**, or approve it under **System Settings → Privacy & Security**.

To have it available like any other app, drag `FXConvert.app` into `/Applications`.

## Usage

- Click the `$` icon in the menu bar to open the converter.
- Type an amount, pick the "from" and "to" currencies from the dropdowns.
- Use the swap button to flip the two currencies.
- The status line at the bottom shows when rates were last updated, or "Offline" if the last refresh failed (cached rates are still used).
- Click **Refresh** to force a re-fetch.

## How it works

| File | Purpose |
|---|---|
| `Package.swift` | Swift Package Manager manifest — single executable target, no dependencies |
| `Sources/FXConvert/FXConvertApp.swift` | App entry point; sets up the `MenuBarExtra` scene and menu bar icon |
| `Sources/FXConvert/CurrencyStore.swift` | App state and conversion math; persists last-used pair via `@AppStorage` |
| `Sources/FXConvert/RatesService.swift` | Fetches live rates from the exchange rate API |
| `Sources/FXConvert/RatesCache.swift` | Local JSON cache so the app works offline |
| `Sources/FXConvert/ConverterView.swift` | The popover UI |
| `Scripts/build-app.sh` | Builds and packages the `.app` bundle without needing Xcode.app |

Rates are fetched relative to a single base currency (USD), so converting between any two currencies is a cross-rate calculation (`amount * (toRate / fromRate)`) rather than a separate API call per pair.

## Rate data

Exchange rates come from [frankfurter.app](https://www.frankfurter.app), a free, keyless API backed by European Central Bank reference rates. These update once per business day (~4pm CET) — good for everyday conversions, but not a live/intraday market feed. Cached rates are used automatically whenever a refresh fails (e.g. offline).

## Roadmap

- Swap in a more frequently-updated (hourly) rate provider
- Possible future paid distribution on the Mac App Store

## Contributing

Issues and pull requests are welcome. Fork it, hack on it, install it on your own machine — that's the point.

## License

MIT — see [LICENSE](LICENSE).
