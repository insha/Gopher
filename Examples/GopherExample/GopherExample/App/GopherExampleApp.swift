//
//  GopherExampleApp.swift
//  GopherExample
//
//  Created by Farhan Ahmed on 1/30/23.
//

import Gopher
import SwiftUI

@main
struct GopherExampleApp: App
{
    private var movieService = Self.create_network_service()

    var body: some Scene
    {
        WindowGroup
        {
            ContentView(provider: MovieInfoProvider(service: movieService))
        }
    }
}

extension GopherExampleApp
{
    static func create_network_service() -> NetworkService
    {
        guard let base_url = URL(string: NetworkService.TheMovieDatabase.host)
        else
        {
            fatalError("=> This should never happen! And if does, it is a programing error!")
        }

        let config = Configuration(url: base_url)
        let network_provider = DefaultNetworkProvider(URLSessionConfiguration.default)
        let gopher = Gopher(provider: network_provider, configuration: config)

        return NetworkService(service: gopher)
    }
}
