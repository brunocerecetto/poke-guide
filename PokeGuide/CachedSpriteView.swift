//
//  CachedSpriteView.swift
//  PokeGuide
//
//  Cache de sprites en disco + vista reutilizable.
//

import SwiftUI
import UIKit

// MARK: - Sprite Cache

final class SpriteCache {
    static let shared = SpriteCache()

    private let fileManager = FileManager.default
    private let cacheDir: URL
    private let session: URLSession

    private init() {
        let caches = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        cacheDir = caches.appendingPathComponent("sprites", isDirectory: true)
        try? fileManager.createDirectory(at: cacheDir, withIntermediateDirectories: true)

        let config = URLSessionConfiguration.default
        config.urlCache = URLCache(memoryCapacity: 10_000_000, diskCapacity: 50_000_000)
        session = URLSession(configuration: config)
    }

    func image(for url: URL) async -> UIImage? {
        let key = url.lastPathComponent
        let fileURL = cacheDir.appendingPathComponent(key)

        if let data = try? Data(contentsOf: fileURL), let img = UIImage(data: data) {
            return img
        }

        guard let (data, _) = try? await session.data(from: url),
              let img = UIImage(data: data) else {
            return nil
        }

        try? data.write(to: fileURL, options: .atomic)
        return img
    }
}

// MARK: - Cached Sprite View

struct CachedSpriteView: View {
    let url: URL?
    let size: CGFloat

    @State private var image: UIImage?
    @State private var failed = false

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
            } else if failed {
                Image(systemName: "questionmark.circle.fill")
                    .font(.system(size: size * 0.45))
                    .foregroundColor(.onSurfaceVariant)
            } else {
                ProgressView()
            }
        }
        .frame(width: size, height: size)
        .task(id: url) {
            guard let url else { failed = true; return }
            if let img = await SpriteCache.shared.image(for: url) {
                image = img
            } else {
                failed = true
            }
        }
    }
}
