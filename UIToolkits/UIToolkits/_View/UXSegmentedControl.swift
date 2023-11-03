//
//  UXSegmentedControl.swift
//  UXSegmentedControl
//
//  Created by Qiang Huang on 7/28/21.
//  Copyright © 2021 dYdX. All rights reserved.
//

import HMSegmentedControl
import UIKit

@objc public class UXSegmentedControl: HMSegmentedControl {
    override public var sectionTitles: [String]? {
        didSet {
            selectedSegmentIndex = HMSegmentedControlNoSegment
        }
    }

    override public func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.systemBackground
        segmentWidthStyle = .dynamic
        selectionIndicatorBoxColor = UIColor.link
        selectionStyle = .fullWidthStripe
        selectionIndicatorHeight = 2
        selectionIndicatorLocation = .bottom
        selectionIndicatorBoxOpacity = 0.1
        titleTextAttributes = titleAttributes
        selectedTitleTextAttributes = selectedTitleAttributes
        selectedSegmentIndex = HMSegmentedControlNoSegment
    }

    var titleAttributes: [NSAttributedString.Key: Any] {
        let font = UIFont.systemFont(ofSize: 14, weight: .medium)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.secondaryLabel,
        ]
        return attributes
    }

    var selectedTitleAttributes: [NSAttributedString.Key: Any] {
        let font = UIFont.systemFont(ofSize: 14, weight: .medium)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.link,
        ]
        return attributes
    }
}
