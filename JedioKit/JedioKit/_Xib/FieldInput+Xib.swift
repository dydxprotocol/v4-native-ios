//
//  FieldOutput+Xib.swift
//  FieldPresenterLib
//
//  Created by Qiang Huang on 10/16/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import ParticlesKit

extension FieldInput: XibProviderProtocol {
    public var xib: String? {
        if let fieldInput = fieldInput {
            if let xib = fieldInput.xib {
                return xib
            } else if fieldInput.link != nil {
                return "field_link"
            } else {
                let hasOptions = fieldInput.options != nil
                switch fieldInput.fieldType {
                case .text:
                    return hasOptions ? "field_input_grid_text" : "field_input_textfield_text"

                case .int:
                    if hasOptions {
                        return "field_input_grid_int"
                    } else if fieldInput.min != nil && fieldInput.max != nil {
                        return "field_input_slider_int"
                    } else {
                        return "field_input_textfield_int"
                    }

                case .float:
                    if fieldInput.min != nil && fieldInput.max != nil {
                        return "field_input_slider_float"
                    } else {
                        return "field_input_textfield_float"
                    }

                case .percent:
                    return "field_input_slider_percent"

                case .strings:
                    return "field_input_grid_strings"

                case .bool:
                    #if _iOS
                        return "field_input_switch"
                    #else
                        return "field_blank"
                    #endif

                case .image:
                    #if _iOS
                        return "field_button_image"
                    #else
                        return "field_blank"
                    #endif

                case .images:
                    #if _iOS
                        return "field_input_grid_images"
                    #else
                        return "field_blank"
                    #endif

                case .signature:
                    #if _iOS
                        return "field_input_button_signature"
                    #else
                        return "field_blank"
                    #endif
                }
            }
        } else {
            return "field_blank"
        }
    }
}
