//
//  DefaultNetworkProvider.swift
//
//  See LICENSE for more details.
//  Copyright © 2016-2022 Farhan Ahmed. All rights reserved.
//

import Foundation

protocol NetworkProviderDelegate: AnyObject {}

public final class DefaultNetworkProvider: NSObject
{
    private let serviceQueueName = "com.themacronaut.gopher.session-queue"

    private var session: URLSession!
    private var networkSessionQueue: OperationQueue
    private var serverTrustValidator: ServerTrustValidator?
    private var serverTrustHandler: GopherTrustHandler?
    private var providerDelegate: NetworkProviderDelegate?

    init(_ configuration: URLSessionConfiguration,
         delegate: NetworkProviderDelegate? = nil,
         trustValidator: ServerTrustValidator? = nil,
         trustHandler: GopherTrustHandler? = nil)
    {
        providerDelegate = delegate
        serverTrustValidator = trustValidator
        serverTrustHandler = trustHandler
        networkSessionQueue = OperationQueue()

        networkSessionQueue.name = serviceQueueName
        networkSessionQueue.maxConcurrentOperationCount = 4

        super.init()

        session = URLSession(configuration: configuration,
                             delegate: self,
                             delegateQueue: networkSessionQueue)
    }
}

// MARK: - Protocol Conformance

extension DefaultNetworkProvider: NetworkProvider
{
    public func data(for request: URLRequest) async throws -> (Data, URLResponse)
    {
        try await session.data(for: request)
    }

    public func flush() async
    {
        await session.flush()
    }

    public func invalidateAndCancel()
    {
        session.invalidateAndCancel()

        networkSessionQueue.cancelAllOperations()
    }

    public func finishTasksAndInvalidate()
    {
        session.finishTasksAndInvalidate()
    }

    private func cancelTasks()
    {
        session.getTasksWithCompletionHandler
        { dataTasks, uploadTasks, downloadTasks in
            self.tasksToCancel(tasks: dataTasks)
            self.tasksToCancel(tasks: uploadTasks)
            self.tasksToCancel(tasks: downloadTasks)
        }
    }

    private func tasksToCancel(tasks: [URLSessionTask])
    {
        for task in tasks where task.state != .completed
        {
            task.cancel()
        }
    }
}

// MARK: - URLSession delegates

extension DefaultNetworkProvider: URLSessionDelegate
{
    public func urlSession(_: URLSession,
                           didReceive challenge: URLAuthenticationChallenge,
                           completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
    {
        guard let serverTrust = challenge.protectionSpace.serverTrust,
              let trustHandler = serverTrustHandler,
              let trustValidator = serverTrustValidator
        else
        {
            // Nothing to do because we were not challenged or
            // we don't have a handler that can handle the challenge
            // therefore we will ignore the challenge.
            completionHandler(.performDefaultHandling, nil)
            return
        }

        let hostname = challenge.protectionSpace.host
        let result = trustValidator.validateServerTrust(serverTrust: serverTrust, hostName: hostname)

        if result == .blockConnection
        {
            trustHandler(hostname, completionHandler)
        }
        else
        {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}
