//
//  DownloadQueue.swift
//  GopherExample
//
//  Created by Farhan Ahmed on 1/31/23.
//

import UIKit

final class DownloadQueue
{
    enum Error: Swift.Error
    {
        case Empty
    }

    var count: Int
    {
        queue.count
    }

    private var queue: [DownloadItem] = []

    func add(url: URL, download_location _: URL? = nil)
    {
        queue.append(DownloadItem(url: url))
    }

    func remove(url: URL)
    {
        queue.removeAll(where: { $0.url == url })
    }

    func clear()
    {
        queue.forEach
        { item in
            switch item.status
            {
                case .in_progress:
                    item.cancel()
                case .completed:
                    // remove the local file
                    break
                default:
                    // Nothing else needs to be done
                    // for other variants.
                    break
            }
        }

        queue.removeAll()
    }

    func fetch() async throws -> UIImage
    {
        var item = try pop()

        item.status = .in_progress

        let result = try await item.task.value

        item.status = .completed(local_url: result.local_url)

        queue.append(item)

        return result.image
    }

    private func pop() throws -> DownloadItem
    {
        guard !queue.isEmpty
        else
        {
            throw Error.empty
        }

        return queue.removeFirst()
    }

    private func peek() -> DownloadItem?
    {
        return queue.first
    }
}

extension DownloadQueue
{
    struct DownloadItem
    {
        enum Status
        {
            case queued
            case in_progress
            case completed(local_url: URL)
            case paused
            case failed(error: Swift.Error)
        }

        enum Error: Swift.Error
        {
            case loading_image(request: URLRequest)
            case generating_local_url(request: URLRequest)
        }

        let url: URL
        var status: Status

        private(set) var task: Task<(local_url: URL, image: UIImage), Swift.Error>

        private let max_retries: Int
        private let download_location: URL?

        init(url: URL, status: Status = .queued, max_retries: Int = 0, download_location: URL? = nil)
        {
            self.url = url
            self.status = status
            self.max_retries = max_retries
            self.download_location = download_location

            task = Task
            {
                let request = URLRequest(url: url)
                let (image_data, _) = try await URLSession.shared.data(for: request)

                if let image = UIImage(data: image_data)
                {
                    let local_url = try Self.persist(image, for: request)

                    return (local_url, image)
                }
                else
                {
                    throw Error.loading_image(request: request)
                }
            }
        }

        func cancel()
        {
            task.cancel()
        }

        static func persist(_ image: UIImage, for request: URLRequest) throws -> URL
        {
            guard let url = fileName(for: request),
                  let data = image.jpegData(compressionQuality: 0.8)
            else
            {
                throw Error.generating_local_url(request: request)
            }

            try data.write(to: url)

            return url
        }

        private static func imageFromFileSystem(for request: URLRequest) throws -> UIImage?
        {
            guard let url = fileName(for: request)
            else
            {
                throw Error.generating_local_url(request: request)
            }

            let data = try Data(contentsOf: url)

            return UIImage(data: data)
        }

        private static func fileName(for urlRequest: URLRequest) -> URL?
        {
            guard let fileName = urlRequest.url?.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
                  let applicationSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            else
            {
                return nil
            }

            return applicationSupport.appendingPathComponent(fileName)
        }
    }
}

extension DownloadQueue.DownloadItem: Hashable
{
    static func == (lhs: DownloadQueue.DownloadItem, rhs: DownloadQueue.DownloadItem) -> Bool
    {
        lhs.url == rhs.url
    }

    func hash(into hasher: inout Hasher)
    {
        hasher.combine(url)
    }
}
