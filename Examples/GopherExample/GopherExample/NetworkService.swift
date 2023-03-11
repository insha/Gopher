//
//  NetworkService.swift
//  GopherExample
//
//  Created by Farhan Ahmed on 1/30/23.
//

import Foundation
import Gopher

final class NetworkService
{
    private let service: Gopher
    private var download_queue: DownloadQueue

    init(service: Gopher)
    {
        self.service = service
        self.download_queue = DownloadQueue()
    }

    func invoke<Model>(resource: TheMovieDatabase,
                       resource_id: String = DefaultValue.empty_string,
                       parameters: GopherQueryParameter = []) async throws -> Model where Model: Codable
    {
        return try await service.send(request: resource.request(resource_id: resource_id, parameters: parameters))
    }

    func enqueue(url: URL)
    {
        download_queue.add(url: url)
    }
}

// Remote service interface

extension NetworkService
{
    enum TheMovieDatabase
    {
        static let host = "https://api.themoviedb.org/3/"

        private static let api_key = "c5eaa39e85715fd9ab44f935303e4edf"

        private enum Header
        {
            static let api_key  = "api_key"
            static let language = "language"
        }

        case auth_temp_token
        case auth_new_session
        case authenticate
        case popular
        case popular_persons
        case topRated
        case upcoming
        case nowPlaying
        case trending
        case movieDetail
        case personDetail
        case credits
        case review
        case recommended
        case similar
        case person_movie_credits
        case personImages
        case searchMovie
        case searchKeyword
        case searchPerson
        case genres
        case discover

        private func prepare_resource(_ identifier: String = DefaultValue.empty_string) -> (resource: String,
                                                                                            method: HTTPMethod)
        {
            switch self
            {
                case .auth_temp_token:
                    return (resource: "authentication/token/new", method: HTTPMethod.get)
                case .auth_new_session:
                    return (resource: "authentication/session/new", method: HTTPMethod.post)
                case .authenticate:
                    return (resource: "authenticate/:id", method: HTTPMethod.get)
                case .popular:
                    return (resource: "movie/popular", method: HTTPMethod.get)
                case .popular_persons:
                    return (resource: "person/popular", method: HTTPMethod.get)
                case .topRated:
                    return (resource: "movie/top_rated", method: HTTPMethod.get)
                case .upcoming:
                    return (resource: "movie/upcoming", method: HTTPMethod.get)
                case .nowPlaying:
                    return (resource: "movie/now_playing", method: HTTPMethod.get)
                case .trending:
                    return (resource: "trending/movie/day", method: HTTPMethod.get)
                case .movieDetail:
                    let prepared_value = Self.prepare_endpoint(with: identifier, resource: "movie/:id")

                    return (resource: prepared_value, method: HTTPMethod.get)
                case .personDetail:
                    let prepared_value = Self.prepare_endpoint(with: identifier, resource: "person/:id")

                    return (resource: prepared_value, method: HTTPMethod.get)
                case .credits:
                    let prepared_value = Self.prepare_endpoint(with: identifier, resource: "movie/:id/credits")

                    return (resource: prepared_value, method: HTTPMethod.get)
                case .review:
                    let prepared_value = Self.prepare_endpoint(with: identifier, resource: "movie/:id/reviews")

                    return (resource: prepared_value, method: HTTPMethod.get)
                case .recommended:
                    let prepared_value = Self.prepare_endpoint(with: identifier, resource: "movie/:id/recommendations")

                    return (resource: prepared_value, method: HTTPMethod.get)
                case .similar:
                    let prepared_value = Self.prepare_endpoint(with: identifier, resource: "movie/:id/similar")

                    return (resource: prepared_value, method: HTTPMethod.get)
                case .person_movie_credits:
                    let prepared_value = Self.prepare_endpoint(with: identifier, resource: "person/:id/movie_credits")

                    return (resource: prepared_value, method: HTTPMethod.get)
                case .personImages:
                    let prepared_value = Self.prepare_endpoint(with: identifier, resource: "person/:id/images")

                    return (resource: prepared_value, method: HTTPMethod.get)
                case .searchMovie:
                    return (resource: "search/movie", method: HTTPMethod.get)
                case .searchKeyword:
                    return (resource: "search/keyword", method: HTTPMethod.get)
                case .searchPerson:
                    return (resource: "search/person", method: HTTPMethod.get)
                case .genres:
                    return (resource: "genre/movie/list", method: HTTPMethod.get)
                case .discover:
                    return (resource: "discover/movie", method: HTTPMethod.get)
            }
        }

        static private func prepare_endpoint(with identifier: String = DefaultValue.empty_string,
                                             resource: String) -> String
        {
            let endpoint: String

            if !identifier.isEmpty, resource.contains(":id")
            {
                endpoint = resource.replacingOccurrences(of: ":id", with: identifier)
            }
            else
            {
                endpoint = resource
            }

            return endpoint
        }

        func request(resource_id: String = DefaultValue.empty_string, parameters: GopherQueryParameter = []) -> Request
        {
            let resource = prepare_resource(resource_id)
            let reqBuilder = RequestBuilder()
                .resource(resource.resource)
                .using(resource.method)
                .parameters(parameters)
                .parameter(Header.api_key, value: Self.api_key)
                .parameter(Header.language, value: Locale.current.identifier)
                .date_decoding(.formatted(DateFormatter.iso8601_short_date))

            return reqBuilder.build()
        }
    }
}

enum DefaultValue
{
    static let empty_string = ""
}

extension DateFormatter
{
    static let iso8601_short_date: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}
