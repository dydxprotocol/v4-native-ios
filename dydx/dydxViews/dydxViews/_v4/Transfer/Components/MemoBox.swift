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

public class MemoBoxModel: PlatformTextInputViewModel {
    @Published public var pasteAction: (() -> Void)?

    public init(onEdited: ((String?) -> Void)?) {
        super.init(label: DataLocalizer.localize(path: "APP.GENERAL.MEMO"),
                   placeHolder: DataLocalizer.localize(path: "APP.DIRECT_TRANSFER_MODAL.REQUIRED_FOR_CEX"),
                   onEdited: onEdited)
    }

    private var memoWarning: InlineAlertViewModel? {
        guard value?.isEmpty != false else { return nil }
        return InlineAlertViewModel(.init(title: nil,
                                   body: DataLocalizer.localize(path: "ERRORS.TRANSFER_MODAL.TRANSFER_WITHOUT_MEMO"),
                                   level: .warning))
    }

    public override var valueAccessoryView: AnyView? {
        set {}
        get { memoInputAccessory }
    }

    private var memoInputAccessory: AnyView? {
        ZStack(alignment: .trailing) {
            let shouldShowCancel = value?.isEmpty == false
            if shouldShowCancel {
                let content = Image("icon_cancel", bundle: .dydxView)
                    .resizable()
                    .templateColor(.textSecondary)
                    .frame(width: 9, height: 9)
                    .padding(.all, 10)
                    .borderAndClip(style: .circle, borderColor: .layer6)
                    .wrappedViewModel

                PlatformButtonViewModel(content: content,
                                               type: .iconType,
                                               state: .secondary) {[weak self] in
                    self?.programmaticallySet(value: "")
                }
                                               .createView()

            }
            let content = Text(localizerPathKey: "APP.GENERAL.PASTE")
                .themeColor(foreground: .textSecondary)
                .themeFont(fontType: .base, fontSize: .small)
                .wrappedViewModel

            PlatformButtonViewModel(content: content,
                                    type: .defaultType(fillWidth: false,
                                                       padding: .init(horizontal: 8, vertical: 6)),
                                    state: .secondary ) {[weak self] in
                guard let pastedString = UIPasteboard.general.string else { return }
                self?.programmaticallySet(value: pastedString)
            }
                                    .createView()
                                    .opacity(shouldShowCancel ? 0 : 1) // hide it with opacity so that it sizes correctly all the timem
        }
        .wrappedInAnyView()

    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        VStack(spacing: 12) {
            super.createView(parentStyle: parentStyle)
                .makeInput()
            memoWarning?.createView(parentStyle: parentStyle)
        }
        .wrappedViewModel
        .createView(parentStyle: parentStyle)
    }

    public static var previewValue: MemoBoxModel = {
        let vm = MemoBoxModel(onEdited: nil)
        return vm
    }()
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
