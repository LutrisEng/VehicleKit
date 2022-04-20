import Foundation

struct VKHTTP {
    enum HTTPError: Error {
        case incompleteResponse
        case invalidURL
    }
    
    struct Response<ResponseType: Codable> {
        let data: ResponseType
        let response: URLResponse
    }

    static let jsonDecoder = JSONDecoder()
    
    static func rawRequest(
        _ url: URL,
        method: String = "GET",
        body: Data? = nil,
        headers: [String: String] = [:]
    ) async throws -> Response<Data> {
        var request = URLRequest(url: url)
        request.httpMethod = method
        for header in headers {
            request.setValue(header.value, forHTTPHeaderField: header.key)
        }
        request.httpBody = body
        let (data, response): (Data, URLResponse) = try await withCheckedThrowingContinuation {
            continuation in
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let data = data, let response = response {
                    continuation.resume(returning: (data, response))
                } else {
                    continuation.resume(throwing: HTTPError.incompleteResponse)
                }
            }
            task.resume()
        }
        return Response(data: data, response: response)
    }

    static func request<ResponseType: Codable>(
        _ url: URL,
        method: String = "GET",
        body: Data? = nil,
        headers: [String: String] = [:]
    ) async throws -> Response<ResponseType> {
        let response = try await rawRequest(url, method: method, body: body, headers: headers)
        return Response(
            data: try jsonDecoder.decode(ResponseType.self, from: response.data),
            response: response.response
        )
    }

    static func request<ResponseType: Codable>(
        _ urlString: String,
        method: String = "GET",
        body: Data? = nil,
        headers: [String: String] = [:]
    ) async throws -> Response<ResponseType> {
        guard let url = URL(string: urlString) else { throw HTTPError.invalidURL }
        return try await request(
            url,
            method: method,
            body: body,
            headers: headers
        )
    }
}
