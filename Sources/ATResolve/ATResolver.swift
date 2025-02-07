import AsyncDNSResolver
import Foundation

enum ATResolverError: Error {
	case urlInvalid
	case requestFailed
}

public struct ResolvedData: Codable, Hashable, Sendable {
	public let did: String
	public let handle: String
	public let serviceEndpoint: String?
	
	public var personalDataServerURL: URL? {
		serviceEndpoint.flatMap(URL.init(string:))
	}
}

public struct BlueskyProfile: Codable, Hashable, Sendable {
	public let did: String
	public let handle: String
	public let displayName: String
}

public struct PLCDirectoryResolveDidResponse: Codable, Hashable, Sendable {
	public struct Service: Codable, Hashable, Sendable {
		public let id: String
		public let type: String
		public let serviceEndpoint: String
	}
	
	public let id: String
	public let service: [Service]
	
	public var pds: Service? {
		service.first(where: { $0.type == "AtprotoPersonalDataServer" })
	}
}

extension URLSession {
	func jsonRequest<T: Decodable>(_ components: URLComponents) async throws -> T {
		guard let url = components.url else {
			throw ATResolverError.urlInvalid
		}
		
		var request = URLRequest(url: url)
		
		request.httpMethod = "GET"
		request.setValue("application/json", forHTTPHeaderField: "Accept")
		
		return try await jsonRequest(request)
	}
	
	func jsonRequest<T: Decodable>(_ request: URLRequest) async throws -> T {
		var updatedRequest = request
		
		updatedRequest.httpMethod = "GET"
		updatedRequest.setValue("application/json", forHTTPHeaderField: "Accept")
		
		let (data, response) = try await URLSession.shared.data(for: updatedRequest)
		
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

public struct ATResolver {
	public init() {
	}
	
	public func didForDomain(_ name: String) async throws -> String? {
		let resolver = try AsyncDNSResolver()
		
		let txtRecords = try await resolver.queryTXT(name: "_atproto." + name)
		
		let didRecord = txtRecords.first { record in
			record.txt.hasPrefix("did=")
		}
		
		return didRecord?.txt.components(separatedBy: "=").last
	}
	
	public func didForHandle(_ handle: String) async throws -> String? {
		if let did = try await didForDomain(handle) {
			return did
		}
		
		return try await blueskyGetProfile(handle).did
	}
	
	public func blueskyGetProfile(_ actor: String) async throws -> BlueskyProfile {
		var components = URLComponents()
		
		components.host = "public.api.bsky.app"
		components.scheme = "https"
		components.path = "/xrpc/app.bsky.actor.getProfile"
		components.queryItems = [
			URLQueryItem(name: "actor", value: actor)
		]
		
		return try await URLSession.shared.jsonRequest(components)
	}
	
	private func plcDirectoryQuery(_ did: String) async throws -> PLCDirectoryResolveDidResponse {
		var components = URLComponents()
		
		components.host = "plc.directory"
		components.scheme = "https"
		components.path = "/" + did
		
		return try await URLSession.shared.jsonRequest(components)
	}
	
	public func resolveHandle(_ handle: String) async throws -> ResolvedData? {
		guard let did = try await didForHandle(handle) else {
			return nil
		}
		
		let directoryResult = try await plcDirectoryQuery(did)
		
		return ResolvedData(did: did, handle: handle, serviceEndpoint: directoryResult.pds?.serviceEndpoint)
	}
}
