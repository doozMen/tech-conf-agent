# ServerSide.swift 2025: Two Days in London That Proved Swift Belongs on the Server

*The conference that showed server-side Swift is ready for production*

I just spent two days at ServerSide.swift 2025 in London, and the message was clear: Swift on the server isn't experimental anymore. Small teams are shipping production backends. Major cloud providers have first-class Swift SDKs. The tooling has matured.

Here's what matters from the conference.

---

## Type-Safe Redis Commands with Parameter Packs

**Adam Fowler** (Apple, Hummingbird maintainer) presented [valkey-swift](https://github.com/valkey-io/valkey-swift), a Redis/Valkey client leveraging Swift's parameter packs ([SE-0393](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0393-parameter-packs.md)) for compile-time type safety.

The problem with most Redis clients: you pass strings and hope the command is valid. Valkey-swift uses parameter packs to verify commands at compile time.

```swift
// Type-safe pipelining - each command returns its correct type
let (string, count, list) = try await connection.execute(
    .get("key1"),          // Returns String?
    .incr("counter"),      // Returns Int
    .lrange("list", 0, -1) // Returns [String]
)
```

Fowler was direct about the implementation: "Parameter packs were quite problematic to implement. But the result is worth it—you catch type errors before deployment, not in production."

The library handles Redis Cluster topology discovery with automatic failover, MOVED error handling during resharding, and connection pooling per node. Built on [SwiftNIO](https://github.com/apple/swift-nio), it integrates cleanly with async/await patterns.

**Key insight**: Type safety isn't just for application code. Infrastructure clients benefit from Swift's type system too.

**Resources**: [github.com/valkey-io/valkey-swift](https://github.com/valkey-io/valkey-swift) • [Swift Evolution SE-0393](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0393-parameter-packs.md)

---

## Swift 6 Concurrency Solves Real Server Problems

**Matt Massicotte** (contracted by Apple to write the [Swift 6 migration guide](https://www.swift.org/migration/documentation/migrationguide/)) focused his talk on patterns that actually work for server-side code.

The `@Concurrent` attribute solves actor isolation mismatches that plague server middleware. When you need to share state between requests, proper isolation patterns prevent data races—caught at compile time by Swift 6's strict concurrency checking.

**Four Evolution proposals** work together to make this practical:

- **[SE-0414](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0414-region-based-isolation.md) (Region-Based Isolation)**: Proves data race safety without requiring Sendable conformance by analyzing code flow
- **[SE-0430](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0430-transferring-parameters-and-results.md) (Sending Values)**: Transfer ownership of non-Sendable types across actors
- **[SE-0420](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0420-inheritance-of-actor-isolation.md) (Inheritance of Actor Isolation)**: Eliminates unnecessary suspensions in middleware chains
- **[SE-0417](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0417-task-executor-preference.md) (Task Executor Preference)**: Low-level performance tuning for sub-millisecond latency

Massicotte covered practical patterns for request-scoped state without sacrificing safety. Server applications have different concurrency requirements than client apps—you need patterns that handle thousands of concurrent requests, not dozens of UI updates.

**Production validation**: Vapor framework achieved zero data race crashes after adopting Sendable conformance. **Mikaela Caron** deployed her Fruitful app backend with Swift 6 strict concurrency mode catching bugs before production.

**Key insight**: Swift 6's concurrency model works for high-load server applications. The strict checking prevents entire categories of bugs.

**Resources**: [Matt's blog](https://massicotte.org) • [Swift 6 Migration Guide](https://www.swift.org/migration/documentation/migrationguide/) • [ConcurrencyRecipes](https://github.com/mattmassicotte/ConcurrencyRecipes)

---

## Vapor vs Hummingbird: Both Work, Pick Based on Needs

**Emma Gaubert** (iOS Developer at Decathlon) compared Vapor and Hummingbird in a practical, side-by-side analysis.

### What's the Same

Both frameworks:
- Support Fluent ORM
- Deploy to Docker and AWS Lambda
- Are open source with active development
- Built on SwiftNIO foundation

### What Differs

**[Vapor](https://vapor.codes)** (24k+ GitHub stars):
- Batteries-included framework with comprehensive middleware
- Established community (13k+ Discord members)
- Fluent ORM with PostgreSQL, MySQL, SQLite, MongoDB support
- Property wrappers (`@ID`, `@Field`, `@Parent`, `@Children`, `@Siblings`)
- JWT authentication via [vapor/jwt-kit](https://github.com/vapor/jwt-kit)
- Redis caching, WebSocket support built-in

**[Hummingbird](https://github.com/hummingbird-project/hummingbird)** (Adam Fowler):
- Lightweight with only 6 core dependencies
- Modular extension packages (Router, Fluent, Redis, WebSocket, Lambda, Auth)
- No Foundation requirement in core
- Swift 6-first architecture rebuilt in 2024
- Flexible for microservices and serverless

The choice isn't about which is "better"—it's about deployment targets and team preferences. Both frameworks are production-ready.

**Key insight**: Framework selection depends on your database needs and architectural preferences, not technical capability.

**Resources**: [vapor.codes](https://vapor.codes) • [hummingbird.codes](https://hummingbird.codes) • [Hummingbird GitHub](https://github.com/hummingbird-project/hummingbird)

---

## SongShift Runs Production Backend on Swift Lambda

**Ben Rosen** (Founder, SongShift) shared their production architecture running entirely on Swift Lambda functions. SongShift transfers playlists between streaming services across iOS, iPadOS, macOS, and visionOS.

### Their Evolution

- **2016**: Client-only app with local storage
- **2018**: Node.js + Docker + MongoDB (unsustainable for small team)
- **2020**: Swift on AWS Lambda (current)

### Technical Stack

- [Swift AWS Lambda Runtime](https://github.com/swift-server/swift-aws-lambda-runtime) (Swift Server Work Group)
- [Soto](https://github.com/soto-project/soto) (Swift SDK for all 200+ AWS services, SSWG Graduated)
- AWS Step Functions for workflow orchestration ([docs](https://docs.aws.amazon.com/step-functions/))
- [DynamoDB](https://docs.aws.amazon.com/dynamodb/) for state, [S3](https://docs.aws.amazon.com/s3/) for unstructured data
- [Terraform](https://developer.hashicorp.com/terraform/docs) for infrastructure as code

**The win**: They share Swift Package Manager packages between their iOS app and Lambda functions. Same data models, same validation logic, same type safety across client and server.

For a small team without dedicated backend engineers, serverless Swift eliminated server management overhead. Lambda handles scaling automatically. They pay per execution. Step Functions orchestrate long-running transfers across multiple Lambdas, handling the 15-minute Lambda timeout constraint.

**Performance**: Swift Lambda achieves 190-219ms cold starts (faster than C# .NET at 224ms, Java at 358ms) and 1.19ms warm execution matching Node.js and Python.

**Key insight**: Small teams can ship production backends with Swift without hiring specialized backend engineers.

**Resources**: [songshift.com](https://songshift.com) • [Swift AWS Lambda Runtime](https://github.com/swift-server/swift-aws-lambda-runtime) • [Soto SDK](https://github.com/soto-project/soto)

---

## Idiomatic AWS Integration with Swift Bedrock Library

**Mona Dierickx** built Swift wrapper patterns during her AWS internship and contributed the first Swift examples to [AWS Bedrock Runtime documentation](https://docs.aws.amazon.com/bedrock/latest/userguide/welcome.html).

The problem: Auto-generated AWS SDKs require 20+ lines of boilerplate for simple operations. The code isn't Swift-idiomatic.

**Before** (raw SDK):
```swift
// ~20+ lines of client setup, manual parameter configuration
let client = BedrockRuntimeClient(…)
let inferenceConfig = InferenceConfiguration(…)
// Base64 decoding required for responses
```

**After** (idiomatic wrapper):
```swift
let bedrock = try await BedrockService(authentication: .sso())
let image = try await bedrock
    .generateImage(.textPrompt, with: .nova_canvas)
try savePNGToDisk(data: image.images[0])
```

Five lines instead of twenty. Type-safe model selection (`.nova_canvas` instead of string literals). Direct typed responses—PNG data, not base64 strings. Native async/await throughout.

The [AWS SDK for Swift](https://github.com/awslabs/aws-sdk-swift) provides official Bedrock support through AWSBedrock, AWSBedrockRuntime, AWSBedrockAgent, and AWSBedrockAgentRuntime modules. The Converse API offers unified streaming chat across Amazon Nova, Anthropic Claude, Meta Llama, and other models.

**Key insight**: Swift needs idiomatic wrappers around auto-generated SDKs. Reduce boilerplate while preserving type safety.

**Resources**: [AWS SDK for Swift](https://github.com/awslabs/aws-sdk-swift) • [AWS Bedrock Documentation](https://docs.aws.amazon.com/bedrock/) • [Mona's GitHub](https://github.com/monadierickx)

---

## Zero-Copy Networking with Span

**Joannis Orlandos** (MongoKitten creator, Vapor core team) covered networking libraries using Swift's Span feature for zero-copy operations.

Span reduces memory allocations in hot paths. [MongoKitten](https://github.com/orlandos-nl/MongoKitten) uses these patterns for efficient BSON parsing. Hummingbird benefits from reduced allocations. EdgeOS (IoT systems) needs memory-efficient networking for constrained environments.

The trade-off: complexity vs performance. Orlandos was clear—"Span is great for zero-copy networking, but you need to weigh the complexity trade-offs."

For high-throughput message parsing or embedded systems, Span provides real benefits. For typical web applications, standard patterns work fine.

**Key insight**: Optimization tools exist when you need them. Use them when performance requirements justify the complexity.

**Resources**: [MongoKitten](https://github.com/orlandos-nl/MongoKitten) • [Joannis on GitHub](https://github.com/Joannis) • [swiftonserver.com](https://swiftonserver.com)

---

## Building Real Applications: Fruitful Backend

**Mikaela Caron** (Independent iOS Engineer, Swift Ecosystem Workgroup member) presented her journey building a conference networking app backend using Vapor.

### Technical Stack

- [Vapor 4](https://vapor.codes) framework
- [PostgreSQL](https://www.postgresql.org/docs/) with [Fluent ORM](https://docs.vapor.codes/4.0/fluent/)
- AWS S3 with [presigned URLs](https://docs.aws.amazon.com/AmazonS3/latest/userguide/PresignedUrlUploadObject.html) for direct uploads
- [Redis](https://redis.io/documentation) for caching attendee lists
- JWT authentication ([intro](https://jwt.io/introduction/)) with refresh token rotation
- [Docker](https://docs.docker.com/) containers on Linux VMs
- **Swift 6.0 strict concurrency mode** ([docs](https://www.swift.org/documentation/concurrency/))

### Architecture Decisions That Worked

**File Uploads**: AWS SDK for Swift generates presigned URLs. Clients upload directly to S3. No file data through the Vapor server. The repository pattern keeps S3 logic separated from route handlers—testable without AWS infrastructure.

**Caching**: Redis for conference attendee lists. Protocol-based cache abstraction means you can swap between in-memory and Redis without code changes.

**Concurrency**: Swift 6 strict concurrency catches data races at compile time. The compiler prevents entire categories of bugs before deployment.

### Learning Resources Used

- [theswiftdev.com](https://theswiftdev.com)
- [swifttoolkit.dev](https://swifttoolkit.dev)
- [serversideswift.info](https://serversideswift.info)
- [swiftonserver.com](https://swiftonserver.com)

**Key insight**: Learning server-side Swift means building real projects that solve actual problems and deploying to Linux.

**Resources**: [Fruitful App](https://getfruitful.app) • [Mikaela on GitHub](https://github.com/mikaelacaron) • [Swift over Coffee Podcast](https://twitter.com/mikaela__caron)

---

## gRPC Swift 2: Modern Distributed Systems

**George Barnett** (Apple Cloud Services, SwiftNIO contributor) announced [gRPC Swift 2](https://github.com/grpc/grpc-swift-2) as a complete rewrite leveraging modern Swift concurrency.

Announced at gRPConf 2024 with the keynote "Building a New gRPC Library in Swift," the modular ecosystem includes:

- **grpc-swift-2** - Core runtime with async/await
- **grpc-swift-nio-transport** - HTTP/2 via SwiftNIO ([repo](https://github.com/grpc/grpc-swift-2))
- **grpc-swift-protobuf** - Protocol Buffers integration with code generator ([repo](https://github.com/grpc/grpc-swift-2))
- **grpc-swift-extras** - Health service, reflection, OpenTelemetry, Swift Service Lifecycle ([repo](https://github.com/grpc/grpc-swift-2))

Protocol Buffers provide binary serialization with smaller messages than JSON, faster processing, and efficient encoding. The four RPC types (unary, server streaming, client streaming, bidirectional streaming) cover all communication patterns.

Production-ready features include automatic retry mechanisms, client-side load balancing, keepalive configuration, and standard gRPC status codes with `RPCErrorConvertible` for custom error types.

**Key insight**: Apple's investment in gRPC Swift demonstrates commitment to server-side distributed systems at internet scale.

**Resources**: [gRPC Swift 2](https://github.com/grpc/grpc-swift-2) • [Swift.org announcement](https://www.swift.org/blog/grpc-swift-2) • [George on GitHub](https://github.com/glbrntt)

---

## Swift Containerization: VM-per-Container Isolation

**Eric Ernst** (Apple Engineering Leader) announced Swift containerization at WWDC 2025, providing OCI-compliant Linux containers on macOS.

The unique architecture runs each container in its own lightweight VM using macOS Virtualization.framework for hardware-level isolation. Sub-second boot times result from an optimized Linux kernel (6.12+), minimal root filesystem, and **vminitd init system written in Swift**.

**Core components**:
- **ContainerizationEXT4**: Formats EXT4 filesystems programmatically
- **ContainerizationNetlink**: Configures dedicated IP addresses per container (no port forwarding)
- **ContainerizationOCI**: Manages OCI images with full Docker Hub compatibility

The system achieves security through VM isolation while maintaining container-like performance, offering an open-source alternative to Docker Desktop optimized for Apple Silicon.

**Key insight**: Apple is investing in Swift-based infrastructure tooling for modern cloud-native development.

**Resources**: [github.com/apple/containerization](https://github.com/apple/containerization) • [github.com/apple/container](https://github.com/apple/container)

---

## Production MongoDB with Native Swift Driver

**Joannis Orlandos** maintains [MongoKitten](https://github.com/orlandos-nl/MongoKitten) (v7.9.0+, SSWG Incubating), a pure Swift MongoDB driver with native BSON parsing and no C dependencies except SSL.

The companion [BSON library](https://github.com/orlandos-nl/BSON) implements BSON specification v1.1 with on-demand parsing and delayed data copies for performance. Unlike JSON, BSON stores binary data directly, supports additional types like ObjectId and Date natively, and maintains type information JSON cannot preserve.

Built on SwiftNIO with async/await patterns, MongoKitten supports MongoDB 3.6+ with GridFS for large files, change streams for real-time monitoring, ACID transactions (MongoDB 4.0+ replica sets), and aggregation pipelines. The Meow ORM layer adds type-safe query building with `@Field` property wrappers.

**Key insight**: Native Swift database drivers provide better performance and developer experience than C bindings.

**Resources**: [MongoKitten](https://github.com/orlandos-nl/MongoKitten) • [BSON Library](https://github.com/orlandos-nl/BSON) • [Joannis on GitHub](https://github.com/Joannis)

---

## Apple's Swift Server Commitment

The conference featured **seven members of Apple's Swift Server team**, demonstrating Apple's serious investment in server-side Swift:

- **Franz Busch** - SwiftNIO, networking protocols
- **George Barnett** - gRPC Swift implementation
- **Honza Dvorsky** - Swift Server Ecosystem, Swift Package Manager
- **Ben Cohen** - Swift Core Team Manager, language design
- **Si Beaumont** - Server infrastructure, systems programming
- **Eric Ernst** - Engineering Leadership, containerization
- **Agam Dua** - Swift Server Ecosystem & Education lead

Their presence signals that server-side Swift is a priority for Apple, not a community-only effort.

---

## Key Technical Themes

### 1. Swift 6 Concurrency Everywhere

Multiple talks emphasized strict concurrency checking and proper isolation patterns. Server applications have different concurrency requirements than client apps. Swift 6's model handles both with compile-time guarantees.

### 2. Type Safety Across the Stack

- Parameter packs for Redis commands (compile-time verification)
- Typed model selection in AWS Bedrock (no string literals)
- Shared SPM packages between client and server (zero duplication)

Type safety prevents production bugs across the entire stack.

### 3. Cloud-Native Patterns

- Serverless with Lambda (sub-200ms cold starts)
- Managed services (DynamoDB, S3, Redis)
- Infrastructure as Code (Terraform, Swift Cloud)
- First-class AWS SDK support ([Soto](https://github.com/soto-project/soto), [AWS SDK for Swift](https://github.com/awslabs/aws-sdk-swift))

Server-side Swift integrates cleanly with modern cloud platforms.

### 4. Production-Ready Tooling

Mature frameworks (Vapor, Hummingbird). Battle-tested libraries (SwiftNIO, Soto, MongoKitten). The ecosystem has stabilized with real production deployments running at scale.

### 5. Developer Experience

- Reducing boilerplate through idiomatic wrappers
- Leveraging Swift features (async/await, parameter packs, actors)
- Clear documentation and real examples
- Active community support

---

## What This Means for Server-Side Swift

### For Small Teams

You can ship backends without dedicated backend engineers. Serverless patterns reduce operational overhead. Shared packages between client and server eliminate duplication.

**Example**: SongShift runs production serverless architecture maintained by iOS team.

### For Production Systems

Swift 6 strict concurrency prevents data races at compile time. Multiple framework options based on needs. Mature ecosystem with battle-tested libraries (SwiftNIO, Soto, MongoKitten).

**Validation**: Apple's Password Monitoring Service migration from Java to Swift achieved 40% throughput increase, 50% hardware reduction, and 90% memory decrease.

### For Integration

- Swift interops with C++ ([SE-0425](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0425-int-cxx-interop.md)) and Java ecosystems
- Cloud providers have first-class Swift SDKs
- Distributed system tools (gRPC, Temporal) support Swift
- Standard Docker and Kubernetes deployment

### For Learning

Strong community resources and documentation. Real production case studies validate approaches. Active open source development with responsive maintainers.

---

## What's Next

Based on conference discussions:

- **Continued concurrency improvements** - Swift 6 adoption and refinement (e.g., [SE-0414](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0414-region-based-isolation.md), [SE-0430](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0430-transferring-parameters-and-results.md), [SE-0417](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0417-task-executor-preference.md))
- **Cloud platform integration** - More first-class AWS, Azure, GCP support (SPM ecosystem & registry growth)
- **Distributed systems tooling** - Temporal SDK expansion, gRPC enhancements (e.g., [SE-0336](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0336-distributed-actors.md))
- **Performance optimization** - Zero-copy networking, memory efficiency improvements (ownership/borrowing directions; [SE-0390](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0390-noncopyable-structs-and-enums.md))
- **Developer experience** - Better tooling, clearer patterns, more examples (Macros: [SE-0382](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0382-expression-macros.md), [SE-0396](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0396-freestanding-declaration-macros.md))

---

## The Verdict

**Server-side Swift is production-ready.** The talks weren't about proof-of-concepts—they covered production systems handling real load with real users.

Small teams ship backends without specialized infrastructure engineers. Type safety prevents bugs across the entire stack. Cloud integration is first-class. The tooling has matured.

If you've been waiting for server-side Swift to be "ready," it is.

---

## Resources

### Frameworks
- **Vapor**: [vapor.codes](https://vapor.codes) • [github.com/vapor/vapor](https://github.com/vapor/vapor)
- **Hummingbird**: [hummingbird.codes](https://hummingbird.codes) • [github.com/hummingbird-project/hummingbird](https://github.com/hummingbird-project/hummingbird)

### Libraries
- **Swift NIO**: [github.com/apple/swift-nio](https://github.com/apple/swift-nio)
- **Soto (AWS SDK)**: [github.com/soto-project/soto](https://github.com/soto-project/soto)
- **Valkey-swift**: [github.com/valkey-io/valkey-swift](https://github.com/valkey-io/valkey-swift)
- **RediStack**: [github.com/swift-server/RediStack](https://github.com/swift-server/RediStack)
- **Swift Temporal SDK**: [github.com/apple/swift-temporal-sdk](https://github.com/apple/swift-temporal-sdk)
- **AWS SDK for Swift**: [github.com/awslabs/aws-sdk-swift](https://github.com/awslabs/aws-sdk-swift)
- **MongoKitten**: [github.com/orlandos-nl/MongoKitten](https://github.com/orlandos-nl/MongoKitten)
- **gRPC Swift 2**: [github.com/grpc/grpc-swift-2](https://github.com/grpc/grpc-swift-2)

### Learning Resources
- [theswiftdev.com](https://theswiftdev.com) - Tutorials and guides
- [swifttoolkit.dev](https://swifttoolkit.dev) - Developer tools
- [serversideswift.info](https://serversideswift.info) - Conference website
- [swiftonserver.com](https://swiftonserver.com) - Community resources
- [massicotte.org](https://massicotte.org) - Swift concurrency deep dives

### Community
- **Swift Server Work Group**: [github.com/swift-server](https://github.com/swift-server)
- **Swift Forums**: [forums.swift.org](https://forums.swift.org)
- **Swift Package Index**: [swiftpackageindex.com](https://swiftpackageindex.com)

### Official Resources
- **Swift.org Blog**: [swift.org/blog](https://swift.org/blog)
- **Swift Evolution**: [github.com/apple/swift-evolution](https://github.com/apple/swift-evolution)
- **Swift 6 Migration Guide**: [swift.org/migration](https://www.swift.org/migration/documentation/migrationguide/)

---

## Call to Action

The conference organizers encouraged attendees to submit talks for next year. Your experience matters to the community. Production deployments. Failed experiments. Architecture decisions. All of it helps others.

If you're building with server-side Swift, share what you're learning.

**Conference**: ServerSide.swift 2025
**Location**: London, UK
**Dates**: October 2-3, 2025
**Website**: [serversideswift.info](https://serversideswift.info)
**Hashtags**: #swiftlang #serversideSwift2025

**Social**: [Bluesky](https://bsky.app/profile/serversideswift.info) • [Mastodon](https://hachyderm.io/@swiftserverconf) • [Twitter](https://twitter.com/SwiftServerConf) • [LinkedIn](https://www.linkedin.com/company/swiftserverconf) • [GitHub](https://github.com/SwiftServerConf)

---

Huge thanks to organizer Tim Condon ([Bluesky](https://bsky.app/profile/0xtim.bsky.social)) and to all the organizers and volunteers who made this conference possible.
