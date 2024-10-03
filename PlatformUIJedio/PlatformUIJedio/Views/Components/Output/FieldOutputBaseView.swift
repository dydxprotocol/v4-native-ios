//
//  FieldOutputBaseViewModel.swift
//  PlatformUIJedio
//
//  Created by Rui Huang on 3/21/23.
//

import SwiftUI
import PlatformUI
import Utilities
import JedioKit

open class FieldOutputBaseViewModel: PlatformViewModel {
    @Published public var title: String?
    @Published public var subtitle: String?
    @Published public var text: String?
    @Published public var subtext: String?
    @Published public var image: String?
    @Published public var link: String?
    @Published public var onTapAction: (() -> Void)?

    public init() {}

    public init(output: FieldOutputProtocol) {
        if let title = output.title {
            self.title = DataLocalizer.localize(path: title)
        }
        if let subtitle = output.subtitle {
            self.subtitle = DataLocalizer.localize(path: subtitle)
        }
        if let text = output.text {
            self.text = DataLocalizer.localize(path: text)
        }
        if let subtext = output.subtext {
            self.subtext = DataLocalizer.localize(path: subtext)
        }
        if let link = output.fieldOutput?.link?["text"] as? String {
            self.link = link
        }
    }
}
