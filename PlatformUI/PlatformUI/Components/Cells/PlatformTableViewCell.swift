//
//  TableCell.swift
//  PlatformUI
//
//  Created by Rui Huang on 8/22/22.
//

import SwiftUI

public class PlatformTableViewCellViewModel: PlatformViewModel {
    
    @Published public var leading: PlatformViewModel?
    @Published public var logo: PlatformViewModel?
    @Published public var main: PlatformViewModel
    @Published public var trailing: PlatformViewModel?
    @Published public var edgeInsets: EdgeInsets
    
    public init(leading: PlatformViewModel? = nil,
                logo: PlatformViewModel? = nil,
                main: PlatformViewModel,
                trailing: PlatformViewModel? = nil,
                edgeInsets: EdgeInsets = EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)) {
        self.leading = leading
        self.logo = logo
        self.main = main
        self.trailing = trailing
        self.edgeInsets = edgeInsets
    }
    
    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }
            
            return AnyView(
                HStack(spacing: 0) {
                    self.leading?.createView(parentStyle: style, styleKey: nil)
                        .themeStyle(styleKey: "table-cell-subtitle-style", parentStyle: style)
                        .padding(.trailing, 16)

                    self.logo?.createView(parentStyle: style, styleKey: nil)
                        .padding(.trailing, 16)

                    self.main.createView(parentStyle: style, styleKey: nil)
                        .themeStyle(styleKey: "table-cell-title-style", parentStyle: style)
                    
                    if self.trailing != nil {
                        Spacer()
                        self.trailing?.createView(parentStyle: style, styleKey: nil)
                            .themeStyle(styleKey: "table-cell-subtitle-style", parentStyle: style)
                    }
                }
                .padding(self.edgeInsets)
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())      // to enable onTapGesture() even when background is .clear
            )
        }
    }
}

#if DEBUG
struct PlatformTableViewCell_Previews: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings()
    
    static var imageView: some View {
       Image(systemName: "heart.fill")
               .resizable()
               .scaledToFit()
               .frame(width: 32, height: 32)
    }
    
    static var previews: some View {
        Group {
            PlatformTableViewCellViewModel(leading: Text("2d").wrappedViewModel,
                                           logo: imageView.wrappedViewModel,
                                           main: Text("main title").wrappedViewModel,
                                           trailing: Text("trailing title").wrappedViewModel)
                .createView()
                .previewLayout(.sizeThatFits)
            
            PlatformTableViewCellViewModel(leading: PlatformView.nilViewModel,
                                           logo: imageView.wrappedViewModel,
                                           main: Text("main title").wrappedViewModel,
                                           trailing: Text("trailing title").wrappedViewModel)
                .createView()
                .previewLayout(.sizeThatFits)
            
            PlatformTableViewCellViewModel(leading: PlatformView.nilViewModel,
                                           logo: PlatformView.nilViewModel,
                                           main: Text("main title").wrappedViewModel,
                                           trailing: Text("trailing title").wrappedViewModel)
                .createView()
                .previewLayout(.sizeThatFits)
            
            PlatformTableViewCellViewModel(leading: PlatformView.nilViewModel,
                                           logo: PlatformView.nilViewModel,
                                           main: Text("main title").wrappedViewModel,
                                           trailing: PlatformView.nilViewModel)
                .createView()
                .previewLayout(.sizeThatFits)
        }
   }
}
#endif
