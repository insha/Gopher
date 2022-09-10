//
//  NetworkError.swift
//  
//  See LICENSE for more details.
//  Copyright © 2016-2022 Farhan Ahmed. All rights reserved.
//

import Foundation

/// A type that is used for representing an error
/// when interacting with a remote server.
public protocol NetworkError: Error, CustomStringConvertible
{
    var code: Int { get }
    var statusCode: Int { get }
    var message: String { get }
    var domain: String { get }
    var relatedURL: URL? { get }
    var kind: String { get }
}

public extension NetworkError
{
    var description: String
    {
        return """
        Code   : \(statusCode) : \(code)
        Domain : \(domain)
        Kind   : \(kind)
        Message: \(message)
        URL    : \(relatedURL?.absoluteString ?? "Not applicable")
        """
    }
}
