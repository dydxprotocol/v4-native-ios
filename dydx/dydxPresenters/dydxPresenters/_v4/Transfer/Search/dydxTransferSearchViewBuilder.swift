//
//  dydxTransferSearchViewBuilder.swift
//  dydxPresenters
//
//  Created by Rui Huang on 4/10/23.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import dydxStateManager
import Abacus
import Combine
import SwiftUI

public class dydxTransferSearchViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxTransferSearchViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        return dydxTransferSearchViewController(presenter: presenter, view: view, configuration: .default) as? T
    }

    public static func createSearchRoutingRequest(options: [SelectionOption], selected: SelectionOption?, resources: TransferInputResources?, selectedCallback: @escaping ((SelectionOption?) -> Void)) -> [String: Any] {
        var params: [String: Any] = [
            "options": options,
            "selectedCallback": selectedCallback
        ]
        if let selected = selected {
            params["selected"] = selected
        }
        if let resources = resources {
            params["resources"] = resources
        }
        return params
    }
}

private class dydxTransferSearchViewController: HostingViewController<PlatformView, dydxSearchViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/transfer/search" {
            if let presenter = presenter as? dydxTransferSearchViewPresenter {
                presenter.options = request?.params?["options"] as? [SelectionOption]
                presenter.selected = request?.params?["selected"] as? SelectionOption
                presenter.resources = request?.params?["resources"] as? TransferInputResources
                presenter.selectedCallback = request?.params?["selectedCallback"] as? ((SelectionOption?) -> Void)
                if navigationController?.topViewController == self {
                    presenter.viewModel?.presentationStyle = .pushed
                }
            }
            return true
        }

        return false
    }
}

private class dydxTransferSearchViewPresenter: dydxSearchViewPresenter {
    @Published var options: [SelectionOption]?
    @Published var selected: SelectionOption?
    @Published var resources: TransferInputResources?
    @Published var selectedCallback: ((SelectionOption?) -> Void)?

    override func start() {
        super.start()

        guard let searchTextPublisher = viewModel?.$searchText else {
            return
        }

        Publishers.CombineLatest4($options.compactMap { $0 },
                                 $selected.compactMap { $0 },
                                  $resources.compactMap { $0 },
                                 searchTextPublisher.removeDuplicates())
            .sink { [weak self] options, selected, resources, searchText in
                self?.updateList(options: options, selected: selected, resources: resources, searchText: searchText)
            }
            .store(in: &subscriptions)
    }

    private func updateList(options: [SelectionOption], selected: SelectionOption, resources: TransferInputResources, searchText: String?) {
        viewModel?.itemList?.items = options.compactMap { option in
            if let searchText = searchText, searchText.isNotEmpty {
                let text = option.localizedString ?? ""
                if text.lowercased().contains(searchText.lowercased()) {
                    return createItemViewModel(option: option, resources: resources)
                } else {
                    return nil
                }
            } else {
                return createItemViewModel(option: option, resources: resources)
            }
        }
    }

    private func createItemViewModel(option: SelectionOption, resources: TransferInputResources) -> dydxTransferSearchItemViewModel {
        dydxTransferSearchItemViewModel(option: option, resources: resources, selected: option == self.selected) { [weak self] in
            self?.selectedCallback?(option)
            Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true, completion: nil)
        }
    }
}

private extension dydxTransferSearchItemViewModel {
    convenience init(option: SelectionOption, resources: TransferInputResources, selected: Bool, onTapAction: @escaping (() -> Void)) {
        self.init()
        self.text =  option.localizedString ?? ""
        if let symbol = resources.tokenResources?[option.type]?.symbol {
            self.tokenText = TokenTextViewModel(symbol: symbol)
        }
        self.isSelected = selected
        if let iconUrl = option.iconUrl, let url = URL(string: iconUrl) {
            let placeholderText = option.localizedString?.prefix(1).uppercased()
            // SwiftUI does not process svgs well
            if url.absoluteString.ends(with: ".svg") {
                self.icon = PlatformIconViewModel(url: nil, placeholderText: placeholderText)
            } else {
                self.icon = PlatformIconViewModel(url: url, placeholderText: placeholderText)
            }
        }
        self.onTapAction = onTapAction
    }
}
