//
//  ParticlesPlatformAppInjection.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 1/6/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import ParticlesKit
import PlatformRouting
import UIToolkits
import Utilities
#if _iOS
    import UIAppToolkits
#endif

open class ParticlesPlatformAppInjection: ParticlesPlatformInjection {
    open override func injectUI() {
        super.injectUI()

        #if _iOS
            ViewControllerStack.shared = UIKitAppViewControllerStack()
        #endif
    }
}
