import Foundation

struct CachedRates: Codable {
    let base: String
    let rates: [String: Double]
    let fetchedAt: Date
}

enum RatesCache {
    private static var cacheFileURL: URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let dir = appSupport.appendingPathComponent("FXConvert", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("rates.json")
    }

    static func load() -> CachedRates? {
        guard let data = try? Data(contentsOf: cacheFileURL) else { return nil }
        return try? JSONDecoder().decode(CachedRates.self, from: data)
    }

    static func save(_ cached: CachedRates) {
        guard let data = try? JSONEncoder().encode(cached) else { return }
        try? data.write(to: cacheFileURL, options: .atomic)
    }
}
