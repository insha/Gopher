//
//  NetworkResponse.swift
//
//  See LICENSE for more details.
//  Copyright © 2016-2022 Farhan Ahmed. All rights reserved.
//

import Foundation

public protocol NetworkResponse
{
    var requestIdentifier: String { get }
    var response: HTTPURLResponse { get }
    var error: NetworkError? { get }
    var contents: Data { get }
}
