//
//  NetworkSession.swift
//  
//  See LICENSE for more details.
//  Copyright © 2016-2022 Farhan Ahmed. All rights reserved.
//

import Foundation

/// A type that is used for send requests to a remote server.
///
/// Generally, the provided `ServiceSession` is used for the
/// majority of use-cases that use Apple's URLSession framework.
///
/// However, in the event that a different networking library/framework
/// needs to be used, Helium can accomodate that fairly easily using this
/// protocol.
///
/// An object can be created that conforms to this protocol and
/// its internal implementation can invoke any number of networking
/// libraries that need to be used.
public protocol NetworkSession
{
    /// Close the connection to the service and optionally
    /// allow any tasks that are currently in-flight to complete.
    func close(should_allow_task_to_complete: Bool)

    /// This method will connect to the server using the provided request
    /// and upon getting back a response it will parse that response returning
    /// the data that was received. In case of error, it will be passed
    /// along to the completion handler.
    ///
    /// - Parameters:
    ///     - request: An object that conforms to the `NetworkRequest` protocol.
    ///     - completion: A closure that will be triggered when the request completes.
    func send<Model>(request: NetworkRequest) async throws -> Model where Model: Codable
}
