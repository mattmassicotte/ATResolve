<div align="center">

[![Build Status][build status badge]][build status]
[![Platforms][platforms badge]][platforms]
[![Documentation][documentation badge]][documentation]

</div>

# ATResolve
AT Protocol PLC/DID/Whatever Resolver

I just want to resolve a handle to a DID and PDS. There's more to do, but this is a start. [This](https://github.com/mackuba/didkit/blob/master/lib/didkit/resolver.rb) could be a good reference.

## Integration

```swift
dependencies: [
    .package(url: "https://github.com/ATProtoKit/ATResolve", branch: "main")
]
```

## Usage

```swift
import ATResolve

let resolver = ATResolver(provider: URLSession.shared)

let data = try await resolver.resolveHandle("lucy.bsky.social")

print(data.did)
print(data.serviceEndpoint)
```

The `ATResolver` type also supports custom HTTP loading for compatibility with server frameworks that don't use URLSession.

```swift
struct CustomProvider: ResponseProviding {
    func decodeJSON<T>(at urlString: String, queryItems: [(String, String)]) async throws -> T where T : Decodable {
        // your custom code that loads and decodes JSON goes here
    }
}

let resolver = ATResolver(provider: CustomProvider())
```

## Contributing and Collaboration

I would love to hear from you! Issues or pull requests work great.

I prefer collaboration, and would love to find ways to work together if you have a similar project.

I prefer indentation with tabs for improved accessibility. But, I'd rather you use the system you want and make a PR than hesitate because of whitespace.

By participating in this project you agree to abide by the [Contributor Code of Conduct](https://github.com/ATProtoKit/.github/blob/main/CODE_OF_CONDUCT.md).

[build status]: https://github.com/mattmassicotte/ATResolve/actions
[build status badge]: https://github.com/mattmassicotte/ATResolve/workflows/CI/badge.svg
[platforms]: https://swiftpackageindex.com/ATProtoKit/ATResolve
[platforms badge]: https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FATProtoKit%2FATResolve%2Fbadge%3Ftype%3Dplatforms
[documentation]: https://swiftpackageindex.com/mattmassicotte/ATResolve/main/documentation
[documentation badge]: https://img.shields.io/badge/Documentation-DocC-blue
