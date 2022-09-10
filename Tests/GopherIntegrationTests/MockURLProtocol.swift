//
//  MockURLProtocol.swift
//  
//  See LICENSE for more details.
//  Copyright © 2016-2022 Farhan Ahmed. All rights reserved.
//

import Foundation
import XCTest

final class MockURLProtocol: URLProtocol
{
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler
        else {
            XCTFail("Received unexpected request with no handler set")

            return
        }

        do
        {
            let (response, data) = try handler(request)

            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        }
        catch
        {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading()
    {}
}
