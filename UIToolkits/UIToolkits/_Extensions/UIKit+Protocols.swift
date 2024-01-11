//
//  UILabel+Protocol.swift
//  UIToolkits
//
//  Created by Qiang Huang on 12/11/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import MaterialActivityIndicator
import UIKit
import Utilities
import Combine

extension UIView: ViewProtocol {
    public var visible: Bool {
        get { return !isHidden }
        set {
            if isHidden != !newValue {
                isHidden = !newValue
            }
        }
    }
}

extension UIActivityIndicatorView: SpinnerProtocol {
    public var spinning: Bool {
        get { return isAnimating }
        set {
            if newValue {
                startAnimating()
            } else {
                stopAnimating()
            }
        }
    }
}

extension MaterialActivityIndicatorView: SpinnerProtocol, CombineObserving {
    fileprivate struct SpinnerKey {
        static var reallySpinning = "MaterialActivityIndicatorView.reallySpinning"
        static var spinning = "MaterialActivityIndicatorView.spinning"
        static var appState = "MaterialActivityIndicatorView.appState"
        static var cancellableMap = "MaterialActivityIndicatorView.cancellableMap"
    }

    var _spinning: Bool {
        get {
            let isSpinning: NSNumber? = associatedObject(base: self, key: &SpinnerKey.reallySpinning)
            return isSpinning?.boolValue ?? false
        }
        set {
            let oldValue = _spinning
            if oldValue != newValue {
                let isSpinning: NSNumber = NSNumber(value: newValue)
                retainObject(base: self, key: &SpinnerKey.reallySpinning, value: isSpinning)
                if newValue {
                    startAnimating()
                } else {
                    stopAnimating()
                }
            }
        }
    }

    public var cancellableMap: [AnyKeyPath: AnyCancellable] {
        get {
            associatedObject(base: self, key: &SpinnerKey.cancellableMap) {
                [AnyKeyPath: AnyCancellable]()
            }
        }
        set {
            retainObject(base: self, key: &SpinnerKey.cancellableMap, value: newValue)
        }
    }

    public var spinning: Bool {
        get {
            let isSpinning: NSNumber? = associatedObject(base: self, key: &SpinnerKey.spinning)
            return isSpinning?.boolValue ?? false
        }
        set {
            let oldValue = spinning
            if oldValue != newValue {
                let isSpinning: NSNumber = NSNumber(value: newValue)
                retainObject(base: self, key: &SpinnerKey.spinning, value: isSpinning)
                if appState?.background == false {
                    _spinning = newValue
                }
            }
        }
    }

    private var appState: AppState? {
        get {
            return associatedObject(base: self, key: &SpinnerKey.appState)
        }
        set {
            let oldValue = appState
            if oldValue !== newValue {
                retainObject(base: self, key: &SpinnerKey.appState, value: newValue)
                changeObservation(from: oldValue, to: appState, keyPath: #keyPath(AppState.background)) { [weak self] _, _, _, animated in
                    if self?.appState?.background == false {
                        self?._spinning = self?.spinning ?? false
                    } else {
                        self?._spinning = false
                    }
                }
            }
        }
    }

    override public func awakeFromNib() {
        super.awakeFromNib()
        appState = AppState.shared
    }
}

extension UILabel: LabelProtocol {
    public func formatUrl(text: String?) -> URL? {
        if let text = text {
            if let ranges = text.detectHttpUrl() {
                let styledText = NSMutableAttributedString(string: text)

                for range in ranges {
                    styledText.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
                    styledText.addAttribute(NSAttributedString.Key.foregroundColor, value: ColorPalette.shared.color(system: "blue") ?? UIColor.blue, range: range)
                }
                self.text = nil
                attributedText = styledText
                if let first = ranges.first, let range = Range(first, in: text) {
                    let urlString = String(text[range])
                    return URL(string: urlString)
                }
                return nil
            } else {
                attributedText = nil
                self.text = text
                return nil
            }
        } else {
            attributedText = nil
            self.text = nil
            return nil
        }
    }
}

extension UITextField: LabelProtocol {
    public func formatUrl(text: String?) -> URL? {
        if let text = text, let ranges = text.detectHttpUrl() {
            let styledText = NSMutableAttributedString(string: text)

            for range in ranges {
                styledText.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
            }
            attributedText = styledText
            if let first = ranges.first, let range = Range(first, in: text) {
                let urlString = String(text[range])
                return URL(string: urlString)
            }
            return nil
        } else {
            self.text = text
            return nil
        }
    }
}

extension UIImageView: ImageViewProtocol {
}

extension UIControl: ControlProtocol {
    public func removeTarget() {
        removeTarget(nil, action: nil, for: .allEvents)
    }

    public func addTarget(_ target: AnyObject?, action: Selector) {
        removeTarget()
        addTarget(target, action: action, for: .touchUpInside)
    }

    public func add(target: AnyObject?, action: Selector, for controlEvents: UIControl.Event) {
        addTarget(target, action: action, for: controlEvents)
    }
}

extension UIButton: ButtonProtocol {
    open var buttonTitle: String? {
        get {
            return title(for: .normal)
        }
        set {
            setTitle(newValue, for: .normal)
        }
    }

    public var buttonImage: UIImage? {
        get {
            return image(for: .normal)
        }
        set {
            DispatchQueue.runInMainThread { [weak self] in
                self?.setImage(newValue, for: .normal)
            }
        }
    }

    public var buttonChecked: Bool {
        get {
            return isSelected
        }
        set {
            isSelected = newValue
        }
    }

    public var buttonTitleColor: UIColor? {
        get {
            return titleColor(for: .normal)
        }
        set {
            setTitleColor(newValue, for: .normal)
        }
    }
}

extension UIBarButtonItem: ButtonProtocol {
    public var backgroundColor: NativeColor! {
        get {
            return UIColor.clear
        }
        set {
        }
    }

    public var buttonTitle: String? {
        get {
            return title
        }
        set {
            title = newValue
        }
    }

    public var buttonImage: NativeImage? {
        get {
            return image
        }
        set {
            image = newValue
        }
    }

    public var buttonChecked: Bool {
        get {
            return checked
        }
        set {
            checked = newValue
        }
    }

    public var frame: CGRect {
        get {
            return CGRect()
        }
        set {
        }
    }

    public var visible: Bool {
        get {
            return isEnabled
        }
        set {
            isEnabled = newValue
        }
    }

    public var checked: Bool {
        get {
            return tintColor == UIColor.blue
        }
        set {
            tintColor = newValue ? UIColor.blue : UIColor.darkGray
        }
    }

    public func removeTarget() {
        target = nil
        action = nil
    }

    public func addTarget(_ target: AnyObject?, action: Selector) {
        self.target = target
        self.action = action
    }

    public func add(target: AnyObject?, action: Selector, for controlEvents: UIControl.Event) {
        addTarget(target, action: action)
    }
}

extension UISegmentedControl: SegmentedProtocol {
    public var selectedIndex: Int {
        get {
            return selectedSegmentIndex
        }
        set {
            selectedSegmentIndex = newValue
        }
    }

    @objc public func fill(titles: [String]?) {
        removeAllSegments()
        if let titles = titles {
            for title in titles {
                insertSegment(withTitle: title, at: numberOfSegments, animated: false)
            }
        }
    }

    public static func segments(with titles: [String]) -> SegmentedProtocol {
        let segments = UISegmentedControl()
        segments.fill(titles: titles)
        return segments
    }

    override public func addTarget(_ target: AnyObject?, action: Selector) {
        removeTarget()
        addTarget(target, action: action, for: .valueChanged)
    }
}
