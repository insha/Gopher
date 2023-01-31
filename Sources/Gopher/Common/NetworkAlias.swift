//
//  NetworkAlias.swift
//
//  See LICENSE for more details.
//  Copyright © 2016-2022 Farhan Ahmed. All rights reserved.
//

import Foundation

public typealias GopherContent = [String: Any]
public typealias GopherHeader = [String: String]
public typealias GopherQueryParameter = [String: Any]
public typealias GopherTrustCompletion = (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
public typealias GopherTrustHandler = (_ hostname: String, _ completion: @escaping GopherTrustCompletion) -> Void
