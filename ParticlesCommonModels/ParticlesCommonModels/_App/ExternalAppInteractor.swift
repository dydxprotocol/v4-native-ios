//
//  ExternalAppInteractor.swift
//  ParticlesCommonModels
//
//  Created by Qiang Huang on 11/1/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import ParticlesKit
import Utilities

public class ExternalAppInteractor: NSObject, InteractorProtocol {
    public var entity: ModelObjectProtocol?

    public var url: String?
    public var appId: String?

    open func open() {
        if let urlString = url, let url = URL(string: urlString) {
            if URLHandler.shared?.canOpenURL(url) ?? false {
            }
        }
    }
}
