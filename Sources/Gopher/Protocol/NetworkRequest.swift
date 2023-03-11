//
//  NetworkRequest.swift
//
//  See LICENSE for more details.
//  Copyright © 2016-2022 Farhan Ahmed. All rights reserved.
//

import Foundation

public protocol NetworkRequest
{
    var identifier: String { get }
    var method: HTTPMethod { get }
    var timeout: TimeInterval { get }
    var endpoint: String { get }
    var url: URL? { get }
    var parameters: GopherQueryParameter { get }
    var headers: GopherHeader { get }
    var body: GopherContent { get }
    var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy { get }
    var kind: NetworkRequestKind { get }
}

public extension NetworkRequest
{
    var dataFormat: DataFormat
    {
        if headers.values.contains(MimeType.binaryData)
        {
            return .form
        }
        else
        {
            return .json
        }
    }

    var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy
    {
        return .iso8601
    }

    var kind: NetworkRequestKind
    {
        return .data
    }
}

public enum NetworkRequestKind
{
    case data
    case download
}
