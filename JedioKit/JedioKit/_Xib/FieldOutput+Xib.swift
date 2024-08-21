//
//  FieldOutput+Xib.swift
//  FieldPresenterLib
//
//  Created by Qiang Huang on 10/16/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import ParticlesKit

extension FieldOutput: XibProviderProtocol {
    public var xib: String? {
        if let xib = fieldOutput?.xib {
            return xib
        } else {
            if let _ = fieldOutput?.checked {
                return "field_checkmark"
            } else if let _ = fieldOutput?.image {
                return "field_image"
            } else if let _ = fieldOutput?.strings {
                return "field_strings"
            } else if let _ = fieldOutput?.images {
                return "field_images"
            } else if let _ = fieldOutput?.subtext {
                return "field_text_long"
            } else if let _ = fieldOutput?.title {
                return "field_text"
            } else {
                return "field_text_long"
            }
        }
    }
}
