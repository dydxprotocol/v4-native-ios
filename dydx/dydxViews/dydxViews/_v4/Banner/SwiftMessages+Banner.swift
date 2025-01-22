//
//  SwiftMessages+Banner.swift
//  dydxViews
//
//  Created by Michael Maguire on 10/4/23.
//

import PlatformUI
import SwiftMessages
import Utilities

public extension MessageView {
    static func banner(title: String?, body: String?, type: EInfoType) -> MessageView {
        let view = MessageView.viewFromNib(layout: .cardView)
        let backgroundColor: UIColor
        let foregroundColor: UIColor
        let iconImage: UIImage?
        switch type {
        case .info, .wait, .success:
            backgroundColor = UIColor { _ in ThemeColor.SemanticColor.layer5.uiColor }
            foregroundColor = UIColor { _ in ThemeColor.SemanticColor.textPrimary.uiColor }
            iconImage = IconStyle.default.image(theme: .info)
        case .warning:
            backgroundColor = UIColor { _ in ThemeColor.SemanticColor.colorYellow.uiColor }
            foregroundColor = UIColor { _ in ThemeColor.SemanticColor.colorBlack.uiColor }
            iconImage = IconStyle.default.image(theme: .warning)
        case .error:
            backgroundColor = UIColor { _ in ThemeColor.SemanticColor.colorRed.uiColor }
            foregroundColor = UIColor { _ in ThemeColor.SemanticColor.colorWhite.uiColor }
            iconImage = IconStyle.default.image(theme: .error)
        }
        view.configureTheme(backgroundColor: backgroundColor, foregroundColor: foregroundColor, iconImage: iconImage)
        view.configureDropShadow()
        view.configureContent(title: title ?? "", body: body ?? "")
        view.button?.isHidden = true
        return view
    }
}
