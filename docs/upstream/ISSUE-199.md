# Core target omits directly used NIO dependencies

[Upstream issue #199](https://github.com/grpc/grpc-swift-nio-transport/issues/199) identifies direct `NIOHTTP1.HTTPResponseStatus` and `NIOTLS.TLSUserEvent` references whose product dependencies were only supplied transitively. Static linkage can conceal the omission; dynamic-framework linkage can fail with undefined symbols.

Declare `NIOHTTP1` and `NIOTLS` from the existing swift-nio package on `GRPCNIOTransportCore`. No package requirement or resolved version needs changing. [Upstream PR #200](https://github.com/grpc/grpc-swift-nio-transport/pull/200) already proposes the same two declarations; this local candidate does not justify a duplicate upstream PR.
