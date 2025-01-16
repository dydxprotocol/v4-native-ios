//
//  IntervalText.swift
//  dydxUI
//
//  Created by Rui Huang on 4/27/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities
import Combine
import dydxFormatter

public class IntervalTextModel: PlatformViewModel, Equatable {
    public enum Direction {
        case countDown, countUp, countDownToHour
    }
    public enum Format {
        case full, short
    }
    @Published public var date: Date?
    @Published public var direction: Direction = .countUp
    @Published public var format: Format = .short

    private var timer: Timer?
    private var cancellable = [AnyCancellable]()

    @Published private var dateText: String?

    public static func == (lhs: IntervalTextModel, rhs: IntervalTextModel) -> Bool {
        lhs.date == rhs.date &&
        lhs.direction == rhs.direction &&
        lhs.format == rhs.format
    }

    public init(date: Date?, direction: Direction = .countUp, format: Format = .short) {
        self.date = date
        self.direction = direction
        self.format = format
        super.init()

        $date
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.resetTimer()
            }
            .store(in: &cancellable)
    }

    deinit {
        timer?.invalidate()
    }

    private func resetTimer() {
        timer?.invalidate()
        dateText = nil

        if self.direction == .countDownToHour {
            let now = Date()
            if date == nil || now > date! {
                date = now.nextHour
            }
        }
        let timerInterval: TimeInterval?
        switch self.format {
        case .short:
            timerInterval = self.timerInterval
        case .full:
            timerInterval = 1
        }

        if let timerInterval = timerInterval {
            displayDate()
            timer = Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true) { [weak self] _ in
                self?.displayDate()
            }
        }
    }

    private func displayDate() {
        if self.timerInterval != nil {
            switch self.format {
            case .short:
                dateText = dydxFormatter.shared.interval(time: date)
            case .full:
                if let date = date {
                    dateText = dydxFormatter.shared.time(time: date)
                }
            }
        } else {
            dateText = nil
        }
    }

    private var timerInterval: TimeInterval? {
        guard let date = date else {
            return nil
        }

        let interval: TimeInterval
        switch direction {
        case .countUp:
            interval = Date().timeIntervalSince(date)
        case .countDown, .countDownToHour:
            interval = date.timeIntervalSince(Date())
        }

        if interval > 0 {
            if interval <= 60 {
                return 1
            }
            if interval <= 60 * 60 {
                return 60
            }
            return 60 * 60 * 24
        }

        return nil
    }

    public static var previewValue: IntervalTextModel {
        let vm = IntervalTextModel(date: Date())
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return AnyView(
                Text(self.dateText ?? "")
            )
        }
    }
}

#if DEBUG
struct IntervalText_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return IntervalTextModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct IntervalText_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return IntervalTextModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
