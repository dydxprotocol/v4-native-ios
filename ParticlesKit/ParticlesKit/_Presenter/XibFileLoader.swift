//
//  XibFileLoader.swift
//  ParticlesKit
//
//  Created by John Huang on 1/16/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import Foundation
/*
 open class XibFileLoader: NSObject {
 public var xibRegister: XibRegisterProtocol?
 public var xibSizes: [String: CGSize] = [:]
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

 public func xibFile(object: (ModelObjectProtocol)?) -> String? {
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

 public func xib(object: (ModelObjectProtocol)?) -> String? {
 if let xibFile = self.xibFile(object: object) {
 xibRegister?.registerXibIfNeeded(xibFile)
 return xibFile
 }
 return nil
 }

 public func defaultSize(xib: String?) -> CGSize? {
 if let xib = xib {
 var size = xibSizes[xib]
 if size == nil {
 if let loadedView = XibLoader.loadView(fromNib: xib) {
 size = loadedView.frame.size
 xibSizes[xib] = size
 }
 }
 return size
 }
 return nil
 }
 }
 */
