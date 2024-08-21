//
//  StackViewSegmentedControl.swift
//  UIToolkits
//
//  Created by Qiang Huang on 12/16/21.
//  Copyright © 2021 dYdX Trading Inc. All rights reserved.
//

import UIKit
import Utilities

@objc open class StackViewSegmentedControl: CustomSegmentedControl {
    @IBOutlet var scrollView: UIScrollView?
    @IBInspectable var unselectedBackgroundColor: UIColor?
    @IBInspectable var unselectedTintColor: UIColor?
    @IBInspectable var selectedBackgroundColor: UIColor?
    @IBInspectable var selectedTintColor: UIColor?
    
    @IBOutlet var stackView: UIStackView? {
        didSet {
            reload()
        }
    }

    public static func segments(with titles: [String]) -> SegmentedProtocol {
        let control = StackViewSegmentedControl()
        let stackView = UIStackView()
        control.stackView = stackView
        control.fill(titles: titles)
        return control
    }

    public static func segments(segments: [ControlSegment]) -> SegmentedProtocol {
        let control = StackViewSegmentedControl()
        let stackView = UIStackView()
        control.stackView = stackView
        control.fill(segments: segments)
        return control
    }

    override open func didSetSegments(oldValue: [ControlSegment]?) {
        reload()
    }
    
    private func reload() {
        if let views = stackView?.arrangedSubviews {
            for view in views {
                if let button = view as? UIButton {
                    button.removeTarget()
                }
                stackView?.removeArrangedSubview(view)
                view.removeFromSuperview()
            }
        }
        if let segments = segments, let cellXib = cellXib {
            for i in 0 ..< segments.count {
                let segment = segments[i]
                let button: UIButton? = XibLoader.load(from: cellXib)
                if let button = button {
                    button.buttonTitle = segment.text
                    button.addTarget(self, action: #selector(tap(_:)))
                    stackView?.addArrangedSubview(button)
                    select(button: button, selected: i == selectedIndex)
                }
            }
            layoutIfNeeded()
        }
    }

    override open func didSetSelectedIndex(oldValue: Int) {
        super.didSetSelectedIndex(oldValue: oldValue)
        if let buttons = stackView?.arrangedSubviews as? [UIButton] {
            if oldValue < buttons.count && oldValue != -1 {
                let button = buttons[oldValue]
                select(button: button, selected: false)
            }
            if selectedIndex < buttons.count && selectedIndex != -1 {
                let button = buttons[selectedIndex]
                select(button: button, selected: true)
            }
        }
        scroll()
    }

    private func select(button: UIButton, selected: Bool) {
        button.backgroundColor = selected ? selectedBackgroundColor : unselectedBackgroundColor
        button.buttonTitleColor = selected ? selectedTintColor : unselectedTintColor
        button.tintColor = selected ? selectedTintColor : unselectedTintColor
    }

    @IBAction func tap(_ sender: Any?) {
        if let button = sender as? UIButton {
            if let buttons = stackView?.arrangedSubviews as? [UIButton] {
                userInteracting = true
                selectedIndex = buttons.firstIndex(of: button) ?? -1
                userInteracting = false
            }
        }
    }
    
    private func scroll() {
        if let scrollView = scrollView, let subviews = stackView?.arrangedSubviews, subviews.count > selectedIndex {
            let view = subviews[selectedIndex]
            let viewRect = scrollView.convert(view.bounds, from: view)
            scrollView.scrollRectToVisible(viewRect, animated: true)
        }
    }
}
