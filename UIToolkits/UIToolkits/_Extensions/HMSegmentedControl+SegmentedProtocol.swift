//
//  HMSegmentedControl+SegmentedProtocol.swift
//  UIToolkits
//
//  Created by Qiang Huang on 12/26/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import HMSegmentedControl
import ObjectiveC

extension HMSegmentedControl: SegmentedProtocol {
    public var selectedIndex: Int {
        get {
            if selectedSegmentIndex == HMSegmentedControlNoSegment {
                return -1
            } else {
                return Int(selectedSegmentIndex)
            }
        }
        set {
            if numberOfSegments != 0 {
                if newValue == -1 || newValue >= 0 && newValue < numberOfSegments {
                    setSelectedSegmentIndex(UInt(newValue), animated: true)
                }
            }
        }
    }

    public var numberOfSegments: Int {
        return sectionTitles?.count ?? 0
    }

    @objc public func fill(titles: [String]?) {
        selectedSegmentIndex = HMSegmentedControlNoSegment
        sectionTitles = titles
    }

    public static func segments(with titles: [String]) -> SegmentedProtocol {
        let segments = HMSegmentedControl(sectionTitles: titles)
        segments.selectionIndicatorLocation = .bottom
        segments.selectionStyle = .fullWidthStripe
        segments.selectionIndicatorHeight = 4.0
        segments.frame = CGRect(x: 0, y: 0, width: 180, height: 44)
        return segments
    }
}
