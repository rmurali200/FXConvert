import Foundation

struct RatesResponse: Codable {
    let result: String
    let base_code: String
    let rates: [String: Double]
}

enum RatesServiceError: Error {
    case badResponse
}

enum RatesService {
    static let baseCurrency = "USD"

    static func fetchLatest() async throws -> RatesResponse {
        let url = URL(string: "https://open.er-api.com/v6/latest/\(baseCurrency)")!

        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw RatesServiceError.badResponse
        }
        let decoded = try JSONDecoder().decode(RatesResponse.self, from: data)
        guard decoded.result == "success" else {
            throw RatesServiceError.badResponse
        }
        return decoded
    }
}
