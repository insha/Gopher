//
//  ContentView.swift
//  GopherExample
//
//  Created by Farhan Ahmed on 1/30/23.
//

import SwiftUI

struct ContentView: View
{
    @ObservedObject var provider: MovieInfoProvider

    var body: some View
    {
        List
        {
            ForEach(provider.movies, id: \.self)
            { movie in
                VStack
                {
                    Text(movie.title)
                }
            }
        }
        .task {
            do
            {
                try await provider.popular()
            }
            catch
            {
                debugPrint(error)
            }
        }
    }
}


import Gopher

struct ContentView_Previews: PreviewProvider
{
    static var provider: MovieInfoProvider
    {
        return MovieInfoProvider(service: create_network_service())
    }

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

    static var previews: some View
    {
        ContentView(provider: provider)
    }
}
