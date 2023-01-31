//
//  Response.swift
//
//  See LICENSE for more details.
//  Copyright © 2016-2022 Farhan Ahmed. All rights reserved.
//

import Foundation

struct Response: NetworkResponse
{
    let requestIdentifier: String
    let response: HTTPURLResponse
    let error: NetworkError?
    let contents: Data

    init(identifier: String,
         data: Data,
         response: HTTPURLResponse,
         error: NetworkError? = nil)
    {
        requestIdentifier = identifier
        self.response = response
        self.error = error
        contents = data
    }
}
