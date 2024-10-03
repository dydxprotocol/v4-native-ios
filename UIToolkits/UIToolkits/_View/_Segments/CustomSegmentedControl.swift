//
//  CustomSegmentedControl.swift
//  UIToolkits
//
//  Created by Qiang Huang on 12/16/21.
//  Copyright © 2021 dYdX Trading Inc. All rights reserved.
//

import UIKit

@objc open class ControlSegment: NSObject {
    @objc public dynamic var text: String?
    @objc public dynamic var image: String?
    @objc public dynamic var selectedImage: String?

    public init(text: String?, image: String?, selectedImage: String? = nil) {
        super.init()
        self.text = text
        self.image = image
        self.selectedImage = selectedImage
    }
}

@objc open class CustomSegmentedControl: UIControl, SegmentedProtocol {
    internal var segments: [ControlSegment]? {
        didSet {
            didSetSegments(oldValue: oldValue)
        }
    }

    internal var selectedSegment: ControlSegment?

    internal var userInteracting: Bool = false

    public var numberOfSegments: Int {
        return segments?.count ?? 0
    }

    open var selectedIndex: Int {
        get {
            if let selectedSegment = selectedSegment {
                return segments?.firstIndex(of: selectedSegment) ?? -1
            } else {
                return -1
            }
        }
        set(newValue) {
            if newValue < numberOfSegments {
                let oldValue = selectedIndex
                if newValue != oldValue {
                    if newValue != -1 {
                        selectedSegment = segments?[newValue]
                    } else {
                        selectedSegment = nil
                    }

                    didSetSelectedIndex(oldValue: oldValue)
                }
            }
        }
    }

    @IBInspectable internal var cellXib: String?

    open func didSetSegments(oldValue: [ControlSegment]?) {
    }

    open func didSetSelectedIndex(oldValue: Int) {
        if userInteracting, selectedIndex != oldValue {
            sendActions(for: .valueChanged)
        }
    }

    open func fill(titles: [String]?) {
        if let titles = titles {
            let segments = titles.map { text -> ControlSegment in
                let segment = ControlSegment(text: text, image: nil, selectedImage: nil)
                return segment
            }
            self.segments = segments
        } else {
            segments = nil
        }
    }

    open func fill(titles: [String]?, images: [String]?) {
        if let titles = titles, let images = images, titles.count == images.count {
            var segments = [ControlSegment]()
            for i in 0 ..< titles.count {
                let segment = ControlSegment(text: titles[i], image: images[i], selectedImage: nil)
                segments.append(segment)
            }
            self.segments = segments
        } else {
            segments = nil
        }
    }

    open func fill(segments: [ControlSegment]?) {
        self.segments = segments
    }
}
