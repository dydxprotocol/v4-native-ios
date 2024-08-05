//
//  dydxVaultChartViewModel.swift
//  dydxViews
//
//  Created by Michael Maguire on 8/2/24.
//

import Foundation
import PlatformUI
import SwiftUI
import Utilities

private protocol RadioButtonContentDisplayable: Equatable {
    var displayText: String { get }
}

public class dydxVaultChartViewModel: PlatformViewModel {
    @Published var selectedValueType: ValueTypeOption = .pnl
    @Published var selectedValueTime: ValueTimeOption = .oneDay
    
    fileprivate let valueTypeOptions = ValueTypeOption.allCases
    fileprivate let valueTimeOptions = ValueTimeOption.allCases

    public enum ValueTypeOption: CaseIterable, RadioButtonContentDisplayable {
        case pnl
        case equity
        
        var displayText: String {
            let path: String
            switch self {
            case .pnl:
                path = "APP.VAULTS.VAULT_PNL"
            case .equity:
                path = "APP.VAULTS.VAULT_EQUITY"
            }
            return DataLocalizer.shared?.localize(path: path, params: nil) ?? ""
        }
    }
    
    public enum ValueTimeOption: CaseIterable, RadioButtonContentDisplayable {
        case oneDay
        case sevenDays
        case thirtyDays
        
        var displayText: String {
            let path: String
            switch self {
            case .oneDay:
                path = "1d"
            case .sevenDays:
                path = "7d"
            case .thirtyDays:
                path = "30d"
            }
            return path
        }
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _  in
            guard let self = self else { return AnyView(PlatformView.nilView) }
            return AnyView(dydxVaultChartView(viewModel: self)).wrappedInAnyView()
        }
    }
}

private struct dydxVaultChartView: View {
    @ObservedObject var viewModel: dydxVaultChartViewModel
    
    var body: some View {
        HStack(spacing: 0) {
            RadioButtonGroup(selected: $viewModel.selectedValueType, 
                             options: viewModel.valueTypeOptions,
                             buttonClipStyle: .capsule,
                             itemWidth: nil,
                             itemHeight: 40
            )
            Spacer()
            RadioButtonGroup(selected: $viewModel.selectedValueTime, 
                             options: viewModel.valueTimeOptions,
                             buttonClipStyle: .circle,
                             itemWidth: 40,
                             itemHeight: 40
            )
        }
                        
    }
}

fileprivate struct RadioButtonGroup<Content: RadioButtonContentDisplayable>: View {
    
    @Binding fileprivate var selected: Content

    fileprivate let options: [Content]

    fileprivate let buttonClipStyle: ClipStyle
    fileprivate let itemWidth: CGFloat?
    fileprivate let itemHeight: CGFloat?

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<options.count, id: \.self) { index in
                let option = options[index]
                RadioButton(displayText: option.displayText,
                            isSelected: selected == option,
                            clipStyle: buttonClipStyle, 
                            width: itemWidth,
                            height: itemHeight
                ) {
                    selected = option
                }
            }
        }
    }
}

fileprivate struct RadioButton: View {
    fileprivate let displayText: String
    fileprivate let isSelected: Bool
    fileprivate let clipStyle: ClipStyle
    fileprivate let width: CGFloat?
    fileprivate let height: CGFloat?
    fileprivate let selectionAction: () -> Void

    private var verticalSpacer: some View {
        Spacer(minLength: 11)
    }
    
    private var horizontalSpacer: some View {
        Spacer(minLength: 8)
    }
    
    var body: some View {
        Text(displayText)
            .lineLimit(1)
            .themeColor(foreground: isSelected ? .textPrimary : .textTertiary)
            .themeFont(fontType: .base, fontSize: .smaller)
            // if width is specified, i.e. non-nil, setting horizontal inset to 0 will allow entire space to be used horizontally
            .padding(.horizontal, width == nil ? 8 : 0)
            // if height is specified, i.e. non-nil, setting vertical inset to 0 will allow entire space to be used horizontally
            .padding(.horizontal, width == nil ? 8 : 0)
            .centerAligned()
            .frame(width: width, height: height)
            .fixedSize()
            .themeColor(background: isSelected ? .layer1 : .layer3)
            .borderAndClip(style: clipStyle, borderColor: .borderDefault)
            .onTapGesture {
                selectionAction()
            }
    }
}
