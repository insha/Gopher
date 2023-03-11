//
//  NetworkUtility.swift
//
//  See LICENSE for more details.
//  Copyright © 2016-2022 Farhan Ahmed. All rights reserved.
//

import Foundation

public enum NetworkUtility
{
    private static func buildURL(endpoint: String, baseURL: URL) throws -> URLComponents
    {
        guard let validURL = URL(string: endpoint, relativeTo: baseURL),
              let urlComponents = URLComponents(url: validURL, resolvingAgainstBaseURL: true)
        else
        {
            let message = "An Invalid URL was provided: \(baseURL.absoluteString) — \(endpoint)"
            let requestError = RequestError(.invalidURL,
                                            message: message,
                                            statusCode: -1,
                                            url: nil,
                                            domain: ErrorDomain.client)
            throw requestError
        }

        return urlComponents
    }

    /// Create an instance of the `URLRequest` type.
    ///
    /// - Parameters:
    ///     - serviceRequest: An object conforming to the `ServiceRequest` type.
    ///     - baseURL: The base URL of the remote service.
    static func buildRequest(serviceRequest: NetworkRequest, baseURL: URL) throws -> URLRequest
    {
        let urlComponents = try buildURL(endpoint: serviceRequest.endpoint, baseURL: baseURL)

        guard let url = urlComponents.url
        else
        {
            throw RequestError(.invalidURL,
                               message: "",
                               statusCode: -1,
                               url: nil,
                               domain: ErrorDomain.client)
        }

        var components = urlComponents
        var request = URLRequest(url: url)

        request.httpMethod = serviceRequest.method.rawValue

        if !serviceRequest.parameters.isEmpty
        {
            components.queryItems = serviceRequest.parameters

            request.url = components.url
        }
        else
        {
            // Nothing else needs to be done.
        }

        if serviceRequest.method != HTTPMethod.get
        {
            switch serviceRequest.dataFormat
            {
                case .json:
                    request.httpBody = dataFromDictionary(dict: serviceRequest.body)
                case .form:
                    request.httpBody = generateFormData(parameters: serviceRequest.body)
            }

            debugPrint("-> Request body format: \(serviceRequest.dataFormat)")
        }

        for (key, value) in serviceRequest.headers
        {
            request.addValue(value, forHTTPHeaderField: key)
        }

        return request
    }

    /**
     This will parse an NSDictionary and convert it into JSON, and ultimately into an NSData representation.
     - Parameters:
     - dict:    NSDictionary with data that will need to be sent with the HTTP request.
     - Returns: An NSData containing parsed JSON data from the dictionary, otherwise nil.
     */
    static func dataFromDictionary(dict: GopherContent?) -> Data?
    {
        var prepData: Data?

        guard let payload = dict
        else
        {
            return prepData
        }

        do
        {
            let dataPayload = try JSONSerialization.data(withJSONObject: payload,
                                                         options: JSONSerialization.WritingOptions.prettyPrinted)

            prepData = dataPayload
        }
        catch
        {
            NSLog("Error encountered while converting response data. \(error)")
        }

        return prepData
    }

    static func generateFormData(parameters: GopherContent) -> Data?
    {
        var formData: Data?

        guard !parameters.isEmpty
        else
        {
            return formData
        }

        var payload: [String] = []

        for (key, value) in parameters
        {
            if let encodedValue = "\(key)=\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            {
                payload.append(encodedValue)
            }
            else
            {
                debugPrint("-> Could not URL encode parameter: \(key) - \(value)")
            }
        }

        formData = payload.joined(separator: "&").data(using: .utf8)

        return formData
    }

    static func handleDownloadedFile(downloadLocationURL: URL, response: HTTPURLResponse) -> URL?
    {
        var downloadedFileURL: URL?
        let fileManager = FileManager.default
        let tempDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory())
        let filename = response.suggestedFilename ?? UUID().uuidString
        let destinationPath = tempDirectoryURL.appendingPathComponent(filename)
        let fileAlreadyExists = fileManager.fileExists(atPath: destinationPath.absoluteString)

        if fileAlreadyExists == false
        {
            do
            {
                try fileManager.moveItem(at: downloadLocationURL, to: destinationPath)

                downloadedFileURL = destinationPath
            }
            catch
            {
                NSLog("Could not move file from \(String(describing: downloadedFileURL?.absoluteString)) to \(destinationPath.absoluteString)")
            }
        }
        else
        {
            downloadedFileURL = destinationPath
        }

        return downloadedFileURL
    }

    public static func decodeJSON<T: Codable>(type _: T.Type, from data: Data) -> Result<T, Error>
    {
        let result: Result<T, Error>

        do
        {
            let decoder = JSONDecoder()
            let payload = try decoder.decode(T.self, from: data)

            result = .success(payload)
        }
        catch
        {
            result = .failure(error)
        }

        return result
    }
}
