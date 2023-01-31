//
//  NetworkProvider.swift
//
//  See LICENSE for more details.
//  Copyright © 2016-2022 Farhan Ahmed. All rights reserved.
//

import Foundation

public protocol NetworkProvider
{
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
    func flush() async
    func invalidateAndCancel()
    func finishTasksAndInvalidate()
}
