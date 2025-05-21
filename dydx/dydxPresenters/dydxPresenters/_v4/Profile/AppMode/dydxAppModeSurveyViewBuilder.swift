//
//  dydxAppModeSurveyViewBuilder.swift
//  dydxPresenters
//
//  Created by Rui Huang on 10/04/2025.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import dydxAnalytics
import Abacus

public class dydxAppModeSurveyViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxAppModeSurveyViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        return dydxAppModeSurveyViewController(presenter: presenter, view: view, configuration: .fullScreenSheet) as? T
    }
}

private class dydxAppModeSurveyViewController: HostingViewController<PlatformView, dydxAppModeSurveyViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/settings/app_mode_survey" {
            return true
        }
        return false
    }
}

private protocol dydxAppModeSurveyViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxAppModeSurveyViewModel? { get }
}

private class dydxAppModeSurveyViewPresenter: HostedViewPresenter<dydxAppModeSurveyViewModel>, dydxAppModeSurveyViewPresenterProtocol {
    private let surveyOptionKeys = [
        "SURVEY.SIMPLE_TO_PRO.OPTION_1",
        "SURVEY.SIMPLE_TO_PRO.OPTION_2",
        "SURVEY.SIMPLE_TO_PRO.OPTION_3"
    ]
    private var selectedKeys = Set<String>()

    override init() {
        super.init()

        viewModel = dydxAppModeSurveyViewModel()
        viewModel?.submitAction = { [weak self] in
            SettingsStore.shared?.setValue(false, forDydxKey: .showAppModeSurvey)
            self?.logSubmission()
            self?.switchMode()
        }
        viewModel?.doNotShowAction = { [weak self] in
            SettingsStore.shared?.setValue(false, forDydxKey: .showAppModeSurvey)
            self?.logDontShowAgain()
            self?.switchMode()
        }
        viewModel?.feedbackAction = { [weak self] in
            self?.setCanSumbit()
        }
        createOptions()
    }

    override func onHalfSheetDismissal() {
        super.onHalfSheetDismissal()

        logCancel()
        switchMode()
    }

    private func switchMode() {
        navigate(to: RoutingRequest(path: "/action/mode/switch",
                                    params: ["mode": "pro"]),
                 animated: true, completion: nil)
    }

    private func createOptions() {
        var options: [dydxAppModeSurveyViewModel.OptionItem] = []
        for optionKey in surveyOptionKeys {
            let option = dydxAppModeSurveyViewModel.OptionItem(
                text: DataLocalizer.localize(path: optionKey),
                isSelected: selectedKeys.contains(optionKey),
                selectionAction: { [weak self] in
                    guard let self else { return }
                    if self.selectedKeys.contains(optionKey) {
                        self.selectedKeys.remove(optionKey)
                    } else {
                        self.selectedKeys.insert(optionKey)
                    }
                    self.createOptions()
                    self.setCanSumbit()
                }
            )
            options.append(option)
        }
        viewModel?.options = options
    }

    private func setCanSumbit() {
        viewModel?.canSubmit = !selectedKeys.isEmpty ||
            viewModel?.feedbackText?.trimmingCharacters(in: .whitespacesAndNewlines).isNotEmpty ?? false
    }

    private func logSubmission() {
        let event = ClientTrackableEventType.AppModeSurveyEvent(
            option1: selectedKeys.contains(surveyOptionKeys[0]),
            option2: selectedKeys.contains(surveyOptionKeys[1]),
            option3: selectedKeys.contains(surveyOptionKeys[2]),
            feedback: viewModel?.feedbackText,
            isSubmit: true,
            isDoNotShowAgain: false
        )
        Tracking.shared?.logSharedEvent(event)
    }

    private func logDontShowAgain() {
        let event = ClientTrackableEventType.AppModeSurveyEvent(
            option1: false,
            option2: false,
            option3: false,
            feedback: nil,
            isSubmit: false,
            isDoNotShowAgain: true
        )
        Tracking.shared?.logSharedEvent(event)
    }

    private func logCancel() {
        let event = ClientTrackableEventType.AppModeSurveyEvent(
            option1: false,
            option2: false,
            option3: false,
            feedback: nil,
            isSubmit: false,
            isDoNotShowAgain: false
        )
        Tracking.shared?.logSharedEvent(event)
    }
}
