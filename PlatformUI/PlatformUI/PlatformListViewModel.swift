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
    public var header: PlatformViewModel? {
        didSet {
            contentChanged?()
        }
    }
    public var placeholder: PlatformViewModel? {
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
    
    // contentChanged is required because the list view model returns a ForEach struct
    // which does not observe the content change.  Caller should supply a contentChanged block
    // that manually triggers the parent view model's objectWillChange.send()
    
    public var contentChanged: (() -> Void)?

    public init(items: [PlatformViewModel] = [], header: PlatformViewModel? = nil, placeholder: PlatformViewModel? = nil, intraItemSeparator: Bool = true, firstListItemTopSeparator: Bool = false, lastListItemBottomSeparator: Bool = false, contentChanged: (() -> Void)? = nil) {
        self.items = items
        self.header = header
        self.placeholder = placeholder
        self.intraItemSeparator = intraItemSeparator
        self.firstListItemTopSeparator = firstListItemTopSeparator
        self.lastListItemBottomSeparator = lastListItemBottomSeparator
        self.contentChanged = contentChanged
    }
    
    open func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> AnyView {
        guard items.count > 0 else {
            let cell = Group {
                    if let placeholder = self.placeholder {
                        placeholder.createView(parentStyle: parentStyle)
                    } else {
                        PlatformView.nilView
                    }
                }
                .frame(width: width)
            return AnyView(cell)
        }
        
        let list: [PlatformViewModel]
        if header != nil {
            list = [PlatformViewModel()] + items
        } else {
            list = items
        }
        
        return AnyView(
            VStack(spacing: intraItemSeparator ? 0 : 10) {
                ForEach(list, id: \.id) { [weak self] item in
                    Group {
                        let cell =
                        Group {
                            if item === list.first, let header = self?.header {
                                header.createView(parentStyle: parentStyle)
                            } else {
                                VStack(alignment: .leading, spacing: 0) {
                                    if self?.intraItemSeparator == true {
                                        let shouldDisplayTopSeparator = self?.intraItemSeparator == true && (self?.firstListItemTopSeparator == true && item === list.first)
                                        let shouldDisplayBottomSeparator = self?.intraItemSeparator == true || (item !== list.last || self?.lastListItemBottomSeparator == true)
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
