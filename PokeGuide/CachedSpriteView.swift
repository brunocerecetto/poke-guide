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

    /// Maximum number of cached sprite files before eviction.
    private let maxEntries = 1500

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
        evictIfNeeded()
        return img
    }

    /// Remove oldest cached files when count exceeds maxEntries.
    private func evictIfNeeded() {
        guard let files = try? fileManager.contentsOfDirectory(
            at: cacheDir,
            includingPropertiesForKeys: [.contentModificationDateKey],
            options: .skipsHiddenFiles
        ), files.count > maxEntries else { return }

        let sorted = files.sorted {
            let d0 = (try? $0.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? .distantPast
            let d1 = (try? $1.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? .distantPast
            return d0 < d1
        }

        let toRemove = sorted.prefix(files.count - maxEntries)
        for file in toRemove {
            try? fileManager.removeItem(at: file)
        }
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
