import Testing
import ATResolve

struct ATResolveTests {
	@Test
	func resolveHandle() async throws {
		let resolver = ATResolver()
		
		let data = try await resolver.resolveHandle("massicotte.org")
		
		#expect(data?.did == "did:plc:klsh7edzj3jmxucibyjqstb3")
		#expect(data?.handle == "massicotte.org")
		#expect(data?.serviceEndpoint == "https://milkcap.us-west.host.bsky.network")
	}
	
	@Test
	func didForDomain() async throws {
		let resolver = ATResolver()
		
		let did = try await resolver.didForDomain("massicotte.org")
		
		#expect(did == "did:plc:klsh7edzj3jmxucibyjqstb3")
	}
	
	@Test
	func blueskyGetProfile() async throws {
		let resolver = ATResolver()
		
		let profile = try await resolver.blueskyGetProfile("massicotte.org")
		
		#expect(profile.did == "did:plc:klsh7edzj3jmxucibyjqstb3")
	}
}
