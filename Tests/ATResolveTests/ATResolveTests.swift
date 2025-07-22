import Testing
import ATResolve
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

struct ATResolveTests {
	@Test
	func resolveHandle() async throws {
		let resolver = ATResolver(provider: URLSession.shared)

		let data = try await resolver.resolveHandle("massicotte.org")
		
		#expect(data?.did == "did:plc:klsh7edzj3jmxucibyjqstb3")
		#expect(data?.handle == "massicotte.org")
		#expect(data?.serviceEndpoint == "https://milkcap.us-west.host.bsky.network")
	}
	
	@Test
	func didForDomain() async throws {
		let resolver = ATResolver(provider: URLSession.shared)

		let did = try await resolver.didForDomain("massicotte.org")
		
		#expect(did == "did:plc:klsh7edzj3jmxucibyjqstb3")
	}
	
	@Test
	func blueskyGetProfile() async throws {
		let resolver = ATResolver(provider: URLSession.shared)

		let profile = try await resolver.blueskyGetProfile("massicotte.org")
		
		#expect(profile.did == "did:plc:klsh7edzj3jmxucibyjqstb3")
	}
	
	@Test func bskySocialHandle() async throws {
		let resolver = ATResolver(provider: URLSession.shared)

		let profile = try await resolver.resolveHandle("cjrdev.bsky.social")
		
		#expect(profile != nil)
	}

	@Test func decodeWithCustomProvider() async throws {
		struct CustomProvider: ResponseProviding {
			let content = """
	{"@context":["https://www.w3.org/ns/did/v1","https://w3id.org/security/multikey/v1","https://w3id.org/security/suites/secp256k1-2019/v1"],"id":"did:plc:klsh7edzj3jmxucibyjqstb3","alsoKnownAs":["at://massicotte.org"],"verificationMethod":[{"id":"did:plc:klsh7edzj3jmxucibyjqstb3#atproto","type":"Multikey","controller":"did:plc:klsh7edzj3jmxucibyjqstb3","publicKeyMultibase":"zQ3shP3NvazgSaEFpryzuyx8Q4MHho2KC2MNobAuQX3gdKAPW"}],"service":[{"id":"#atproto_pds","type":"AtprotoPersonalDataServer","serviceEndpoint":"https://milkcap.us-west.host.bsky.network"}]}
"""

			func decodeJSON<T>(at urlString: String, queryItems: [(String, String)]) async throws -> T where T : Decodable {
				try JSONDecoder().decode(T.self, from: Data(content.utf8))
			}
		}

		let resolver = ATResolver(provider: CustomProvider())

		let response = try await resolver.plcDirectoryQuery("did:plc:klsh7edzj3jmxucibyjqstb3")

		#expect(response.pds?.serviceEndpoint == "https://milkcap.us-west.host.bsky.network")
	}
}
