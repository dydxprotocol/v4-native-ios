//
//  PlatformListViewModel.swift
//  PlatformUI
//
//  Created by Rui Huang on 3/10/23.
//

import SwiftUI
import Utilities
import Combine

open class PlatformListViewModel: PlatformViewModeling {
    private let firstListItemTopSeparator: Bool
    private let lastListItemBottomSeparator: Bool
    private let intraItemSeparator: Bool

    public var items: [PlatformViewModel] = [] {
        didSet {
            contentChanged?()
        }
    }

    public var width: CGFloat? {
        didSet {
            if width != oldValue {
                contentChanged?()
            }
        }
    }

    open var header: PlatformViewModel? { nil }
    open var footer: PlatformViewModel? { nil }
    open var placeholder: PlatformViewModel? { nil }

    // contentChanged is required because the list view model returns a ForEach struct
    // which does not observe the content change.  Caller should supply a contentChanged block
    // that manually triggers the parent view model's objectWillChange.send()

    public var contentChanged: (() -> Void)?

    public init(items: [PlatformViewModel] = [],
                intraItemSeparator: Bool = true,
                firstListItemTopSeparator: Bool = false,
                lastListItemBottomSeparator: Bool = false,
                contentChanged: (() -> Void)? = nil) {
        self.items = items
        self.intraItemSeparator = intraItemSeparator
        self.firstListItemTopSeparator = firstListItemTopSeparator
        self.lastListItemBottomSeparator = lastListItemBottomSeparator
        self.contentChanged = contentChanged
    }

    open func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> AnyView {

        let itemsOrPlaceholder = items.count > 0 ? items : [placeholder ?? .init(bodyBuilder: nil)]
        let list: [PlatformViewModel]
        if let header, let footer {
            list = [header] + itemsOrPlaceholder + [footer]
        } else if let header {
            list = [header] + itemsOrPlaceholder
        } else if let footer {
            list = itemsOrPlaceholder + [footer]
        } else {
            list = itemsOrPlaceholder
        }

        return AnyView(
            VStack(spacing: intraItemSeparator ? 0 : 10) {
                ForEach(list, id: \.id) { [weak self] item in
                    Group {
                        let cell =
                        Group {
                            // render the item if it is a header or a footer and the index is first or last
                            // or if items is empty (and placeholder is being displayed)
                            if (item === list.first && self?.header != nil) || (item === list.last && self?.footer != nil) || self?.items.isEmpty != false {
                                item.createView(parentStyle: parentStyle)
                            } else {
                                VStack(alignment: .leading, spacing: 0) {
                                    if self?.intraItemSeparator == true {
                                        let shouldDisplayTopSeparator = self?.intraItemSeparator == true && (self?.firstListItemTopSeparator == true && item === list.first)
                                        let shouldDisplayBottomSeparator = self?.intraItemSeparator == true && (item !== list.last || self?.lastListItemBottomSeparator == true)
                                        if shouldDisplayTopSeparator {
                                            DividerModel().createView(parentStyle: parentStyle)
                                        }

                                        Spacer()
                                        item.createView(parentStyle: parentStyle)
                                        Spacer()

                                        if shouldDisplayBottomSeparator {
                                            DividerModel().createView(parentStyle: parentStyle)
                                        }
                                    } else {
                                        item.createView(parentStyle: parentStyle)
                                    }
                                }
                            }
                        }

                        if let width = self?.width {
                            cell.frame(width: width)
                        } else {
                            cell
                        }
                    }
                }
            }
        )
    }
}
