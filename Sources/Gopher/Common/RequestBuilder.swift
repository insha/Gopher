//
//  RequestBuilder.swift
//
//  See LICENSE for more details.
//  Copyright © 2016-2022 Farhan Ahmed. All rights reserved.
//

import Foundation

public final class RequestBuilder
{
    private var name: String
    private var identifier: String
    private var method: HTTPMethod
    private var endpoint: String
    private var timeout: TimeInterval
    private var parameters: GopherQueryParameter
    private var body: GopherContent
    private var headers: GopherHeader
    private var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy

    public init()
    {
        endpoint = ""
        method = HTTPMethod.get
        timeout = 60
        headers = [:]
        parameters = []
        body = [:]
        dateDecodingStrategy = .iso8601
        identifier = UUID().uuidString
        name = "[\(method.rawValue.uppercased())] \(endpoint.lowercased())"
    }

    public func resource(_ endpoint: String) -> Self
    {
        self.endpoint = endpoint

        return self
    }

    public func using(_ method: HTTPMethod) -> Self
    {
        self.method = method

        return self
    }

    public func parameter(_ name: String, value: String) -> Self
    {
        parameters.append(URLQueryItem(name: name, value: value))

        return self
    }

    public func parameters(_ value: GopherQueryParameter) -> Self
    {
        guard !value.isEmpty
        else
        {
            return self
        }

        parameters = value

        return self
    }

    public func header(_ key: Header, value: String) -> Self
    {
        headers[key.rawValue] = value

        return self
    }

    public func custom_header(_ key: String, value: String) -> Self
    {
        guard !key.isEmpty
        else
        {
            return self
        }

        headers[key] = value

        return self
    }

    public func timeoutAt(_ interval: TimeInterval) -> Self
    {
        timeout = interval

        return self
    }

    public func content(_ value: GopherContent) -> Self
    {
        body = value

        return self
    }

    public func date_decoding(_ strategy: JSONDecoder.DateDecodingStrategy) -> Self
    {
        dateDecodingStrategy = strategy

        return self
    }

    public func build() -> Request
    {
        guard !endpoint.isEmpty
        else
        {
            fatalError("An endpoint for a resource cannot be empty.")
        }

        let request = Request(endpoint: endpoint,
                              method: method,
                              headers: headers,
                              parameters: parameters,
                              body: body,
                              dateDecodingStrategy: dateDecodingStrategy,
                              timeout: timeout)
        return request
    }
}
