//
//  ImageCacheManager.swift
//  Friendzi
//
//  Created by Future Soul Co on 25/06/2016.
//  Copyright © 2016 KrazyLabs LLC. All rights reserved.
//

import Foundation
import AlamofireImage

class ImageCacheManager: NSObject {
    
    static let sharedManager = ImageCacheManager()
    
    lazy var imageDownloadQueue: dispatch_queue_t = {
        dispatch_queue_create("com.NFImageDownloadQueue.background", DISPATCH_QUEUE_SERIAL)
    }()
    
    private lazy var imageRequestCache: AutoPurgingImageCache = {
        AutoPurgingImageCache(memoryCapacity: 150 * 1024 * 1024, preferredMemoryUsageAfterPurge: 60 * 1024 * 1024)
    }()
    
    private lazy var imageDownloader: ImageDownloader = {
        ImageDownloader(configuration: ImageDownloader.defaultURLSessionConfiguration(), downloadPrioritization: .LIFO, maximumActiveDownloads: 4, imageCache: self.imageRequestCache)
    }()
    
    /**
     * Asynchronously download and cache image from a requested URL using AlamofireImage configuration
     */
    func downloadImage(requestURL: NSURL, completion: ImageDownloader.CompletionHandler? = nil) -> RequestReceipt? {
        let request = NSURLRequest(URL: requestURL)
        
        return imageDownloader.downloadImage(URLRequest: request, completion: completion)
    }
    
    /**
     * Asynchronously download and cache image from a requested URL using AlamofireImage configuration with progress handler
     */
    func downloadImageWithProgress(requestURL: NSURL, progress: ImageDownloader.ProgressHandler?, completion: ImageDownloader.CompletionHandler?) -> RequestReceipt? {
        let request = NSURLRequest(URL: requestURL)
        
        return imageDownloader.downloadImage(URLRequest: request, progress: progress, completion: completion)
    }
    
    /**
     * Check image if is in cache
     */
    func checkForImageContentInCacheStorage(requestURL: NSURL) -> UIImage? {
        
        let request = NSURLRequest(URL: requestURL)
        return imageRequestCache.imageForRequest(request, withAdditionalIdentifier: nil)
    }
    
}