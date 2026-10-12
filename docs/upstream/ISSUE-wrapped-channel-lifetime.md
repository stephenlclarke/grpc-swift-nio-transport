# Wrapped-channel shutdown can abandon an eagerly configured connection

## Description

A transport created with `WrappedChannel.wrapping` owns a configured NIO async channel before its connection runner starts. Graceful shutdown while idle currently changes state without closing that channel. Shutdown racing configuration closes only the raw socket and does not finish the async writer. Releasing the transport can therefore trap with `Deinited NIOAsyncWriter without calling finish()`. Requests queued before SETTINGS are also abandoned when shutdown or lazy pipeline configuration failure discards their state.

## Reproduction

Create a configured wrapped-channel client and close it immediately, before running `connect()`. In the SDK, construct a guest client over a socket pair, then close it immediately and release the connection owner. An existing checked-continuation bootstrap additionally exposed the configured value before socket activation, allowing the same writer to be released during `channelActive`. Both raw crash traces are retained in the Container-family performance/parity goal evidence.

## Expected behavior

The successful factory owns the channel until scoped disposal. Closing must work before connection startup, during configuration and after readiness. Queued requests must resume with `unavailable`, exactly once, when no connection can become ready.

## Compatibility

The factory and existing connect APIs stay source compatible. The SDK should use NIO's typed bootstrap API and await transport closure directly so that a GRPC client shutdown before `runConnections()` cannot bypass transport cleanup. No protocol payload or upstream baseline measurement changes.

Related: [implementation handoff](PR-wrapped-channel-lifetime.md).
