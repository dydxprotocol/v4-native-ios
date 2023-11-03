//
//  CachedFileLoader.swift
//  Utilities
//
//  Created by Rui Huang on 8/30/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import Foundation

final public class CachedFileLoader: SingletonProtocol {
    public static let shared: CachedFileLoader = CachedFileLoader()
    
    public func loadString(filePath: String, url: String?, completion: @escaping ((String?) -> Void)) {
        loadData(filePath: filePath, url: url) { (data: Data?) in
            if let data = data, let string = String(data: data, encoding: .utf8) {
                completion(string)
            }
        }
    }
    
    public func loadData(filePath: String, url: String?, completion: @escaping ((Data?) -> Void)) {
        if let cachedFile = cachedFilePath(filePath: filePath),
           let cachedData = try? Data(contentsOf: cachedFile) {
            completion(cachedData)
        } else {
            let bundledFile = Bundle.main.bundleURL.appendingPathComponent(filePath)
            let bundledData = try? Data(contentsOf: bundledFile)
            completion(bundledData)
        }
        
        if let url = url, let url = URL(string: url) {
            URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                guard let data = data, error == nil else {
                    return
                }
                
                if let cachedFile = self?.cachedFilePath(filePath: filePath) {
                    self?.writeToFile(fileUrl: cachedFile, data: data)
                }
                completion(data)
            }
            .resume()
        }
    }
    
    private func writeToFile(fileUrl: URL, data: Data) {
        do {
            let filePath = fileUrl.path
            _ = Directory.ensure(filePath.stringByDeletingLastPathComponent)
            File.delete(filePath)
            try data.write(to: fileUrl)
        } catch {
            Console.shared.log("CachedFileLoader: unable to write file \(fileUrl): \(error)")
        }
    }
    
    private func cachedFilePath(filePath: String) -> URL? {
        do {
            let cacheDirectory = try FileManager.default.url(for: .documentDirectory,
                                                             in: .userDomainMask,
                                                             appropriateFor: nil,
                                                             create: true)
            return cacheDirectory.appendingPathComponent(filePath)
        } catch {
            Console.shared.log("CachedFileLoader: Error getting cached file path: \(error)")
            return nil
        }
    }
}
