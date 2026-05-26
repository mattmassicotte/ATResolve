import AsyncDNSResolver

enum ATResolverError: Error {
	case urlInvalid
	case requestFailed
}

struct XRPCError: Decodable, Error {
	let error: String
	let message: String?
}

public struct ResolvedData: Codable, Hashable, Sendable {
	public let did: String
	public let handle: String
	public let serviceEndpoint: String?
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

public struct ATResolver<Provider: ResponseProviding> {
	public let provider: Provider

	public init(provider: Provider) {
		self.provider = provider
	}
	
	public func didForDomain(_ name: String) async throws -> String? {
		// I don't understand exactly why, but this triggers a timeout. When I do it with `dig` it returns right away...
		if name.hasSuffix(".bsky.social") {
			return nil
		}
		
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
		
		return try await blueskyGetProfile(handle)?.did
	}
	
	public func blueskyGetProfile(_ actor: String) async throws -> BlueskyProfile? {
		do {
			return try await provider.decodeJSON(
				host: "public.api.bsky.app",
				path: "/xrpc/app.bsky.actor.getProfile",
				headers: ["Accept": "application/json"],
				queryItems: [("actor", actor)]
			)
		} catch let error as XRPCError
					where error.error == "InvalidRequest" &&
					(error.message?.localizedCaseInsensitiveContains("not found") == true ||
					error.message?.localizedCaseInsensitiveContains("invalid app.bsky.actor.getProfile params") == true) {
			return nil
		}
	}
	
	public func plcDirectoryQuery(
		_ did: String
	) async throws -> PLCDirectoryResolveDidResponse {
		try await provider.decodeJSON(
			host: "plc.directory",
			path: "/\(did)",
			headers: ["Accept": "application/json"]
		)
	}
	
	public func resolveHandle(_ handle: String) async throws -> ResolvedData? {
		guard let did = try await didForHandle(handle) else {
			return nil
		}
		print("did: \(did)")
		let directoryResult = try await plcDirectoryQuery(did)
		
		return ResolvedData(did: did, handle: handle, serviceEndpoint: directoryResult.pds?.serviceEndpoint)
	}
}

extension ATResolver: Sendable where Provider: Sendable {}

#if canImport(Foundation)
import Foundation

extension ResolvedData {
	public var personalDataServerURL: URL? {
		serviceEndpoint.flatMap(URL.init(string:))
	}
}
#endif
