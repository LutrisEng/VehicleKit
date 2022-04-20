import Foundation

struct VKHTTP {
    enum HTTPError: Error {
        case responseMissingData
        case invalidURL
    }

    static let jsonDecoder = JSONDecoder()

    static func request<ResponseType: Codable>(
        _ url: URL,
        method: String = "GET",
        body: Data? = nil,
        headers: [String: String] = [:]
    ) async throws -> ResponseType {
        var request = URLRequest(url: url)
        request.httpMethod = method
        for header in headers {
            request.setValue(header.value, forHTTPHeaderField: header.key)
        }
        request.httpBody = body
        let data: Data = try await withCheckedThrowingContinuation {
            continuation in
            URLSession.shared.dataTask(with: request) { data, _, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let data = data {
                    continuation.resume(returning: data)
                } else {
                    continuation.resume(throwing: HTTPError.responseMissingData)
                }
            }
        }
        return try jsonDecoder.decode(ResponseType.self, from: data)
    }

    static func request<ResponseType: Codable>(
        _ urlString: String,
        method: String = "GET",
        body: Data? = nil,
        headers: [String: String] = [:]
    ) async throws -> ResponseType {
        guard let url = URL(string: urlString) else { throw HTTPError.invalidURL }
        return try await request(
            url,
            method: method,
            body: body,
            headers: headers
        )
    }
}
