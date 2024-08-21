//
//  XibListPresenter.swift
//  PresenterLib
//
//  Created by Qiang Huang on 10/9/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import ParticlesKit
import UIToolkits
import WatchKit

open class XibListPresenter: ListPresenter {
    @IBInspectable var xibMap: String? {
        didSet {
            if xibMap != oldValue {
                if let xibMap = xibMap {
                    xibMapFile = XibJsonFile(fileName: xibMap, bundle: Bundle.ui())
                }
            }
        }
    }

    private static var sharedXibMapFile: XibJsonFile = {
        XibJsonFile(fileName: "xib.json", bundle: Bundle.ui())
    }()

    private var xibMapFile: XibJsonFile?

    public func xibFile(object: ModelObjectProtocol?) -> String? {
        var xib: String?
        if let xibProvider = object as? XibProviderProtocol {
            xib = xibProvider.xib
        }
        if xib == nil {
            if let xibFile = xibMapFile {
                xib = xibFile.xibFile(object: object)
            }
        }
        if xib == nil {
            let xibFile = XibListPresenter.sharedXibMapFile
            xib = xibFile.xibFile(object: object)
        }
        return xib
    }

    public func xib(object: ModelObjectProtocol?) -> String? {
        if let xibFile = self.xibFile(object: object) {
            return xibFile
        }
        return nil
    }
}
