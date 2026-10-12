/*
 * Copyright 2024, gRPC Authors All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import GRPCCore
import NIOCore
import NIOEmbedded
import NIOHTTP2
import XCTest

@testable import GRPCNIOTransportCore

@available(gRPCSwiftNIOTransport 2.9, *)
final class WrappedChannelTests: XCTestCase {
  func testCloseBeforeConnectDisposesConfiguredChannel() async throws {
    let channel = NIOAsyncTestingChannel()
    let address = try SocketAddress(ipAddress: "127.0.0.1", port: 12345)
    let transport = try await HTTP2ClientTransport.WrappedChannel.wrapping { configure in
      try await configure(channel).flatMap { configured in
        channel.connect(to: address).map { configured }
      }.get()
    }

    XCTAssertTrue(channel.isActive)
    try await transport.close()
    XCTAssertFalse(channel.isActive)
    try await transport.connect()
    // Repeated shutdown must not start a second async-channel consumer.
    try await transport.close()
  }

  func testShutdownResumesRequestsQueuedBeforeSettings() async throws {
    for (configuring, configurationFails) in [(false, false), (true, false), (true, true)] {
      var state = HTTP2ClientTransport.WrappedChannel.State()
      if configuring {
        _ = state.connect()
      }
      do {
        let _: NIOHTTP2Handler.AsyncStreamMultiplexer<Void> =
          try await withCheckedThrowingContinuation { continuation in
            _ = state.enqueue(continuation: continuation, withID: QueueEntryID())
            let continuations:
              [CheckedContinuation<NIOHTTP2Handler.AsyncStreamMultiplexer<Void>, any Error>]
            if configurationFails {
              guard case .shutDown(let queued) = state.channelConfigured(multiplexer: nil) else {
                XCTFail("Failed configuration must return its queued requests")
                continuation.resume(
                  throwing: RPCError(
                    code: .internalError,
                    message: "Unexpected configuration action"
                  )
                )
                return
              }
              continuations = queued
            } else {
              switch state.beginGracefulShutdown() {
              case .closeChannel(let queued), .failQueuedStreams(let queued):
                continuations = queued
              default:
                XCTFail("An unready transport must return its queued requests")
                continuation.resume(
                  throwing: RPCError(code: .internalError, message: "Unexpected shutdown action")
                )
                return
              }
            }
            XCTAssertEqual(continuations.count, 1)
            for queued in continuations {
              queued.resume(
                throwing: RPCError(code: .unavailable, message: "The channel was closed")
              )
            }
          }
        XCTFail("A queued request must fail when shutdown starts")
      } catch let error as RPCError {
        XCTAssertEqual(error.code, .unavailable)
      }
    }
  }

  func testShutdownDuringConfigurationDisposesCompletedChannel() {
    var state = HTTP2ClientTransport.WrappedChannel.State()
    guard case .configureChannel = state.connect() else {
      XCTFail("The first connection must own configuration")
      return
    }
    guard case .failQueuedStreams(let continuations) = state.beginGracefulShutdown() else {
      XCTFail("Shutdown must drain requests while configuration is in flight")
      return
    }
    XCTAssertTrue(continuations.isEmpty)
    guard case .shutDown = state.channelConfigured(multiplexer: nil) else {
      XCTFail("A late configuration must be disposed of")
      return
    }
    _ = state.connectionClosed()
    guard case .shutDown = state else {
      XCTFail("Finished cleanup must be terminal")
      return
    }
    guard case .return = state.connect() else {
      XCTFail("A closed transport must not configure again")
      return
    }
  }
}
