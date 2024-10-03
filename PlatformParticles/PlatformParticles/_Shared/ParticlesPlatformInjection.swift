//
//  ParticlesPlatformInjection.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 12/26/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import ParticlesKit
import PlatformRouting
import SDWebImage
import SDWebImageSVGCoder
import Utilities
import UIToolkits

open class ParticlesPlatformInjection: ParticlesInjection {
    open override func injectAppStart(completion: @escaping () -> Void) {
        super.injectAppStart {[weak self] in
            self?.injectUI()
            completion()
        }
    }

    open func injectUI() {
        Console.shared.log("injectUI")

        HapticFeedback.shared = MotionHapticFeedback()
        SDImageCodersManager.shared.addCoder(SDImageSVGCoder.shared)
        RoutingTabBarController.parserOverwrite = Parser.standard
        PrompterFactory.shared = UIKitPrompterFactory()
    }
}
