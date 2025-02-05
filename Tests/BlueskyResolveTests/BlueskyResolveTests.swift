import Testing
@testable import BlueskyResolve

struct BlueskyResolveTests {
	@Test
	func resolveHandle() async throws {
		let resolver = BlueskyResolver()
		
		let data = try await resolver.resolveHandle("massicotte.org")
		
		#expect(data?.did == "did:plc:klsh7edzj3jmxucibyjqstb3")
		#expect(data?.handle == "massicotte.org")
		#expect(data?.serviceEndpoint == "https://milkcap.us-west.host.bsky.network")
	}
	
	@Test
	func didForDomain() async throws {
		let resolver = BlueskyResolver()
		
		let did = try await resolver.didForDomain("massicotte.org")
		
		#expect(did == "did:plc:klsh7edzj3jmxucibyjqstb3")
	}
	
	@Test
	func blueskyGetProfile() async throws {
		let resolver = BlueskyResolver()
		
		let profile = try await resolver.blueskyGetProfile("massicotte.org")
		
		#expect(profile.did == "did:plc:klsh7edzj3jmxucibyjqstb3")
	}
}
