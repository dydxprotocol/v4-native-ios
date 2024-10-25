//
//  MemoBox.swift
//  dydxViews
//
//  Created by Michael Maguire on 6/4/24.
//

import SwiftUI
import PlatformUI
import Utilities
import dydxFormatter

public class MemoBoxModel: PlatformViewModel {
    @Published public var shouldDisplayWarningWhenEmpty: Bool = false
    @Published public var text: String = ""

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        MemoBoxView(viewModel: self)
            .wrappedViewModel
            .createView()
    }

    public static var previewValue: MemoBoxModel = {
        let vm = MemoBoxModel()
        return vm
    }()
}

private struct MemoBoxView: View {
    @ObservedObject var viewModel: MemoBoxModel

    private var titledTextField: some View {
        dydxTitledTextField(title: DataLocalizer.localize(path: "APP.GENERAL.MEMO"),
                            placeholder: DataLocalizer.localize(path: "APP.DIRECT_TRANSFER_MODAL.REQUIRED_FOR_CEX"),
                            isPasteEnabled: true,
                            text: $viewModel.text)
    }

    private var memoWarning: some View {
        InlineAlertViewModel(.init(title: nil,
                                   body: DataLocalizer.localize(path: "ERRORS.TRANSFER_MODAL.TRANSFER_WITHOUT_MEMO"),
                                   level: .warning))
        .createView()
    }

    var body: some View {
        VStack(spacing: 12) {
            titledTextField
                .frame(maxWidth: .infinity)
            memoWarning
        }
    }
}

#if DEBUG
struct MemoBox_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return MemoBoxModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct MemoBox_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return MemoBoxModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
