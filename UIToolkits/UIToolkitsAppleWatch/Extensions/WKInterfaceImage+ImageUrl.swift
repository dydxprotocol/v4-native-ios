//
//  WKInterfaceImage+ImageUrl.swift
//  UIToolkitsAppleWatch
//
//  Created by John Huang on 12/8/18.
//  Copyright © 2019 dYdX. All rights reserved.
//

import WatchKit

public extension WKInterfaceImage {
    func setImage(url: String?) {
        if let url = url {
            let asyncQueue = DispatchQueue(label: "backgroundImage")
            asyncQueue.async {
                do {
                    if let url = URL(string: url) {
                        let data = try Data(contentsOf: url)
                        if let image = UIImage(data: data) {
                            self.setImage(image)
                        }
                    }
                } catch let error {
                    Console.shared.log("Could not set backgroundImage for WKInterfaceImage: \(error.localizedDescription)")
                }
            }
        } else {
            setImage(nil)
        }
    }
}
