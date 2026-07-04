# FXConvert

A tiny, native macOS menu bar app for quick currency conversion. Click the icon, type an amount, pick two currencies, see the converted result instantly — no browser tab, no separate app window.

## Features

- Lives in the menu bar only (no Dock icon, no app switcher clutter)
- Live exchange rates across ~166 currencies, cached locally so it still works offline
- A configurable favorites list keeps the currency pickers short and relevant
- Copy the converted result to the clipboard in one click
- Accepts both `.` and `,` as a decimal separator
- Preferences pane: manage favorites, refresh interval, decimal precision, and Launch at Login
- Remembers your last-used amount and currency pair between launches
- Zero third-party dependencies — pure SwiftUI + Foundation + AppKit
- No Xcode.app required to build — just the Swift toolchain

## Requirements

- macOS 14 (Sonoma) or later
- Swift toolchain (Xcode Command Line Tools are enough — full Xcode.app is not required)

## Installing from source

```bash
git clone https://github.com/rmurali200/FXConvert.git
cd FXConvert
./Scripts/build-app.sh
open FXConvert.app
```

This builds a release binary via Swift Package Manager and wraps it into a standard `.app` bundle. By default it deletes the `.build/` compiler cache once the app is packaged, to keep the working tree clean — pass `--keep-cache` (`./Scripts/build-app.sh --keep-cache`) to keep it around for faster incremental rebuilds while iterating.

The app is unsigned, so on first launch macOS Gatekeeper will block it — see [First launch: getting past Gatekeeper](#first-launch-getting-past-gatekeeper) below.

To have it available like any other app, drag `FXConvert.app` into `/Applications`.

## Installing via Homebrew

```bash
brew tap rmurali200/fxconvert
brew install --cask fxconvert
```

This installs from a personal Homebrew tap (not the official `homebrew-cask` repo — see [Distribution](#distribution) below). The app is still unsigned, so the same Gatekeeper approval step applies on first launch.

## First launch: getting past Gatekeeper

However you installed it, opening `FXConvert.app` the first time shows *"Apple could not verify this app is free of malware"* with only **Done** and **Move to Trash** as options — there's no inline "Open" button, unlike older macOS versions.

1. Click **Done** (not Move to Trash).
2. Open **System Settings → Privacy & Security**.
3. Scroll to the **Security** section — you'll see *"'FXConvert' was blocked to protect your Mac"* with an **Open Anyway** button.
4. Click **Open Anyway**, then confirm with your password/Touch ID if prompted.
5. One more confirmation dialog may appear — click **Open**.

This is only needed once; it launches normally after that.

## Usage

- Click the `$` icon in the menu bar to open the converter.
- Type an amount, pick the "from" and "to" currencies from the dropdowns (favorites only — manage the full list from Preferences).
- Use the swap button to flip the two currencies, or the copy button to copy the result.
- The status line at the bottom shows when rates were last updated, or "Offline" if the last refresh failed (cached rates are still used).
- Click **Refresh** to force a re-fetch, or the gear icon to open Preferences.

## How it works

| File | Purpose |
|---|---|
| `Package.swift` | Swift Package Manager manifest — executable target + test target, no third-party dependencies |
| `Sources/FXConvert/FXConvertApp.swift` | App entry point; sets up the `MenuBarExtra` and `Settings` scenes and the menu bar icon |
| `Sources/FXConvert/CurrencyStore.swift` | App state: rates, favorites, preferences, conversion inputs; persists via `@AppStorage` |
| `Sources/FXConvert/ConversionMath.swift` | Pure cross-rate math and amount-input filtering, covered by unit tests |
| `Sources/FXConvert/RatesService.swift` | Fetches live rates from the exchange rate API |
| `Sources/FXConvert/RatesCache.swift` | Local JSON cache so the app works offline |
| `Sources/FXConvert/ConverterView.swift` | The popover UI |
| `Sources/FXConvert/PreferencesView.swift` | The Preferences window (General + Favorites tabs) |
| `Sources/FXConvert/LaunchAtLoginManager.swift` | Wraps `SMAppService` for the Launch at Login toggle |
| `Tests/FXConvertTests/` | Unit tests for `ConversionMath`, using Swift Testing |
| `Scripts/build-app.sh` | Builds and packages the `.app` bundle without needing Xcode.app |
| `Scripts/generate-icon.swift` | Regenerates the app icon from the menu bar's SF Symbol motif |
| `Scripts/package-release.sh` | Packages a versioned, zipped release artifact for the Homebrew cask |

Rates are fetched relative to a single base currency (USD), so converting between any two currencies is a cross-rate calculation (`amount * (toRate / fromRate)`) rather than a separate API call per pair.

## Rate data

Exchange rates come from [open.er-api.com](https://www.exchangerate-api.com/docs/free), a free, keyless API covering ~166 currencies. Rates update roughly once a day — good for everyday conversions, but not a live/intraday market feed. Cached rates are used automatically whenever a refresh fails (e.g. offline).

## Distribution

FXConvert is unsigned and unnotarized (no Apple Developer Program membership yet), so:

- It's distributed via a personal Homebrew tap ([homebrew-fxconvert](https://github.com/rmurali200/homebrew-fxconvert)), not the official `homebrew-cask` repo — hence the `brew tap` step above rather than a bare `brew install --cask fxconvert`.
- Gatekeeper will block first launch, however you install it — see [First launch: getting past Gatekeeper](#first-launch-getting-past-gatekeeper) above for the exact steps (it's an extra System Settings step now, not a simple right-click).

## Roadmap

- Swap in a more frequently-updated (hourly) rate provider
- Possible future code-signed/notarized release and official Mac App Store distribution

## Contributing

Issues and pull requests are welcome. Fork it, hack on it, install it on your own machine — that's the point.

## License

MIT — see [LICENSE](LICENSE).
