import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension URLSession: ResponseProviding {
	public func decodeJSON<T>(at urlString: String, queryItems: [(String, String)]) async throws -> T where T : Decodable {
		guard var components = URLComponents(string: urlString) else {
			throw ATResolverError.urlInvalid
		}

		components.queryItems = queryItems.map({ pair in
			URLQueryItem(name: pair.0, value: pair.1)
		})

		guard let url = components.url else {
			throw ATResolverError.urlInvalid
		}

		var request = URLRequest(url: url)

		request.httpMethod = "GET"
		request.setValue("application/json", forHTTPHeaderField: "Accept")

		let (data, response) = try await URLSession.shared.data(for: request)

		guard
			let httpResponse = response as? HTTPURLResponse,
			httpResponse.statusCode >= 200 && httpResponse.statusCode < 300
		else {
			print("data:", String(decoding: data, as: UTF8.self))
			print("response:", response)

			throw ATResolverError.requestFailed
		}

		return try JSONDecoder().decode(T.self, from: data)
	}
}
