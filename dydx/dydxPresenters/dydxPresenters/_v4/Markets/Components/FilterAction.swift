//
//  FilterAction.swift
//  dydxPresenters
//
//  Created by Rui Huang on 15/11/2024.
//

import Utilities
import PlatformUI
import Abacus
import dydxStateManager
import dydxFormatter

// MARK: Filter

struct FilterAction: Equatable {
    static var defaultAction: FilterAction {
        FilterAction(type: .all,
                     content: .text(DataLocalizer.localize(path: "APP.GENERAL.ALL")),
                     action: { _, _ in
                         true       // included
                     })
    }

    static var actions: [FilterAction] {
        var actions = [
            .defaultAction,

            FilterAction(type: .favorited,
                         content: .icon(UIImage.named("action_like_unselected", bundles: Bundle.particles) ?? UIImage()),
                         action: { market, _ in
                             dydxFavoriteStore().isFavorite(marketId: market.id)
                         }),

            FilterAction(type: .new,
                         content: .text(DataLocalizer.localize(path: "APP.GENERAL.RECENTLY_LISTED")),
                         action: { market, _ in
                             market.perpetual?.isNew ?? false
                         })
        ]
        if dydxBoolFeatureFlag.showPredictionMarketsUI.isEnabled {
            let predictionMarketText = DataLocalizer.localize(path: "APP.GENERAL.PREDICTION_MARKET")
            let newPillConfig = TabItemViewModel.TabItemContent.PillConfig(text: DataLocalizer.localize(path: "APP.GENERAL.NEW"),
                                                                           textColor: .colorPurple,
                                                                           backgroundColor: .colorFadedPurple)
            let content = TabItemViewModel.TabItemContent.textWithPillAccessory(text: predictionMarketText,
                                                                                pillConfig: newPillConfig)
            let predictionMarketsAction = FilterAction(type: .predictionMarkets,
                                                       content: content,
                                                       action: { market, assetMap in
                                                            assetMap[market.assetId]?.tags?.contains("Prediction Market") ?? false
                                                       })
            actions.append(predictionMarketsAction)
        }
        actions.append(contentsOf: [
            FilterAction(type: .meme,
                        content: .text(DataLocalizer.localize(path: "APP.GENERAL.MEME")),
                        action: { market, assetMap in
                            assetMap[market.assetId]?.tags?.contains("memes") ?? false
                        }),

            FilterAction(type: .ai,
                         content: .text(DataLocalizer.localize(path: "APP.GENERAL.AI")),
                         action: { market, assetMap in
                             assetMap[market.assetId]?.tags?.contains("ai-big-data") ?? false
                         }),

            FilterAction(type: .defi,
                         content: .text(DataLocalizer.localize(path: "APP.GENERAL.DEFI")),
                         action: { market, assetMap in
                             assetMap[market.assetId]?.tags?.contains("defi") ?? false
                         }),

            FilterAction(type: .depin,
                         content: .text(DataLocalizer.localize(path: "APP.GENERAL.DEPIN")),
                         action: { market, assetMap in
                             assetMap[market.assetId]?.tags?.contains("depin") ?? false
                         }),

            FilterAction(type: .layer1,
                         content: .text(DataLocalizer.localize(path: "APP.GENERAL.LAYER_1")),
                         action: { market, assetMap in
                             assetMap[market.assetId]?.tags?.contains("layer-1") ?? false
                         }),

            FilterAction(type: .layer2,
                         content: .text(DataLocalizer.localize(path: "APP.GENERAL.LAYER_2")),
                         action: { market, assetMap in
                             assetMap[market.assetId]?.tags?.contains("layer-2") ?? false
                         }),

            FilterAction(type: .rwa,
                         content: .text(DataLocalizer.localize(path: "APP.GENERAL.REAL_WORLD_ASSET_SHORT")),
                         action: { market, assetMap in
                             assetMap[market.assetId]?.tags?.contains("real-world-assets") ?? false
                         }),

            FilterAction(type: .gaming,
                         content: .text(DataLocalizer.localize(path: "APP.GENERAL.GAMING")),
                         action: { market, assetMap in
                             assetMap[market.assetId]?.tags?.contains("gaming") ?? false
                         }),

            FilterAction(type: .ent,
                         content: .text(DataLocalizer.localize(path: "APP.GENERAL.FOREX")),
                         action: { market, assetMap in
                             assetMap[market.assetId]?.tags?.contains("fiat") ?? false
                         })
        ])
        return actions
    }

    let type: MarketFiltering
    let content: TabItemViewModel.TabItemContent
    let action: ((PerpetualMarket, [String: Asset]) -> Bool)

    static func == (lhs: FilterAction, rhs: FilterAction) -> Bool {
        lhs.type == rhs.type
    }
}

enum MarketFiltering: Equatable {
    case all
    case favorited
    case predictionMarkets
    case layer1
    case layer2
    case defi
    case depin
    case new
    case ai
    case nft
    case gaming
    case meme
    case rwa
    case ent
}
