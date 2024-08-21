//
//  SVGCache.swift
//  UIToolkits
//
//  Created by Qiang Huang on 10/26/21.
//  Copyright © 2021 dYdX Trading Inc. All rights reserved.
//

import SVGKit
import UIKit

public typealias SVGImageFunction = (_ image: UIImage?, _ error: Error?) -> Void
@objc public class SVGCache: NSObject {
    public static var shared = SVGCache()

    var cache: [String: UIImage] = [:]
    
    public func image(url: URL?, completion: @escaping SVGImageFunction) {
        if let url = url {
            let urlString = url.absoluteString
             if let image = cache[urlString] {
                completion(image, nil)
            } else {
                    URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                        if let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200, let mimeType = response?.mimeType, mimeType.hasPrefix("image"), let data = data, error == nil, let receivedicon: SVGKImage = SVGKImage(data: data), let image = receivedicon.uiImage {
                            self?.cache[urlString] = image

                            DispatchQueue.main.async {
                                completion(image, nil)
                            }
                        } else {
                            completion(nil, nil)
                        }
                    }.resume()
            }
        } else {
            completion(nil, nil)
        }
    }
}
