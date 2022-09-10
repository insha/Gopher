//
//  Request.swift
//  
//  See LICENSE for more details.
//  Copyright © 2016-2022 Farhan Ahmed. All rights reserved.
//

import Foundation

/// A type that is used for representing an HTTP request.
///
/// It is provided as a convinence and as an example of
/// how `NetworkRequest` protocol can be used. This `struct`
/// can be used for quickly getting up and running, when no
/// customization is desired or needed.
///
/// Once passed to an object that is confirming to the
/// `NetworkSession` protocol, it is used to create the low
/// level HTTP request that is transmitted to the remote
/// service.
public struct Request: NetworkRequest
{
    public var name: String
    public var identifier: String
    public var method: HTTPMethod
    public var endpoint: String
    public var url: URL?
    public var timeout: TimeInterval
    public var parameters: GopherContent
    public var headers: GopherHeader

    public init(endpoint: String,
                method: HTTPMethod,
                headers: GopherHeader = [:],
                parameters: GopherContent = [:],
                timeout: TimeInterval = 60)
    {
        self.endpoint = endpoint
        self.method = method
        self.timeout = timeout
        self.headers = headers
        self.parameters = parameters

        identifier = UUID().uuidString
        name = "[\(method.rawValue.uppercased())] \(endpoint.lowercased())"
    }

    public mutating func addParameters(parameters: GopherQueryParameter)
    {
        self.parameters = parameters
    }
}
