//
//  FieldInputBaseView.swift
//  PlatformUIJedio
//
//  Created by Rui Huang on 3/29/23.
//

import SwiftUI
import PlatformUI
import Utilities
import JedioKit

open class FieldInputBaseViewModel: PlatformViewModel {
    @Published public var title: String?
    @Published public var subtitle: String?
    @Published public var text: String?
    @Published public var image: String?
    @Published public var valueChanged: ((Any?) -> Void)?
    
    @Published public var input: FieldInputProtocol?
    
    public init() {}
    
    public init(input: FieldInputProtocol, valueChanged: ((Any?) -> Void)?) {
        self.input = input
        self.valueChanged = valueChanged
        if let title = input.title {
            self.title = DataLocalizer.localize(path: title)
        }
        if let subtitle = input.subtitle {
            self.subtitle = DataLocalizer.localize(path: subtitle)
        }
        if let text = input.text {
            self.text = DataLocalizer.localize(path: text)
        }
    }
}
