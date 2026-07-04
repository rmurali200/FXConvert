import Foundation

struct RatesResponse: Codable {
    let amount: Double
    let base: String
    let date: String
    let rates: [String: Double]
}

enum RatesServiceError: Error {
    case badResponse
}

enum RatesService {
    static let baseCurrency = "USD"

    static func fetchLatest() async throws -> RatesResponse {
        var components = URLComponents(string: "https://api.frankfurter.app/latest")!
        components.queryItems = [URLQueryItem(name: "from", value: baseCurrency)]

        let (data, response) = try await URLSession.shared.data(from: components.url!)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw RatesServiceError.badResponse
        }
        var decoded = try JSONDecoder().decode(RatesResponse.self, from: data)
        // frankfurter.app omits the base currency from its own rates map; add the 1.0 identity
        // rate so downstream cross-rate math can treat every currency uniformly.
        decoded = RatesResponse(
            amount: decoded.amount,
            base: decoded.base,
            date: decoded.date,
            rates: decoded.rates.merging([decoded.base: 1.0]) { _, new in new }
        )
        return decoded
    }
}
