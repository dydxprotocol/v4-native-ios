//
//  UIProtocols.swift
//  UIToolkits
//
//  Created by Qiang Huang on 12/11/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

#if _macOS

    import Cocoa

    public typealias NativeColor = NSColor
    public typealias NativeFont = NSFont
    public typealias NativeImage = NSImage

#elseif _watchOS

    import WatchKit

    public typealias NativeColor = UIColor
    public typealias NativeFont = UIFont
    public typealias NativeImage = UIImage

#else

    import UIKit

    public typealias NativeColor = UIColor
    public typealias NativeFont = UIFont
    public typealias NativeImage = UIImage

#endif

@objc public protocol ViewProtocol: AnyObject {
    @objc var visible: Bool { get set }
    @objc var frame: CGRect { get set }
    @objc var backgroundColor: NativeColor! { get set }
}

@objc public protocol SpinnerProtocol: ViewProtocol {
    @objc var spinning: Bool { get set }
}

@objc public protocol LabelProtocol: ViewProtocol {
    @objc var attributedText: NSAttributedString? { get set }
    @objc var text: String? { get set }
    @objc var textColor: NativeColor! { get set }
    @objc var font: NativeFont! { get set }

    func formatUrl(text: String?) -> URL?
}

@objc public protocol ImageViewProtocol: ViewProtocol {
    @objc var image: NativeImage? { get set }
    @objc optional var imageUrl: String? { get set }
}

@objc public protocol ControlProtocol: ViewProtocol {
    @objc func removeTarget()
    @objc func addTarget(_ target: AnyObject?, action: Selector)
    @objc func add(target: AnyObject?, action: Selector, for controlEvents: UIControl.Event)
}

@objc public protocol ButtonProtocol: ControlProtocol {
    @objc var buttonTitle: String? { get set }
    @objc var buttonImage: NativeImage? { get set }
    @objc var buttonChecked: Bool { get set }
}

@objc public protocol SegmentedProtocol: ControlProtocol {
    @objc var numberOfSegments: Int { get }
    @objc var selectedIndex: Int { get set }

    @objc func fill(titles: [String]?)
}

@objc public protocol WaitProtocol: ViewProtocol {
    @objc var waiting: Bool { get set }
}
