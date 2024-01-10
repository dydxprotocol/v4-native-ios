//
//  dydxTitledCardView.swift
//  dydxViews
//
//  Created by Michael Maguire on 12/1/23.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxTitledCardViewModel: PlatformViewModel {

    public let title: String
    public let tooltip: String?
    public let verticalContentPadding: CGFloat
    public let horizontalContentPadding: CGFloat
    @Published public var tapAction: (() -> Void)?
    @Published private var isTooltipPresented: Bool = false
    private lazy var isTooltipPresentedBinding = Binding(
        get: { [weak self] in self?.isTooltipPresented == true },
        set: { [weak self] in self?.isTooltipPresented = $0 }
    )

    public init(title: String,
                tooltip: String? = nil,
                verticalContentPadding: CGFloat = 16,
                horizontalContentPadding: CGFloat = 16) {
        self.title = title
        self.tooltip = tooltip
        self.verticalContentPadding = verticalContentPadding
        self.horizontalContentPadding = horizontalContentPadding
        super.init()
    }

    fileprivate static var previewValue: dydxTitledCardViewModel {
        let vm = dydxTitledCardViewModel(title: "TEST")
        return vm
    }

    func createContentView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> AnyView? {
        AnyView(PlatformView.nilView)
    }

    /// creates the title text view. If tooltip is non-nil, the title will be hyperlinked and underlined such that tapping displays the tooltip text.
    func createTitleTextView() -> AnyView? {
        let attributedTitle = AttributedString(self.title)
            .themeFont(fontSize: .small)
            .themeColor(foreground: .textSecondary)
        if let tooltip = tooltip {
            return Text(attributedTitle.dottedUnderline(foreground: .textSecondary))
                .onTapGesture { [weak self] in
                    self?.isTooltipPresented.toggle()
                }
                .popover(present: self.isTooltipPresentedBinding, attributes: {
                    $0.position = .absolute(
                          originAnchor: .top,
                          popoverAnchor: .bottom
                      )
                    $0.sourceFrameInset = .init(top: 0, left: 0, bottom: -16, right: 0)
                    $0.presentation.animation = .none
                    $0.blocksBackgroundTouches = true
                    $0.onTapOutside = {
                        self.isTooltipPresented = false
                    }
                }, view: {
                    Text(tooltip)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 12)
                        .themeFont(fontType: .text, fontSize: .small)
                        .themeColor(foreground: .textSecondary)
                        .themeColor(background: .layer5)
                        .borderAndClip(style: .cornerRadius(8), borderColor: .layer6, lineWidth: 1)
                        .environmentObject(ThemeSettings.shared)
                })
                .wrappedInAnyView()
        } else {
            return Text(attributedTitle)
                .wrappedInAnyView()
        }

    }

    /// defaults to a right facing chevron. override if you want a different accessory view or no accessory view at all
    func createTitleAccessoryView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> AnyView? {
        PlatformIconViewModel(type: .system(name: "chevron.right"),
                              size: CGSize(width: 10, height: 10),
                              templateColor: .textSecondary)
        .createView(parentStyle: parentStyle)
        .wrappedInAnyView()
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = VStack(spacing: 0) {
                HStack(spacing: 0) {
                    self.createTitleTextView()
                    Spacer(minLength: 16)
                    self.createTitleAccessoryView(parentStyle: parentStyle)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                DividerModel()
                    .createView(parentStyle: style)
                self.createContentView(parentStyle: parentStyle)
                    .padding(.vertical, self.verticalContentPadding)
                    .padding(.horizontal, self.horizontalContentPadding)
                Spacer(minLength: 0)
            }
            .themeColor(background: .layer3)
            .cornerRadius(12, corners: .allCorners)
            .onTapGesture { [weak self] in
                self?.tapAction?()
            }

            return AnyView(view)
        }
    }
}

#if DEBUG
struct dydxTitledCardViewModel_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxTitledCardViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxTitledCardViewModel_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxTitledCardViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
