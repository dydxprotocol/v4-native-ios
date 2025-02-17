//
//  ExpandableText.swift
//  PlatformUI
//
//  Created by Rui Huang on 17/02/2025.
//

import SwiftUI

public struct ExpandableText: View {
    var text : String
    
    @available(iOS 15, *)
    var markdownText: AttributedString {
        (try? AttributedString(markdown: text, options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace))) ?? AttributedString()
    }
    
    var font: Font = .body
    var lineLimit: Int = 3
    var foregroundColor: Color = .primary
    
    var expandButton: TextSet = TextSet(text: "more", fontSize: .medium)
    var collapseButton: TextSet? = nil
    
    var animation: Animation? = .none
    
    @State private var expand : Bool = false
    @State private var truncated : Bool = false
    @State private var fullSize: CGFloat = 0
    
    private var expandButtonFont: Font {
        let fontType = expandButton.fontType
        return ThemeSettings.shared.themeConfig.themeFont.font(of: fontType, fontSize: expandButton.fontSize) ?? .title
    }
    
    private var collapseButtonFont: Font {
        let fontType = collapseButton?.fontType ?? .base
        return ThemeSettings.shared.themeConfig.themeFont.font(of: fontType, fontSize: collapseButton?.fontSize ?? .medium) ?? .title
    }
    
    public init(text: String) {
        self.text = text
    }
    public var body: some View {
        
      
            
        ZStack(alignment: .bottomTrailing){
            Group {
                if #available(iOS 15.0, *) {
                    Text(markdownText)
                } else {
                    Text(text)
                }
            }
                .font(font)
                .foregroundColor(foregroundColor)
                .lineLimit(expand == true ? nil : lineLimit)
                .animation(animation, value: expand)
                .mask(
                    VStack(spacing: 0){
                        Rectangle()
                            .foregroundColor(.black)
                        
                        HStack(spacing: 0){
                            Rectangle()
                                .foregroundColor(.black)

                            if truncated{
                                if !expand {
                                    HStack(alignment: .bottom,spacing: 0){
                                        LinearGradient(
                                            gradient: Gradient(stops: [
                                                Gradient.Stop(color: .black, location: 0),
                                                Gradient.Stop(color: .clear, location: 0.8)]),
                                            startPoint: .leading,
                                            endPoint: .trailing)
                                            .frame(width: 32, height: expandButton.text.heightOfString(usingFont: fontToUIFont(font: expandButtonFont)))
                                        
                                        Rectangle()
                                            .foregroundColor(.clear)
                                            .frame(width: expandButton.text.widthOfString(usingFont: fontToUIFont(font: expandButtonFont)), alignment: .center)
                                    }
                                }
                                else if let collapseButton = collapseButton {
                                    HStack(alignment: .bottom,spacing: 0){
                                        LinearGradient(
                                            gradient: Gradient(stops: [
                                                Gradient.Stop(color: .black, location: 0),
                                                Gradient.Stop(color: .clear, location: 0.8)]),
                                            startPoint: .leading,
                                            endPoint: .trailing)
                                            .frame(width: 32, height: collapseButton.text.heightOfString(usingFont: fontToUIFont(font: collapseButtonFont)))
                                        
                                        Rectangle()
                                            .foregroundColor(.clear)
                                            .frame(width: collapseButton.text.widthOfString(usingFont: fontToUIFont(font: collapseButtonFont)), alignment: .center)
                                    }
                                }
                            }
                        }
                        .frame(height: expandButton.text.heightOfString(usingFont: fontToUIFont(font: font)))
                    }
                )
            
            if truncated {
                if let collapseButton = collapseButton {
                    Button(action: {
                        self.expand.toggle()
                    }, label: {
                        Text(expand == false ? expandButton.text : collapseButton.text)
                            .if(expand == false) { view in
                                view.themeFont(fontType: expandButton.fontType, fontSize: expandButton.fontSize)
                            }
                            .if(expand) {  view in
                                view.themeFont(fontType: collapseButton.fontType, fontSize: collapseButton.fontSize)
                            }
                            .themeColor(foreground: expand == false ? expandButton.color : collapseButton.color)
                    })
                }
                else if !expand {
                    Button(action: {
                        self.expand = true
                    }, label: {
                        Text(expandButton.text)
                            .themeFont(fontType: expandButton.fontType, fontSize: expandButton.fontSize)
                            .themeColor(foreground: expandButton.color)
                    })
                }
            }
        }
        .background(
            ZStack{
                if !truncated {
                    if fullSize != 0 {
                        Text(text)
                            .font(font)
                            .lineLimit(lineLimit)
                            .background(
                                GeometryReader { geo in
                                    Color.clear
                                        .onAppear {
                                            if fullSize > geo.size.height {
                                                self.truncated = true
                                                print(geo.size.height)
                                            }
                                        }
                                }
                            )
                    }
                    
                    Text(text)
                        .font(font)
                        .lineLimit(999)
                        .fixedSize(horizontal: false, vertical: true)
                        .background(GeometryReader { geo in
                            Color.clear
                                .onAppear() {
                                    self.fullSize = geo.size.height
                                }
                        })
                }
            }
                .hidden()
        )
    }
}
