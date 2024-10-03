//
//  AnimationBlock.swift
//  UIToolkits
//
//  Created by John Huang on 10/24/18.
//  Copyright © 2019 dYdX. All rights reserved.
//

import Foundation
import QuartzCore

public enum AnimationType {
    case none
    case curl
    case flip
    case resolve
    case fade
    case push
    case reveal
    case move
}

public enum AnimationDirection {
    case none
    case up
    case down
    case left
    case right
}

public typealias AnimationBlock = () -> Void
public typealias AnimationCompletionBlock = (Bool) -> Void

public extension UIView {
    static var defaultAnimationDuration: TimeInterval { return 0.15 }
    static var fastAnimationDuration: TimeInterval { return 0.05 }
    static func animate(_ view: UIView?, type: AnimationType, direction: AnimationDirection, duration: TimeInterval, animations: @escaping AnimationBlock, completion: AnimationCompletionBlock?) {
        if let view = view {
            switch type {
            case .curl:
                fallthrough
            case .flip:
                fallthrough
            case .resolve:
                UIView.transition(with: view, duration: duration, options: transition(type, direction: direction), animations: { animations() }, completion: completion)

            case .fade:
                fallthrough
            case .push:
                fallthrough
            case .reveal:
                fallthrough
            case .move:
                UIView.layerTransition(view, type: type, direction: direction, duration: duration, animations: animations, completion: completion)
                default:
                animations()
                completion?(false)
            }
        } else {
            animations()
            completion?(false)
        }
    }

    private static func transition(_ type: AnimationType, direction: AnimationDirection) -> UIView.AnimationOptions {
        switch type {
        case .curl:
            switch direction {
            case .up:
                return .transitionCurlUp

            case .down:
                return .transitionCurlDown

            default:
                return .transitionCurlUp
            }

        case .flip:
            switch direction {
            case .left:
                return .transitionFlipFromRight

            case .right:
                return .transitionFlipFromLeft

            case .up:
                return .transitionFlipFromBottom

            case .down:
                return .transitionFlipFromTop

            default:
                return .transitionFlipFromRight
            }

        default:
            return .transitionCrossDissolve
        }
    }

    private static func transitionType(_ type: AnimationType) -> CATransitionType {
        switch type {
        case .push:
            return CATransitionType.push

        case .reveal:
            return CATransitionType.reveal

        case .move:
            return CATransitionType.moveIn

        case .fade:
            return CATransitionType.fade

        default:
            return CATransitionType.fade
        }
    }

    private static func transitionSubtype(direction: AnimationDirection) -> CATransitionSubtype? {
        switch direction {
        case .up:
            return CATransitionSubtype.fromBottom

        case .down:
            return CATransitionSubtype.fromTop

        case .left:
            return CATransitionSubtype.fromRight

        case .right:
            return CATransitionSubtype.fromTop

        default:
            return nil
        }
    }

    private static func layerTransition(_ view: UIView?, type: AnimationType, direction: AnimationDirection, duration: TimeInterval, animations: @escaping AnimationBlock, completion: AnimationCompletionBlock?) {
        CATransaction.begin()
        if let completion = completion {
            CATransaction.setCompletionBlock({
                completion(true)
            })
        }

        let animation = CATransition()
        animation.type = transitionType(type)
        animation.subtype = transitionSubtype(direction: direction)
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        view?.layer.add(animation, forKey: nil)
        animations()

        CATransaction.commit()
    }
}

public extension UIView {
    func screenshot() -> UIImage {
        return UIGraphicsImageRenderer(size: bounds.size).image { _ in
            drawHierarchy(in: CGRect(origin: .zero, size: bounds.size), afterScreenUpdates: true)
        }
    }
}
