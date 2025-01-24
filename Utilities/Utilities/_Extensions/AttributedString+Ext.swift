//
//  AttributedString+Ext.swift
//  Utilities
//
//  Created by Rui Huang on 10/11/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import Foundation

extension AttributedString {
    public init(text: String, url: URL?, foregroundColor: UIColor? = .link) {
        self.init(text)
        if let url = url {
            self.link = url
            self.foregroundColor = foregroundColor
        }
    }

    public init(text: String, urlString: String?, foregroundColor: UIColor? = .link) {
        self.init(text: text, url: createUrl(string: urlString), foregroundColor: foregroundColor)
    }
}

private func createUrl(string: String?) -> URL? {
    if let string = string {
        return URL(string: string)
    } else {
        return nil
    }
}
