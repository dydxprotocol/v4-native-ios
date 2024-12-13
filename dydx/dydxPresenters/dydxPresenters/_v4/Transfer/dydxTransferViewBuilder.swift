//
//  dydxTransferViewBuilder.swift
//  dydxPresenters
//
//  Created by Rui Huang on 1/24/23.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import dydxStateManager
import FloatingPanel
import PlatformRouting
import dydxFormatter

public class dydxTransferViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxTransferViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        let viewController = dydxTransferViewController(presenter: presenter, view: view, configuration: .default)
        return viewController as? T
    }
}

private class dydxTransferViewController: HostingViewController<PlatformView, dydxTransferViewModel> {

    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/transfer" {
            if let section = request?.params?["section"] as? String {
                (presenter as? dydxTransferViewPresenterProtocol)?.startingAt = TransferSection(rawValue: section)
            }
            return true
        }
        return false
    }
}

public enum TransferSection: String {
    case deposit, withdrawal, transferOut

    var sectionIndex: Int {
        switch self {
        case .deposit:
            return 0
        case .withdrawal:
            return 1
        case .transferOut:
            return 2
        }
    }
}

private protocol dydxTransferViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxTransferViewModel? { get }
    var startingAt: TransferSection? { get set }
}

private class dydxTransferViewPresenter: HostedViewPresenter<dydxTransferViewModel>, dydxTransferViewPresenterProtocol {
    var startingAt: TransferSection?

    private let depositPresenter = dydxTransferDepositViewPresenter()
    private let withdrawalPresenter = dydxTransferWithdrawalViewPresenter()
    private let transferOutPresenter = dydxTransferOutViewPresenter()

    private lazy var childPresenters: [HostedViewPresenterProtocol] = []

    private lazy var selectionPresenters: [dydxTransferSectionsViewModel.TransferSection: HostedViewPresenterProtocol] = [
        .deposit: depositPresenter,
        .withdraw: withdrawalPresenter,
        .transferOut: transferOutPresenter
    ]

    override init() {
        let viewModel = dydxTransferViewModel()

        depositPresenter.$viewModel.assign(to: &viewModel.$deposit)
        withdrawalPresenter.$viewModel.assign(to: &viewModel.$withdrawal)
        transferOutPresenter.$viewModel.assign(to: &viewModel.$transferOut)

        super.init()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [weak self] in
            AbacusStateManager.shared.startTrade()
            AbacusStateManager.shared.startTransfer()
            self?.setDefaultSection()
        }

        viewModel.faucet.valueSelected = { amount in
            AbacusStateManager.shared.faucet(amount: Int32(amount))
            Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true, completion: nil)
            ErrorInfo.shared?.info(title: "Faucet Request Submitted",
                                   message: "Your portofolio balance will be updated after a short while.",
                                   type: .success,
                                   error: nil, time: nil)
            HapticFeedback.shared?.notify(type: .success)
        }

        self.viewModel = viewModel

        attachChildren(workers: childPresenters)
    }

    override func start() {
        super.start()

        resetPresentersForVisibilityChange()
    }

    override func stop() {
        super.stop()

        for (_, presenter) in selectionPresenters {
            presenter.stop()
        }
    }

    private func setDefaultSection() {
        if let startingAt = startingAt {
            updateSections()
            setCurrentSection(index: startingAt.sectionIndex)
        } else if AbacusStateManager.shared.isMainNet {
            updateSections()
            if let key = Section.allSections.first?.key {
                viewModel?.sectionSelection = key
                viewModel?.sections.sectionIndex = 0
            }
        } else {
            // default to Faucet if no subaccount
            AbacusStateManager.shared.state.hasAccount
                .prefix(1)
                .sink { [weak self] hasAccount in
                     self?.updateSections()

                    if hasAccount {
                        if let key = Section.allSections.first?.key {
                            self?.viewModel?.sectionSelection = key
                            self?.viewModel?.sections.sectionIndex = 0
                        }
                    } else {
                        self?.viewModel?.sectionSelection = .faucet
                        self?.viewModel?.sections.sectionIndex = Section.indexOf(sectionKey: .faucet)
                    }

                    self?.selectionPresenters.values.forEach { presenter in
                        presenter.stop()
                    }
                    self?.resetPresentersForVisibilityChange()
                }
                .store(in: &subscriptions)
        }
    }

    private func updateSections() {
        let sections = Section.allSections

        viewModel?.sections.itemTitles = sections.map(\.text)
        viewModel?.sections.onSelectionChanged = { [weak self] index in
            self?.setCurrentSection(index: index)
        }
    }

    private func setCurrentSection(index: Int) {
        let sections = Section.allSections
        if index < sections.count {
            let selectedSection = sections[index]
            viewModel?.sectionSelection = selectedSection.key
            viewModel?.sections.sectionIndex = index
            resetPresentersForVisibilityChange()
        }
    }

    private func resetPresentersForVisibilityChange() {
        for (key, presenter) in selectionPresenters {
            if key == viewModel?.sectionSelection {
                if presenter.isStarted == false {
                    presenter.start()
                }
            } else if presenter.isStarted {
                presenter.stop()
           }
        }
    }
}

// MARK: Section

private struct Section: Equatable {
    let text: String
    let key: dydxTransferSectionsViewModel.TransferSection

    private static var depositSection: Section {
        Self(text: DataLocalizer.localize(path: "APP.GENERAL.DEPOSIT"), key: .deposit)
    }
    private static var withdrawalSection: Section {
        Self(text: DataLocalizer.localize(path: "APP.GENERAL.WITHDRAW"), key: .withdraw)
    }
    private static var transferOutSection: Section {
        Self(text: DataLocalizer.localize(path: "APP.GENERAL.TRANSFER"), key: .transferOut)
    }
    private static var faucetSection: Section {
        Self(text: "Faucet", key: .faucet)
    }

    static var allSections: [Section] {
        [
            .depositSection,
            .withdrawalSection,
            .transferOutSection,
            !AbacusStateManager.shared.isMainNet ? .faucetSection : nil
        ]
        .filterNils()
    }

    static func indexOf(sectionKey: dydxTransferSectionsViewModel.TransferSection) -> Int? {
        allSections.firstIndex { $0.key == sectionKey }
    }
}
