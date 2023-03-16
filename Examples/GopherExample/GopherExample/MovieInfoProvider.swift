//
//  MovieInfoProvider.swift
//  GopherExample
//
//  Created by Farhan Ahmed on 1/30/23.
//

import Foundation

final class MovieInfoProvider: ObservableObject
{
    @Published
    private(set) var movies: [Movie] = []

    private let service: NetworkService

    init(service: NetworkService)
    {
        self.service = service
    }
}

extension MovieInfoProvider
{
    func popular() async throws
    {
        _ = URL(string: "https://road.to.nowhere")!
        let result: MovieResult = try await service.invoke(resource: .popular)

        DispatchQueue.main.async
        {
            self.movies = result.results
        }
    }
}

struct MovieResult: Codable
{
    let results: [Movie]
}

struct Movie: Codable, Hashable, Identifiable
{
    let id: Int
    let title: String
    let poster_path: URL
    let adult: Bool
    let overview: String
    let release_date: Date
    let genre_ids: [Int]
    let original_title: String
    let original_language: String
    let backdrop_path: URL
    let popularity: Double
    let vote_count: Int
    let video: Bool
    let vote_average: Double
}

struct AuthenticationToken: Codable
{
    let success: Bool
    let expires_at: String
    let request_token: String
}

struct SessionIdentifier: Codable
{
    let success: Bool
    let session_id: String
}
