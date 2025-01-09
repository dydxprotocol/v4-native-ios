//
//  ThemeViewModifiers.swift
//  PlatformUI
//
//  Created by Rui Huang on 8/10/22.
//

import SwiftUI
import SDWebImageSwiftUI
import Utilities

// MARK: Color

public extension View {
    func themeColor(foreground: ThemeColor.SemanticColor) -> some View {
        modifier(TextColorModifier(textColor: foreground))
    }

    func themeColor(background: ThemeColor.SemanticColor) -> some View {
        modifier(BackgroundColorModifier(layerColor: background))
    }

    func themeGradient(background: ThemeColor.SemanticColor,
                       gradientColor: Color,
                       intensityLayerColor: Double = 0.95,
                       intensityGradientColor: Double = 0.05) -> some View {
        modifier(GradientColorModifier(layerColor: background,
                                       gradientColor: gradientColor,
                                       intensityLayerColor: intensityLayerColor,
                                       intensityGradientColor: intensityGradientColor))
    }
}

public extension Text {
    func themeColor(foreground: ThemeColor.SemanticColor) -> Text {
        self.foregroundColor(foreground.color)
    }
}

private struct TextColorModifier: ViewModifier {
    @EnvironmentObject var themeSettings: ThemeSettings

    let textColor: ThemeColor.SemanticColor

    func body(content: Content) -> some View {
        content
            .foregroundColor(themeSettings.themeConfig.themeColor.color(of: textColor))
    }
}

private struct BackgroundColorModifier: ViewModifier {
    @EnvironmentObject var themeSettings: ThemeSettings

    let layerColor: ThemeColor.SemanticColor

    func body(content: Content) -> some View {
        content
            .background(themeSettings.themeConfig.themeColor.color(of: layerColor))
    }
}

private struct GradientColorModifier: ViewModifier {
    @EnvironmentObject var themeSettings: ThemeSettings

    let layerColor: ThemeColor.SemanticColor
    let gradientColor: Color
    let intensityLayerColor: Double
    let intensityGradientColor: Double

    fileprivate init(layerColor: ThemeColor.SemanticColor, gradientColor: Color, intensityLayerColor: Double = 0.95, intensityGradientColor: Double = 0.05) {
        self.layerColor = layerColor
        self.gradientColor = gradientColor
        self.intensityLayerColor = intensityLayerColor
        self.intensityGradientColor = intensityGradientColor
    }

    func body(content: Content) -> some View {
        let layerColor = themeSettings.themeConfig.themeColor.color(of: layerColor)
        let blendedColor = Color(UIColor.blend(color1: UIColor(layerColor), intensity1: intensityLayerColor, color2: UIColor(gradientColor), intensity2: intensityGradientColor))

        let gradient = LinearGradient(
            gradient: Gradient(colors: [
                layerColor,
                blendedColor]),
            startPoint: .leading, endPoint: .trailing)

        content
            .background(gradient)
    }
}

public extension Image {
    /// iniitalizes an image that supports app themes
    /// - Parameters:
    ///   - themedImageBaseName: the base image name. e.g. if the app supports 3 themes and the corresponding themed image names are "circle_light" "circle_dark" and "circle_classic_dark" then your base name is "circle"
    ///   - bundle: the bundle
    init(themedImageBaseName: String, bundle: Bundle, themeSettings: ThemeSettings = ThemeSettings.shared) {
        self.init(themedImageBaseName + "_" + "\(themeSettings.themeConfig.id)", bundle: bundle)
    }

    func templateColor(_ foreground: ThemeColor.SemanticColor?) -> some View {
        if let foreground = foreground {
            return AnyView(self.renderingMode(.template).themeColor(foreground: foreground))
        }
        return AnyView(self)
    }
}

public extension WebImage {
    func templateColor(_ foreground: ThemeColor.SemanticColor?) -> some View {
        if let foreground = foreground {
          return AnyView(self.renderingMode(.template).themeColor(foreground: foreground))
        }
        return AnyView(self)
    }
}

// MARK: Font

public extension View {
    func themeFont(fontType: ThemeFont.FontType? = nil, fontSize: ThemeFont.FontSize = .medium) -> some View {
        let fontType = fontType ?? .base
        return modifier(ThemeFontModifier(fontType: fontType, fontSize: fontSize))
    }
}

private struct ThemeFontModifier: ViewModifier {
    @EnvironmentObject var themeSettings: ThemeSettings

    let fontType: ThemeFont.FontType
    let fontSize: ThemeFont.FontSize

    func body(content: Content) -> some View {
        content
            .font(themeSettings.themeConfig.themeFont.font(of: fontType, fontSize: fontSize))
    }
}

public extension Text {
    func themeFont(fontType: ThemeFont.FontType = .base, fontSize: ThemeFont.FontSize = .medium) -> Text {
        return self.font(ThemeSettings.shared.themeConfig.themeFont.font(of: fontType, fontSize: fontSize))
    }
}

// MARK: Style

public extension View {
    func themeStyle(style: ThemeStyle) -> some View {
        modifier(StyleModifier(style: style))
    }

    func themeStyle(styleKey: String, parentStyle: ThemeStyle) -> some View {
        modifier(StyleKeyModifier(styleKey: styleKey, parentStyle: parentStyle))
    }
}

private struct StyleModifier: ViewModifier {
    @EnvironmentObject var themeSettings: ThemeSettings

    let style: ThemeStyle

    func body(content: Content) -> some View {
        if let fontType = style.fontType, let fontSize = style.fontSize, let textColor = style.textColor, let layerColor = style.layerColor {
            content
                .themeFont(fontType: fontType, fontSize: fontSize)
                .themeColor(foreground: textColor)
                .themeColor(background: layerColor)
        } else {
           // assertionFailure("StyleModifier: style not complete")
            content
        }
    }
}

private struct StyleKeyModifier: ViewModifier {
    @EnvironmentObject var themeSettings: ThemeSettings

    let styleKey: String
    let parentStyle: ThemeStyle

    func body(content: Content) -> some View {
        if let style = themeSettings.styleConfig.styles[styleKey] {
            content
                .themeStyle(style: parentStyle.merge(from: style))
        } else {
            content
        }
    }
}

// MARK: Sheet

public enum MakeSheetStyle {
    case fullScreen, fitSize
    /// note this style behaves significantly different. It takes content and rounds the corners, adds insets and safe area ignore.
    /// only use on views presented with presentOverFullSreen presentation style
    /// these sheets are not drag-to-dismiss
    case forPresentedOverCurrentScreen
}

public extension View {
    func makeSheet(sheetStyle: MakeSheetStyle = .fullScreen) -> some View {
        modifier(SheetViewModifier(sheetStyle: sheetStyle))
    }
}

private struct SheetViewModifier: ViewModifier {
    let topPadding: CGFloat = 18
    let sheetStyle: MakeSheetStyle

    @EnvironmentObject var themeSettings: ThemeSettings

    func body(content: Content) -> some View {
        let dragIndicator = Rectangle()
            .themeColor(background: .layer1)
            .frame(width: 36, height: 4)
            .clipShape(Capsule())
            .padding(.top, topPadding)

        switch sheetStyle {
        case .fullScreen:
            return AnyView(
                ZStack(alignment: .top) {
                    content
                        .cornerRadius(36, corners: [.topLeft, .topRight])
                    VStack {
                        dragIndicator
                        Spacer()
                    }
                }
                    .frame(maxWidth: .infinity)
                    .environmentObject(themeSettings)
            )
        case .fitSize:
            return AnyView(
                ZStack(alignment: .bottom) {
                    VStack(spacing: 0) {
                        Spacer()
                        ZStack(alignment: .top) {
                            content
                                .cornerRadius(36, corners: [.topLeft, .topRight])
                            VStack {
                                dragIndicator
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .environmentObject(themeSettings)
                }
            )

        case .forPresentedOverCurrentScreen:
            return ZStack(alignment: .bottom) {
                ThemeColor.SemanticColor.layer0.color
                    .opacity(0.8)
                content
                .padding(.top, 24)
                .padding(.bottom, max((content.safeAreaInsets?.bottom ?? 0), 16))
                .padding(.horizontal, 24)
                .themeColor(background: .layer3)
                .cornerRadius(36, corners: [.topLeft, .topRight])
            }
            .frame(maxWidth: .infinity)
            .ignoresSafeArea(edges: [.all])
            .wrappedInAnyView()
        }
    }
}
// MARK: Make any view a button

public extension View {
    func makeButton(style: ThemeStyle = ThemeStyle.defaultStyle, action: @escaping (() -> Void)) -> some View {
        modifier(ButtonViewModifier(style: style, action: action))
    }
}

private struct ButtonViewModifier: ViewModifier {
    let style: ThemeStyle
    let action: (() -> Void)

    @EnvironmentObject var themeSettings: ThemeSettings

    func body(content: Content) -> some View {
        PlatformButtonViewModel(content: content.wrappedViewModel, type: .iconType) {
            action()
        }
        .createView(parentStyle: style)
        .environmentObject(themeSettings)
    }
}

// MARK: CornerRadius

public extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners) )
    }
}

private struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

// MARK: Border

public extension View {
    func border(borderWidth: CGFloat = 1, cornerRadius: CGFloat = 0, borderColor: Color? = ThemeColor.SemanticColor.layer5.color) -> some View {
        modifier(BorderModifier(cornerRadius: cornerRadius, borderWidth: borderWidth, borderColor: borderColor))
    }

    func borderAndClip(style: ClipStyle, borderColor: ThemeColor.SemanticColor, lineWidth: CGFloat = 1) -> some View {
        modifier(BorderAndClipModifier(style: style, borderColor: borderColor, lineWidth: lineWidth))
    }
}

/// The clip shape/style
public enum ClipStyle {
    /// A rectangular shape with rounded corners with specified corner radius, aligned inside the frame of the view containing it.
    case cornerRadius(CGFloat)
    /// A capsule shape is equivalent to a rounded rectangle where the corner radius is chosen as half the length of the rectangle’s smallest edge.
    case capsule
    case circle
}

private struct BorderAndClipModifier: ViewModifier {
    @EnvironmentObject var themeSettings: ThemeSettings
    
    let style: ClipStyle
    let borderColor: ThemeColor.SemanticColor
    let lineWidth: CGFloat

    func body(content: Content) -> some View {
        let color = themeSettings.themeConfig.themeColor.color(of: borderColor)
        switch style {
        case .circle:
            content
                .clipShape(Circle())
                .overlay(Circle()
                    .strokeBorder(color, lineWidth: lineWidth))
                .environmentObject(themeSettings)

        case .cornerRadius(let cornerRadius):
            content
                .clipShape(.rect(cornerRadius: cornerRadius))
                .overlay(RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(color, lineWidth: lineWidth))
                .environmentObject(themeSettings)

        case .capsule:
            content
                .clipShape(Capsule())
                .overlay(Capsule()
                    .strokeBorder(color, lineWidth: lineWidth))
                .environmentObject(themeSettings)
        }
    }
}

private struct BorderModifier: ViewModifier {
    var cornerRadius: CGFloat = .infinity
    var borderWidth: CGFloat = 1
    var borderColor: Color? = ThemeColor.SemanticColor.layer5.color

    @EnvironmentObject var themeSettings: ThemeSettings

    func body(content: Content) -> some View {
        content
            .clipShape(.rect(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor ?? .clear, lineWidth: borderWidth)
            )
            .padding(borderWidth)
            .environmentObject(themeSettings)
    }
}

// MARK: List

public extension View {
    func animateHeight(height: CGFloat) -> some View {
        modifier(AnimatingViewHeight(height: height))
    }
}

private struct AnimatingViewHeight: AnimatableModifier {
    var height: CGFloat = 0

    var animatableData: CGFloat {
        get { height }
        set { height = newValue }
    }

    func body(content: Content) -> some View {
        content.frame(height: height)
    }
}

// MARK: LeftAligned

public extension View {
    func leftAligned() -> some View {
        modifier(LeftAlignedModifier())
    }
}

private struct LeftAlignedModifier: ViewModifier {
    func body(content: Content) -> some View {
        HStack(spacing: 0) {
            content
            Spacer(minLength: 0)
        }
    }
}

// MARK: RightAligned

public extension View {
    func rightAligned() -> some View {
        modifier(RightAlignedModifier())
    }
}

private struct RightAlignedModifier: ViewModifier {
    func body(content: Content) -> some View {
        HStack {
            Spacer()
            content
        }
    }
}

// MARK: TopAligned

public extension View {
    func topAligned() -> some View {
        modifier(TopAlignedModifier())
    }
}

private struct TopAlignedModifier: ViewModifier {
    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            content
            Spacer(minLength: 0)
        }
    }
}

// MARK: BottomAligned

public extension View {
    func bottomAligned() -> some View {
        modifier(BottomAlignedModifier())
    }
}

private struct BottomAlignedModifier: ViewModifier {
    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)
            content
        }
    }
}

// MARK: LeftAligned

public extension View {
    func verticalCenterAligned() -> some View {
        modifier(VerticalCenterAlignedModifier())
    }
}

private struct VerticalCenterAlignedModifier: ViewModifier {
    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)
            content
            Spacer(minLength: 0)
        }
    }
}

// MARK: CenterAligned

public extension View {
    func centerAligned() -> some View {
        modifier(CenterAlignedModifier())
    }
}

private struct CenterAlignedModifier: ViewModifier {
    func body(content: Content) -> some View {
        // forcing minLength to 0 does make a difference, default behavior is black box behavior which seems to vary
        HStack(spacing: 0) {
            Spacer(minLength: 0)
            VStack(spacing: 0) {
                Spacer(minLength: 0)
                content
                Spacer(minLength: 0)
            }
            Spacer(minLength: 0)
        }
    }
}

// MARK: NavigationView

public extension View {
    func navigationViewEmbedded(backgroundColor: Color?) -> some View {
        modifier(NavigationViewEmbeddedModifier(backgroundColor: backgroundColor))
    }
}

private struct NavigationViewEmbeddedModifier: ViewModifier {
    let backgroundColor: Color?

    func body(content: Content) -> some View {
        NavigationView {
            if let backgroundColor = backgroundColor {
                ZStack {
                    backgroundColor.edgesIgnoringSafeArea(.all)
                    content
                }
                .navigationBarHidden(true)
            } else {
                content
                    .navigationBarHidden(true)
            }
        }
    }
}

// MARK: Circle background

public extension View {
    func circleBackground(size: CGSize = CGSize(width: 48, height: 48), color: ThemeColor.SemanticColor = .layer6) -> some View {
        modifier(CircleBackgroundModifier(size: size, color: color))
    }
}

private struct CircleBackgroundModifier: ViewModifier {
    let size: CGSize
    let color: ThemeColor.SemanticColor

    func body(content: Content) -> some View {
        ZStack {
            content
       }
        .frame(width: size.width, height: size.height)
       .themeColor(background: color)
       .clipShape(Circle())
    }
}

public extension View {
    func flipped(_ axis: Axis = .horizontal, anchor: UnitPoint = .center) -> some View {
        switch axis {
        case .horizontal:
            return scaleEffect(CGSize(width: -1, height: 1), anchor: anchor)
        case .vertical:
            return scaleEffect(CGSize(width: 1, height: -1), anchor: anchor)
        }
    }
}

// MARK: AttributedString

public extension AttributedString {
    /// Applies a font to the attributed string.
    /// - Parameters:
    ///   - foreground: the font to apply
    ///   - range: the range to modify, `nil` if the entire string should be modified
    func themeFont(fontType: ThemeFont.FontType = .base, fontSize: ThemeFont.FontSize = .medium, to range: Range<AttributedString.Index>? = nil) -> Self {
        var string = self
        if let range = range {
            string[range].font = ThemeSettings.shared.themeConfig.themeFont.font(of: fontType, fontSize: fontSize)
        } else {
            string.font = ThemeSettings.shared.themeConfig.themeFont.font(of: fontType, fontSize: fontSize)
        }
        return string
    }

    /// Applies a foreground color to the attributed string.
    /// - Parameters:
    ///   - foreground: the color to apply
    ///   - range: the range to modify, `nil` if the entire string should be modified
    func themeColor(foreground: ThemeColor.SemanticColor, to range: Range<AttributedString.Index>? = nil) -> Self {
        var string = self
        if let range = range {
            string[range].foregroundColor = ThemeSettings.shared.themeConfig.themeColor.color(of: foreground)
        } else {
            string.foregroundColor = ThemeSettings.shared.themeConfig.themeColor.color(of: foreground)
        }
        return string
    }

    func dottedUnderline(foreground: ThemeColor.SemanticColor, for range: Range<AttributedString.Index>? = nil) -> Self {
        var string = self
        let range = range ?? string.startIndex..<string.endIndex
        let underlineStyle = NSUnderlineStyle.single.union(.patternDot)
        string[range].underlineStyle = underlineStyle
        string[range].underlineColor = UIColor(ThemeSettings.shared.themeConfig.themeColor.color(of: foreground))
        return string
    }
}

// MARK: Keyboard Accessory

public extension View {
    func keyboardAccessory(keyboardToolbarContent: AnyView? = nil, background: ThemeColor.SemanticColor = .transparent, parentStyle: ThemeStyle) -> some View {
        if let keyboardToolbarContent = keyboardToolbarContent {
            return modifier(KeyboardAccessoryModifier(keyboardToolbarContent: keyboardToolbarContent, background: background))
        }

        let text = Text(DataLocalizer.localize(path: "APP.GENERAL.DONE"))
            .themeColor(foreground: .colorWhite)
            .themeFont(fontSize: .small)
        let keyboardToolbarContent = AnyView(
            PlatformButtonViewModel(content: text.wrappedViewModel,
                                    type: .pill) {
                                        PlatformView.hideKeyboard()
                                    }
                .createView(parentStyle: parentStyle)
        )
        return modifier(KeyboardAccessoryModifier(keyboardToolbarContent: keyboardToolbarContent, background: background))
    }
}

// MARK: Bullet list

public extension View {
    func bulletItem() -> some View {
        modifier(BulletItemModifier())
    }
}

private struct BulletItemModifier: ViewModifier {
    func body(content: Content) -> some View {
        HStack(alignment: .top) {
            Text("\u{2022}")
            content
        }
    }
}

private struct KeyboardAccessoryModifier: ViewModifier {
    let keyboardToolbarContent: AnyView
    let background: ThemeColor.SemanticColor

    func body(content: Content) -> some View {
        ZStack {

            background.color
                .edgesIgnoringSafeArea(.all)

            content
                .themeColor(background: background)
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        keyboardToolbarContent
                    }
                }
        }
    }
}

public extension PlatformView {
    static func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

private struct TruncateWithoutEllipses: ViewModifier {
    func body(content: Content) -> some View {
        ZStack(alignment: .leading) {
            content.hidden().layoutPriority(1)
            content.fixedSize(horizontal: true, vertical: false)
        }
        .clipped()
    }
}

public enum ExtendedTruncationMode {
    case noEllipsis
}

public extension View {
    func truncationMode(_ mode: ExtendedTruncationMode) -> some View {
        switch mode {
        case .noEllipsis:
            return self.modifier(TruncateWithoutEllipses())
        }
    }
}

public extension View {
    func wrappedInAnyView() -> AnyView {
        AnyView(self)
    }
}

// MARK: ScrollView

public extension View {
  func disableBounces() -> some View {
    modifier(DisableBouncesModifier())
  }
}

struct DisableBouncesModifier: ViewModifier {
  func body(content: Content) -> some View {
      content
          .onAppear {
              UIScrollView.appearance().bounces = false
          }
          .onDisappear {
              UIScrollView.appearance().bounces = true
          }
  }
}

// MARK: Conditional

public extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, _ transform: (Self) -> Content, `else` elseTransform: ((Self) -> Content)? = nil) -> some View {
        if condition {
            transform(self)
        } else if let elseTransform {
            elseTransform(self)
        } else {
            self
        }
    }
}
