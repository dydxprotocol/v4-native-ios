//
//  AttributedString+Ext.swift
//  PlatformUI
//
//  Created by Michael Maguire on 9/9/24.
//

import Utilities

public extension AttributedString {
    init(text: String,
         // localizerPathKeys mapped to the action to be performed when tapped
         hyperlinks: [String: String],
         foreground: ThemeColor.SemanticColor = .textPrimary
    ) {
        var text = text
        for (key, url) in hyperlinks {
            let hyperlinkText = DataLocalizer.localize(path: key)
            // markdown supported as of iOS 15!
            text = text.replacingOccurrences(of: hyperlinkText, with: "[\(hyperlinkText)](\(url))")
        }
        var attributedString = (try? AttributedString(markdown: text)) ?? AttributedString(text)
            .themeColor(foreground: foreground)
        for run in attributedString.runs {
            if let _ = run.link {
                attributedString[run.range].underlineStyle = .single
                attributedString[run.range].foregroundColor = foreground.color // Change to any desired color
            }
        }
        self = attributedString
    }
    
    init(localizerPathKey: String,
         params: [String: String]? = nil,
         // localizerPathKeys mapped to the action to be performed when tapped
         hyperlinks: [String: String],
         foreground: ThemeColor.SemanticColor = .textPrimary
    ) {
        var localizedText = DataLocalizer.localize(path: localizerPathKey, params: params)
        self.init(text: localizedText, hyperlinks: hyperlinks, foreground: foreground)
    }
}
