#if canImport(Foundation)
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension URLSession: ResponseProviding {
	public func data(for request: Request) async throws -> Data {
		var components = URLComponents()
		components.scheme = "https"
		components.host = request.host
		components.path = request.path
		components.queryItems = request.queryItems.map({ pair in
			URLQueryItem(name: pair.0, value: pair.1)
		})
		
		guard let url = components.url else {
			throw URLError(.badURL)
		}
		var urlRequest = URLRequest(url: url)
		urlRequest.httpMethod = request.method.rawValue
		for (key, value) in request.headers {
			urlRequest.addValue(value, forHTTPHeaderField: key)
		}
		urlRequest.addValue("text/plain;charset=UTF-8", forHTTPHeaderField: "Accept")
		let (data, response) = try await URLSession.shared.data(for: urlRequest)

		guard
			let httpResponse = response as? HTTPURLResponse,
			httpResponse.statusCode >= 200 && httpResponse.statusCode < 300
		else {
			print("data:", String(decoding: data, as: UTF8.self))
			print("response:", response)
			if let xrpcError = try? JSONDecoder().decode(XRPCError.self, from: data) {
				throw xrpcError
			} else {
				throw ATResolverError.requestFailed
			}
		}
		return data
	}
}
#endif
