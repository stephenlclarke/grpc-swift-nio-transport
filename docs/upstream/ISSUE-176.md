# UDS default authority breaks strict HTTP/2 peers

[Upstream issue #176](https://github.com/grpc/grpc-swift-nio-transport/issues/176) reports that an omitted UDS authority becomes a percent-encoded socket path. Strict HTTP/2 peers, including tonic, reject it as an invalid authority. The upstream maintainer welcomed a PR.

The socket path selects the connection endpoint; it must not become the default HTTP/2 service authority. Use `localhost` when authority is nil, preserve every explicit override, and retain the socket endpoint and constant pull-mode resolution. Dependency versions, connection lifecycle and fork enqueue-race fixes are outside this correction.

The end-to-end UDS authority test now checks `localhost` over a real client/server exchange. Resolver RED/GREEN and complete core/HTTP2 validation are recorded in the [PR handoff](PR-176.md); Vsock remains unavailable on the validation host.
