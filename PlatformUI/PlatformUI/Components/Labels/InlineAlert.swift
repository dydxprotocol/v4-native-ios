//
//  InlineAlert.swift
//  dydxUI
//
//  Created by Michael Maguire on 4/4/24.
//  Copyright © 2024 dYdX Trading Inc. All rights reserved.
//

import SwiftUI

public class InlineAlertViewModel: PlatformViewModel {
    
    @Published public var config: Config
    
    public init(_ config: Config) {
        self.config = config
    }
    
    public static var previewValue: InlineAlertViewModel = {
        let vm = InlineAlertViewModel(Config(title: "Title", body: "Body", level: .error))
        return vm
    }()
    
    private var title: AnyView? {
        guard let titleText = config.title else { return nil }
        return Text(titleText)
            .themeFont(fontType: .plus, fontSize: .medium)
            .wrappedInAnyView()
    }
    
    private var body: AnyView? {
        guard let bodyText = config.body else { return nil }
        return Text(bodyText)
            .themeFont(fontType: .base, fontSize: .small)
            .wrappedInAnyView()
    }
    
    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }
            let config = self.config
            
            return HStack(spacing: 0) {
                config.level.tabColor.color
                    .frame(width: 6)
                HStack(spacing: 0) {
                    VStack(alignment: .leading) {
                        self.title
                        self.body

                    }
                    Spacer()
                }
                .padding(.all, 10)
                .themeColor(background: config.level.backgroundColor)
            }

            .fixedSize(horizontal: false, vertical: true)
            .clipShape(.rect(cornerRadius: 6))
            .wrappedInAnyView()
        }
    }
}

public extension InlineAlertViewModel {
    struct Config {
        public var title: AttributedString? = nil
        public var body: AttributedString? = nil
        public var level: Level
        
        public init(title: String?, body: String?, level: Level) {
            if let title = title {
                self.title = AttributedString(title)
            }
            if let body = body {
                self.body = AttributedString(body)
            }
            self.level = level
        }
        
        public init(title: AttributedString?, body: AttributedString?, level: Level) {
            self.title = title
            self.body = body
            self.level = level
        }
    }
}

public extension InlineAlertViewModel {
    enum Level {
        case error
        case warning
        case success
        
        fileprivate var tabColor: ThemeColor.SemanticColor {
            switch self {
            case .error:
                return .colorRed
            case .warning:
                return .colorYellow
            case .success:
                return .colorGreen
            }
        }
        
        fileprivate var backgroundColor: ThemeColor.SemanticColor {
            switch self {
            case .error:
                return .colorFadedRed
            case .warning:
                return .colorFadedYellow
            case .success:
                return .colorFadedGreen
            }
        }
    }
}

#if DEBUG
struct InlineAlert_Previews: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        Group {
            InlineAlertViewModel.previewValue
                .createView()
                .environmentObject(themeSettings)
                .previewLayout(.sizeThatFits)
        }
    }
}
#endif

