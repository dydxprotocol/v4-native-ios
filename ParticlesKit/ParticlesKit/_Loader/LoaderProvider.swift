//
//  LoaderProvider.swift
//  ParticlesKit
//
//  Created by Qiang Huang on 12/30/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import Utilities

public protocol LoaderProviderProtocol {
    func loader(tag: String, cache: LocalCacheProtocol?) -> LoaderProtocol?
    func localLoader(path: String, cache: LocalCacheProtocol?) -> LoaderProtocol?
    func localAsyncLoader(path: String, cache: LocalCacheProtocol?) -> LoaderProtocol?
}

public class LoaderProvider {
    public static var shared: LoaderProviderProtocol?
}
