//
//  Gopher.swift
//
//  See LICENSE for more details.
//  Copyright © 2016-2022 Farhan Ahmed. All rights reserved.
//

import Foundation

/// An object that coordinates network releated tasks.
///
/// The `NetworkSession` class provides an API for interacting with
/// remote services. It provides capabilities for network profiling
/// and public key pinning.
///
/// `Gopher` service uses the `NetworkProvider` type to performa all
/// network related interactions. The `DefaultNetworkProvider` that is
/// provided, relies on the underlaying `URLSession` and related classes.
/// It is provided as both a convinence and an example of the `NetworkProvider`
/// usage that can be used to add networking using other libraries, when the
/// need arise.
///
public final class Gopher: NetworkSession
{
    private let profiler: Profiler
    private var session: NetworkProvider
    private var validSession = true

    public let settings: Configuration

    // MARK: - Lifecycle

    public init(provider: NetworkProvider, configuration: Configuration)
    {
        session = provider
        settings = configuration

        profiler = Profiler()
        profiler.enabled = settings.profileNetworkActivity
    }

    public func close(should_allow_task_to_complete shouldAllowTasksToComplete: Bool)
    {
        if shouldAllowTasksToComplete
        {
            session.finishTasksAndInvalidate()
        }
        else
        {
            session.invalidateAndCancel()
        }

        // Flushes cookies and credentials to disk, clears
        // transient caches, and ensures that future requests
        // occur on a new TCP connection.
        Task
        {
            await session.flush()
        }

        validSession = false
    }

    // MARK: - Protocol Conformance

    /// This method will connect to the server using the provided request
    /// and upon getting back a response it will parse that response returning
    /// the data that was received. In case of error, it will be passed
    /// along to the completion handler.
    ///
    /// - Parameters:
    ///     - request: An object conforming to `NetworkRequest`
    public func send<Model>(request: NetworkRequest) async throws -> Model where Model: Codable
    {
        let outgoingRequest = try NetworkUtility.buildRequest(serviceRequest: request, baseURL: settings.baseURL)
        let (data, urlResponse) = try await session.data(for: outgoingRequest)

        let response = try prepareServiceResponse(requestID: request.identifier,
                                                  data: data,
                                                  response: urlResponse,
                                                  originalError: nil)

        return try JSONDecoder().decode(Model.self, from: response.contents)
    }

    // MARK: - Helpers

    private func prepareServiceResponse(requestID: String,
                                        data: Data,
                                        response: URLResponse?,
                                        originalError: Error?) throws -> NetworkResponse
    {
        guard let receivedResponse = response
        else
        {
            if let receivedError = originalError
            {
                throw transform(receivedError as NSError, url: response?.url)
            }
            else
            {
                let failureMessage = "An invalid response from the server was received and no error was provided."
                let responseError = RequestError(.badResponse,
                                                 message: failureMessage,
                                                 statusCode: -1,
                                                 url: nil,
                                                 domain: ErrorDomain.server)
                throw responseError
            }
        }

        let serviceResponse: NetworkResponse

        if let httpResponse = receivedResponse as? HTTPURLResponse
        {
            serviceResponse = try handleResponse(httpResponse: httpResponse, data: data, requestID: requestID)
        }
        else
        {
            let failureMessage = "An invalid response was received from the server."
            let responseError = RequestError(.badResponse,
                                             message: failureMessage,
                                             statusCode: -1,
                                             url: nil,
                                             domain: ErrorDomain.server)
            throw responseError
        }

        return serviceResponse
    }

    private func handleResponse(httpResponse: HTTPURLResponse, data: Data, requestID: String) throws -> NetworkResponse
    {
        guard !(400 ..< 600).contains(httpResponse.statusCode)
        else
        {
            let errorKind: (kind: RequestError.ErrorKind, domain: String)

            switch httpResponse.statusCode
            {
                case 401:
                    errorKind = (.unauthorized, ErrorDomain.client)
                case 403:
                    errorKind = (.forbidden, ErrorDomain.client)
                case 400, 402, 404 ..< 500:
                    errorKind = (.badRequest, ErrorDomain.client)
                case 500 ..< 600:
                    errorKind = (.internalServerError, ErrorDomain.server)
                default:
                    errorKind = (.invalidHTTPStatusCode, ErrorDomain.server)
            }

            throw RequestError(errorKind.kind,
                               message: "",
                               statusCode: httpResponse.statusCode,
                               url: httpResponse.url,
                               domain: errorKind.domain)
        }

        let serviceResponse = Response(identifier: requestID, data: data, response: httpResponse)

        return serviceResponse
    }

    private func transform(_ error: NSError, url: URL?) -> RequestError
    {
        let kind: RequestError.ErrorKind

        switch error.code
        {
            case NSURLErrorBadURL,
                 NSURLErrorUnsupportedURL: kind = .invalidURL

            case NSURLErrorTimedOut: kind = .requestTimedOut

            case NSURLErrorAppTransportSecurityRequiresSecureConnection,
                 NSURLErrorCannotFindHost,
                 NSURLErrorCannotConnectToHost,
                 NSURLErrorNetworkConnectionLost,
                 NSURLErrorDNSLookupFailed,
                 NSURLErrorResourceUnavailable: kind = .connectivityIssue

            case NSURLErrorNotConnectedToInternet: kind = .noInternetConnectionAvailable

            case NSURLErrorBadServerResponse,
                 NSURLErrorZeroByteResource,
                 NSURLErrorCannotDecodeRawData,
                 NSURLErrorCannotDecodeContentData,
                 NSURLErrorCannotParseResponse: kind = .badResponse

            default: kind = .noInternetConnectionAvailable
        }

        return RequestError(kind,
                            message: error.localizedDescription,
                            statusCode: -1,
                            url: url,
                            domain: error.domain)
    }
}
