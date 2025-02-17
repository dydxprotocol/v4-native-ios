//
//  Extensions.swift
//  PlatformUI
//
//  Created by Rui Huang on 17/02/2025.
//

import SwiftUI

extension ExpandableText {
    public func themeFont(fontType: ThemeFont.FontType? = nil, fontSize: ThemeFont.FontSize = .medium) -> ExpandableText {
        var result = self
        
        let fontType = fontType ?? .base
        if let font = ThemeSettings.shared.themeConfig.themeFont.font(of: fontType, fontSize: fontSize) {
            result.font = font
        }
        return result
    }
    
    public func themeColor(foreground: ThemeColor.SemanticColor) -> ExpandableText {
        var result = self
       
        let color = ThemeSettings.shared.themeConfig.themeColor.color(of: foreground)
        result.foregroundColor = color
        return result
    }
    
    public func font(_ font: Font) -> ExpandableText {
        var result = self
        
        result.font = font
        
        return result
    }
    
    public func lineLimit(_ lineLimit: Int) -> ExpandableText {
        var result = self
        
        result.lineLimit = lineLimit
        return result
    }
    
    public func foregroundColor(_ color: Color) -> ExpandableText {
        var result = self
        
        result.foregroundColor = color
        return result
    }
    
    public func expandButton(_ expandButton: TextSet) -> ExpandableText {
        var result = self
        
        result.expandButton = expandButton
        return result
    }
    
    public func collapseButton(_ collapseButton: TextSet) -> ExpandableText {
        var result = self
        
        result.collapseButton = collapseButton
        return result
    }
    
    public func expandAnimation(_ animation: Animation?) -> ExpandableText {
        var result = self
        
        result.animation = animation
        return result
    }
}

extension String {
    func heightOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.height
    }
    
    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
}

public struct TextSet {
    var text: String
    var fontSize: ThemeFont.FontSize
    var fontType: ThemeFont.FontType
    var color: ThemeColor.SemanticColor

    public init(text: String, fontSize: ThemeFont.FontSize, fontType: ThemeFont.FontType = .base, color: ThemeColor.SemanticColor = .colorPurple) {
        self.text = text
        self.fontSize = fontSize
        self.fontType = fontType
        self.color = color
    }
}

func fontToUIFont(font: Font) -> UIFont {
    if #available(iOS 14.0, *) {
        switch font {
        case .largeTitle:
            return UIFont.preferredFont(forTextStyle: .largeTitle)
        case .title:
            return UIFont.preferredFont(forTextStyle: .title1)
        case .title2:
            return UIFont.preferredFont(forTextStyle: .title2)
        case .title3:
            return UIFont.preferredFont(forTextStyle: .title3)
        case .headline:
            return UIFont.preferredFont(forTextStyle: .headline)
        case .subheadline:
            return UIFont.preferredFont(forTextStyle: .subheadline)
        case .callout:
            return UIFont.preferredFont(forTextStyle: .callout)
        case .caption:
            return UIFont.preferredFont(forTextStyle: .caption1)
        case .caption2:
            return UIFont.preferredFont(forTextStyle: .caption2)
        case .footnote:
            return UIFont.preferredFont(forTextStyle: .footnote)
        case .body:
            return UIFont.preferredFont(forTextStyle: .body)
        default:
            return UIFont.preferredFont(forTextStyle: .body)
        }
    } else {
        switch font {
        case .largeTitle:
            return UIFont.preferredFont(forTextStyle: .largeTitle)
        case .title:
            return UIFont.preferredFont(forTextStyle: .title1)
            //            case .title2:
            //                return UIFont.preferredFont(forTextStyle: .title2)
            //            case .title3:
            //                return UIFont.preferredFont(forTextStyle: .title3)
        case .headline:
            return UIFont.preferredFont(forTextStyle: .headline)
        case .subheadline:
            return UIFont.preferredFont(forTextStyle: .subheadline)
        case .callout:
            return UIFont.preferredFont(forTextStyle: .callout)
        case .caption:
            return UIFont.preferredFont(forTextStyle: .caption1)
            //            case .caption2:
            //                return UIFont.preferredFont(forTextStyle: .caption2)
        case .footnote:
            return UIFont.preferredFont(forTextStyle: .footnote)
        case .body:
            return UIFont.preferredFont(forTextStyle: .body)
        default:
            return UIFont.preferredFont(forTextStyle: .body)
        }
    }
}
