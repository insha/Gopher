//
//  Profiler.swift
//
//  See LICENSE for more details.
//  Copyright © 2016-2022 Farhan Ahmed. All rights reserved.
//

import Foundation

/// A data container for the entry that is passed
/// to the profiler.
public struct ProfilerEntry
{
    public var request: URLRequest
    public var response: HTTPURLResponse
    public var timeSent: Date
    public var timeReceived: Date
    public var content: Data?

    public var duration: Double
    {
        return -timeSent.timeIntervalSince(timeReceived)
    }

    public var roundTrip: String
    {
        return requestDuration(duration: duration)
    }

    public func logRequest(_ shouldShowContents: Bool = false) -> String
    {
        let rawRequestBody: String

        if shouldShowContents
        {
            rawRequestBody = String(data: request.httpBody ?? Data(), encoding: .utf8) ?? ""
        }
        else
        {
            rawRequestBody = "<Redacted>"
        }

        let profilerLog = """
        ====
        Request: (\(request.httpMethod ?? "N/A")) \(request.url?.absoluteString ?? "N/A")
        Headers: \(request.allHTTPHeaderFields ?? [:])
        Body   : \(rawRequestBody)
        """

        return profilerLog
    }

    public func logResponse(_ shouldShowContents: Bool = false) -> String
    {
        let rawContentString: String

        if shouldShowContents
        {
            rawContentString = String(data: content ?? Data(), encoding: .utf8) ?? "N/A"
        }
        else
        {
            rawContentString = "<Redacted>"
        }

        let profilerLog = """
        ----
        Response [\(response.mimeType ?? "N/A") : \(response.statusCode) : \(roundTrip) : \(response.expectedContentLength) bytes]:
        \(rawContentString)\n\n
        """

        return profilerLog
    }

    private func requestDuration(duration: TimeInterval) -> String
    {
        var roundTrip = "0s"

        switch duration
        {
            case 0.0: roundTrip = "0s"
            case 0.0 ..< 1.0: roundTrip = String(format: "%.0fms", duration * 1000)
            case 1.0 ..< 10.0: roundTrip = String(format: "%.2fs", duration)
            default: roundTrip = String(format: "%.1fs", duration)
        }

        return roundTrip
    }
}

/// A type that can profile the request/response
/// roundtrip times and creates a formatted output
/// with the information.
public final class Profiler
{
    public var enabled: Bool
    public var shouldShowRequestContents: Bool
    public var shouldShowResponseContents: Bool

    public init()
    {
        enabled = true
        shouldShowRequestContents = false
        shouldShowResponseContents = true
    }

    public func profile(entry: ProfilerEntry) -> String
    {
        var profilerLog: String

        if enabled
        {
            profilerLog = entry.logRequest(shouldShowRequestContents)
            profilerLog += entry.logResponse(shouldShowResponseContents)
        }
        else
        {
            profilerLog = ""
        }

        return profilerLog
    }
}
