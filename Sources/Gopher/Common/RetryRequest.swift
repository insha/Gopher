//
//  RetryRequest.swift
//
//  See LICENSE for more details.
//  Copyright © 2016-2022 Farhan Ahmed. All rights reserved.
//

import Foundation

/// This object is used for configuring an `NetworkRequest` and
/// then retrying that request upon failure.
///
/// The criteria for the retry varies and it is usually contained
/// within the the object conforming to the `NetworkService` protocol.
final class RetryRequest
{
    public typealias RetryBlock = () -> Void

    public var retryDelay: TimeInterval = 3
    public var maximumRetries = 5

    private(set) var request: NetworkRequest
    private(set) var retryAttempt = 0
    private var retryBlock: RetryBlock?

    init(request: NetworkRequest)
    {
        self.request = request
    }

    func configureRequestRetry(retryBlock: @escaping RetryBlock)
    {
        if self.retryBlock == nil
        {
            self.retryBlock = retryBlock
        }
        else
        {
            // Nothing to do, we already have a retry block
        }
    }

    func retry() throws
    {
        guard let block = retryBlock, shouldRetryRequest()
        else
        {
            if !shouldRetryRequest()
            {
                let failureMessage = "The request was tried and failed maximum number of times."
                let maxRetriesError = RequestError(.maximumRetriesReached,
                                                   message: failureMessage,
                                                   statusCode: -1,
                                                   url: request.url,
                                                   domain: ErrorDomain.server)
                throw maxRetriesError
            }

            return
        }

        block()
        retryAttempt += 1
    }

    func shouldRetryRequest() -> Bool
    {
        return retryAttempt < maximumRetries
    }
}
