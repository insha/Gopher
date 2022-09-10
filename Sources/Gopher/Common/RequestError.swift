//
//  RequestError.swift
//  
//  See LICENSE for more details.
//  Copyright © 2016-2022 Farhan Ahmed. All rights reserved.
//

import Foundation

/// This type is used to represent all errors that occur
/// when interacting with a remote service.
///
/// An instance of this object will be propagated up when
/// an  error occurs.
public struct RequestError: NetworkError
{
    public enum ErrorKind: String
    {
        case noError
        case invalidURL
        case serverNotAvailable
        case internalServerError
        case badRequest
        case badResponse
        case noContent
        case noInternetConnectionAvailable
        case requestTimedOut
        case unauthorized
        case forbidden
        case resourceCreated
        case invalidHTTPStatusCode
        case maximumRetriesReached
        case connectivityIssue

        public var errorCode: Int
        {
            let code: Int

            switch self
            {
                case .noError: code = -100_000
                case .invalidURL: code = -100_001
                case .serverNotAvailable: code = -100_002
                case .internalServerError: code = -100_003
                case .badRequest: code = -100_004
                case .badResponse: code = -100_005
                case .noContent: code = -100_006
                case .noInternetConnectionAvailable: code = -100_007
                case .requestTimedOut: code = -100_008
                case .unauthorized: code = -100_009
                case .forbidden: code = -100_010
                case .resourceCreated: code = -100_011
                case .invalidHTTPStatusCode: code = -100_013
                case .maximumRetriesReached: code = -100_014
                case .connectivityIssue: code = -100_015
            }

            return code
        }
    }

    public var code: Int
    public var statusCode: Int
    public var message: String
    public var domain: String
    public var relatedURL: URL?

    public var kind: String
    {
        errorKind.rawValue
    }

    public var errorKind: ErrorKind

    public init(_ errorKind: ErrorKind,
                message: String,
                statusCode: Int,
                url: URL?,
                domain: String)
    {
        self.errorKind = errorKind
        self.message = message
        self.domain = domain
        self.statusCode = statusCode
        
        relatedURL = url
        code = errorKind.errorCode
    }
}
