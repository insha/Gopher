//
//  NetworkEnumerations.swift
//
//  See LICENSE for more details.
//  Copyright © 2016-2022 Farhan Ahmed. All rights reserved.
//

import Foundation

public enum ErrorDomain
{
    static let client = "com.themacronaut.gopher.error-domain.client"
    static let server = "com.themacronaut.gopher.error-domain.server"
}

public enum DataFormat
{
    case json
    case form
}

public enum HTTPMethod: String
{
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case head = "HEAD"
    case patch = "PATCH"
    case options = "OPTIONS"
}

public enum MimeType
{
    public static let json = "application/json"
    public static let binaryData = "application/x-www-form-urlencoded"
    public static let pdf = "application/pdf"
    public static let htmlForm = "multipart/form-data"
    public static let textHTML = "text/html"
    public static let png = "image/png"
    public static let jpeg = "image/jpeg"
    public static let gif = "image/gif"
}

public enum Header: String
{
    case accept = "Accept"
    case acceptCharset = "Accept-Charset"
    case acceptEncoding = "Accept-Encoding"
    case acceptLanguage = "Accept-Language"
    case acceptDatetime = "Accept-Datetime"
    case authorization = "Authorization"
    case cacheControl = "Cache-Control"
    case connection = "Connection"
    case cookie = "Cookie"
    case contentLength = "Content-Length"
    case contentMD5 = "Content-MD5"
    case contentType = "Content-Type"
    case date = "Date"
    case expect = "Expect"
    case forwarded = "Forwarded"
    case from = "From"
    case host = "Host"
    case ifMatch = "If-Match"
    case ifModifiedSince = "If-Modified-Since"
    case ifNoneMatch = "If-None-Match"
    case ifRange = "If-Range"
    case ifUnmodifiedSince = "If-Unmodified-Since"
    case maxForwards = "Max-Forwards"
    case origin = "Origin"
    case pragma = "Pragma"
    case proxyAuthorization = "Proxy-Authorization"
    case range = "Range"
    case referer = "Referer"
    case transferEncoding = "TE"
    case userAgent = "User-Agent"
    case upgrade = "Upgrade"
    case via = "Via"
    case warning = "Warning"
}
