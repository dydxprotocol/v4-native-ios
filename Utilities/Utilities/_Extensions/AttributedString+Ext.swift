//
//  AttributedString+Ext.swift
//  Utilities
//
//  Created by Rui Huang on 10/11/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import Foundation

extension AttributedString {
    public init(text: String, url: URL?) {
        self.init(text)
        if let url = url {
            self.link = url
            self.foregroundColor = .link
        }
    }
    
    public init(text: String, urlString: String?) {
        self.init(text: text, url: createUrl(string: urlString))
    }
}

private func createUrl(string: String?) -> URL? {
    if let string = string {
        return URL(string: string)
    } else {
        return nil
    }
}
