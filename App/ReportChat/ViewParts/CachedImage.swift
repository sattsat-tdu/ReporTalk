//
//  CachedImage.swift
//  ReportChat
//
//  Created by SATTSAT on 2024/10/12
//
//

import SwiftUI

struct CachedImage<Content: View>: View {
    
    @StateObject private var manager = CachedImageManager()
    let url: String
    @ViewBuilder let content: (AsyncImagePhase) -> Content
    
    var body: some View {
        Group {
            switch manager.currentState {
            case .loading:
                content(.empty)
            case .failed(let error):
                content(.failure(error))
            case .success(let image):
                content(.success(Image(uiImage: image)))
            default:
                content(.empty)
            }
        }
        .onAppear {
            Task {
                await manager.load(url)
            }
        }
    }
}

#Preview {
    CachedImage(url: "https://picsum.photos/300/200") { _ in
        EmptyView()
    }
}

extension CachedImage {
    enum CachedImageError: Error {
        case invalidData
    }
}

final class CachedImageManager: ObservableObject {
    @Published private(set) var currentState: CurrentState?
    
    private let imageRetriever = ImageRetriever()
    
    func load(_ imageUrl: String, cache: ImageCache = .shared) async {
        
        // メインスレッドでローディング状態に更新
        await MainActor.run {
            self.currentState = .loading
        }
        
        // キャッシュが存在する場合、キャッシュからUIImageを取得
        if let cachedImage = cache.object(forKey: imageUrl as NSString) {
            await MainActor.run {
                self.currentState = .success(image: cachedImage)
            }
            return
        }
        
        // 画像をネットワークから取得（バックグラウンドスレッド）
        do {
            let data = try await imageRetriever.fetch(imageUrl)
            if let image = UIImage(data: data) {
                // メインスレッドで成功状態に更新
                await MainActor.run {
                    self.currentState = .success(image: image)
                }
                // 取得したUIImageをキャッシュに保存
                cache.set(object: image, forKey: imageUrl as NSString)
            } else {
                // メインスレッドでエラー状態に更新
                await MainActor.run {
                    self.currentState = .failed(error: CachedImageError.invalidData)
                }
            }
        } catch {
            // メインスレッドでエラー状態に更新
            await MainActor.run {
                self.currentState = .failed(error: error)
            }
        }
    }
}

extension CachedImageManager {
    enum CurrentState {
        case loading
        case failed(error: Error)
        case success(image: UIImage)
    }
    
    enum CachedImageError: Error {
        case invalidData
    }
}

class ImageCache {
    typealias CacheType = NSCache<NSString, UIImage>
    
    static let shared = ImageCache()
    
    private init() {}
    
    private lazy var cache: CacheType = {
        let cache = CacheType()
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB
        return cache
    }()
    
    func object(forKey key: NSString) -> UIImage? {
        cache.object(forKey: key)
    }
    
    func set(object: UIImage, forKey key: NSString) {
        cache.setObject(object, forKey: key)
    }
}

struct ImageRetriever {
    func fetch(_ imageUrl: String) async throws -> Data {
        guard let url = URL(string: imageUrl) else {
            throw RetriverError.invalidUrl
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    }
}

private extension ImageRetriever {
    enum RetriverError: Error {
        case invalidUrl
    }
}
