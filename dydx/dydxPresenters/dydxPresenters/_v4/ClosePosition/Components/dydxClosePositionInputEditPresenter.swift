//
//  dydxClosePositionInputEditPresenter.swift
//  dydxPresenters
//
//  Created by John Huang on 2/15/23.
//

import Abacus
import dydxStateManager
import dydxViews
import ParticlesKit
import PlatformParticles
import PlatformUI
import RoutingKit
import SwiftUI
import Utilities
import Combine
import dydxFormatter

protocol dydxClosePositionInputEditViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxClosePositionInputEditViewModel? { get }
}

class dydxClosePositionInputEditViewPresenter: HostedViewPresenter<dydxClosePositionInputEditViewModel>, dydxClosePositionInputEditViewPresenterProtocol {

    private lazy var sizeViewModel: dydxTradeInputSizeViewModel = {
        let viewModel = dydxTradeInputSizeViewModel(label: DataLocalizer.localize(path: "APP.GENERAL.AMOUNT"), placeHolder: "0.000")
        viewModel.onEdited = { [weak self] value in
            if let vm = self?.sizeViewModel {
                AbacusStateManager.shared.closePosition(input: value, type: ClosePositionInputField.size)
            }
        }
        return viewModel
    }()

    private let options = {
        var options = [InputSelectOption]()
        options.append(InputSelectOption(value: "0.25", string: "25%"))
        options.append(InputSelectOption(value: "0.50", string: "50%"))
        options.append(InputSelectOption(value: "0.75", string: "75%"))
        // must be 1.0 so that when double value is parsed as string, it matches for 1
        options.append(InputSelectOption(value: "1.0", string: "100%"))
        return options
    }()

    private lazy var percentViewModel: dydxClosePositionInputPercentViewModel = {
        let viewModel = dydxClosePositionInputPercentViewModel(label: DataLocalizer.localize(path: "APP.GENERAL.PERCENT"), value: nil, options: options)
        viewModel.onEdited = { [weak self] value in
            PlatformView.hideKeyboard()
            AbacusStateManager.shared.closePosition(input: value, type: ClosePositionInputField.percent)
        }
        return viewModel
    }()

    override init() {
        super.init()

        viewModel = dydxClosePositionInputEditViewModel()
    }

    override func start() {
        super.start()

        Publishers
            .CombineLatest(
                AbacusStateManager.shared.state.closePositionInput,
                AbacusStateManager.shared.state.configsAndAssetMap)
            .sink { [weak self] closePositionInput, configsAndAssetMap in
                if let closePositionInput, let marketId = closePositionInput.marketId {
                    self?.update(closePositionInput: closePositionInput, configsAndAsset: configsAndAssetMap[marketId])
                }
            }
            .store(in: &subscriptions)
    }

    private func update(closePositionInput: ClosePositionInput, configsAndAsset: MarketConfigsAndAsset?) {
        let marketConfigs = configsAndAsset?.configs
        let asset = configsAndAsset?.asset

        var visible = [PlatformValueInputViewModel]()

        sizeViewModel.placeHolder = dydxFormatter.shared.raw(number: .zero, size: marketConfigs?.stepSize?.stringValue)
        if let size = closePositionInput.size?.size {
            sizeViewModel.size = dydxFormatter.shared.raw(number: size, size: marketConfigs?.stepSize?.stringValue)
        } else {
            sizeViewModel.size = nil
        }
        if let usdcSize = closePositionInput.size?.usdcSize {
            sizeViewModel.usdcSize = dydxFormatter.shared.raw(number: usdcSize, size: "0.01")
        } else {
            sizeViewModel.usdcSize = nil
        }
        sizeViewModel.tokenSymbol = asset?.displayableAssetId ?? configsAndAsset?.assetId
        visible.append(sizeViewModel)

        if parser.asNumber(percentViewModel.value)?.doubleValue != closePositionInput.size?.percent?.doubleValue {
            percentViewModel.value = parser.asString(closePositionInput.size?.percent?.doubleValue)
        }
        visible.append(percentViewModel)

        viewModel?.children = visible
    }
}
