//
//  GopherIntegrationTests.swift
//
//  See LICENSE for more details.
//  Copyright © 2016-2022 Farhan Ahmed. All rights reserved.
//

@testable import Gopher
import XCTest

final class GopherIntegrationTests: XCTestCase
{
    private var service: Gopher!

    override func setUp() async throws
    {
        guard let baseURL = URL(string: "https://road.to.nowhere")
        else
        {
            throw URLError(.badURL)
        }

        let serviceConfig = Configuration.default(with: baseURL)
        let config = URLSessionConfiguration.ephemeral

        config.protocolClasses = [MockURLProtocol.self]

        service = Gopher(provider: DefaultNetworkProvider(config), configuration: serviceConfig)
    }

    func testCreatingARequest() async throws
    {
        // Set up
        struct Profile: Codable
        {
            let name: String
        }

        let sample = Profile(name: "Farhan")
        let mockData = try JSONEncoder().encode(sample)

        MockURLProtocol.requestHandler = { _ in
            (HTTPURLResponse(), mockData)
        }

        // Test
        let request = RequestBuilder()
            .resource("/")
            .using(.get)
            .header(Header.contentType, value: MimeType.json)
            .build()

        let result: Profile = try await service.send(request: request)

        XCTAssertEqual(result.name, "Farhan")
    }
}
