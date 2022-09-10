//
//  Configuration.swift
//  
//  See LICENSE for more details.
//  Copyright © 2016-2022 Farhan Ahmed. All rights reserved.
//

import Foundation

/// A data container for the networking configuration.
public struct Configuration
{
    public var baseURL: URL
    public var serviceName = ""
    public var userAgent = ""
    public var profileNetworkActivity = false
    public var requestTimeoutInterval: TimeInterval = 60
    public var resourceTimeoutInterval: TimeInterval = 60.0 * 60.0 * 24.0 * 7.0 // 7 days

    private enum DefaultValue
    {
        static let userAgent = ""
        static let serviceName = "com.themacronaut.gopher.network-service"
    }

    public init(url: URL,
                name: String = "",
                userAgent: String = "")
    {
        baseURL = url
        serviceName = name.isEmpty ? DefaultValue.serviceName : name
        self.userAgent = userAgent.isEmpty ? DefaultValue.userAgent : userAgent
    }

    static func `default`(with url: URL) -> Configuration
    {
        Configuration(url: url)
    }
}
