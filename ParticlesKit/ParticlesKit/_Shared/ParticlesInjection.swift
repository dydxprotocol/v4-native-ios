//
//  ParticlesInjections.swift
//  ParticlesKit
//
//  Created by Qiang Huang on 12/26/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import RoutingKit
import Utilities

public protocol InjectionProtocol: NSObjectProtocol {
    func injectCore(completion: @escaping () -> Void)
    func injectFeatures(completion: @escaping () -> Void)
    func injectFeatured(completion: @escaping () -> Void)
    func injectParsers()
    func injectAppStart(completion: @escaping () -> Void)
}

public class Injection {
    internal static var _shared: InjectionProtocol?
    public static var shared: InjectionProtocol? {
        return _shared
    }

    public static func inject(injeciton: InjectionProtocol, completion: @escaping () -> Void) {
        _shared = injeciton
        _shared?.injectCore(completion: completion)
    }
}

open class ParticlesInjection: NSObject, InjectionProtocol {
    open func injectCore(completion: @escaping () -> Void) {
        injectFolderService()
        injectDebug()
        injectLocalization()
        completion()
    }

    open func injectFolderService() {
        Console.shared.log("injectFolderService")
        if CommandLine.arguments.contains("-MockTest") {
            FolderService.shared = RealFolderProvider.mock()
            _ = LocalDebugCacheInteractor.mock()
            _ = LocalFeatureFlagsCacheInteractor.mock()
        } else {
            FolderService.shared = RealFolderProvider()
        }
    }

    open func injectDebug() {
        DebugSettings.shared = LocalDebugCacheInteractor.shared
    }

    open func injectLocalization() {
        #if DEBUG
        LocalizerBuffer.shared = DebugLocalizer()
        #endif
    }

    open func injectFeatures(completion: @escaping () -> Void) {
        injectFeatureService { [weak self] in
            self?.injectFeatured(completion: completion)
        }
    }

    open func injectFeatureService(completion: @escaping () -> Void) {
        Console.shared.log("injectFeatures")
        FeatureService.shared = LocalFeatureFlagsCacheInteractor.shared
        FeatureService.shared?.activate(completion: completion)
    }

    open func injectFeatured(completion: @escaping () -> Void) {
        Console.shared.log("injectFeatured")
        if let integration_test = parser.asString(DebugSettings.shared?.debug?["integration_test"]), integration_test == "r" {
            FolderService.shared = RealFolderProvider.mock()
        }

        if let debug = DebugSettings.shared?.debug, parser.asString(debug["demo_mode"]) == "1" {
            if let dateText = parser.asString(debug["demo_date"]) {
                DateService.shared = FixedDateProvider(date: Date.date(serverString: dateText))
            } else {
                DateService.shared = FixedDateProvider(date: Date())
            }
        } else {
            DateService.shared = RealDateProvider()
        }
        completion()
    }

    open func injectParsers() {
        Console.shared.log("injectParsers")
        // Router and Xib loader supports Feature flagging
        MappedRouter.parserOverwrite = Parser.featureFlagged
        XibJsonFile.parserOverwrite = Parser.featureFlagged
        JsonEndpointResolver.parserOverwrite = Parser.debug
        JsonCredentialsProvider.parserOverwrite = Parser.debug
    }

    open func injectReplay() {
        Console.shared.log("injectReplay")
        // set up the router
        ApiReplayer.shared = JsonApiReplayer(path: ProcessInfo.processInfo.environment["API_RECORDER_DIR"])
    }

    open func injectAppStart(completion: @escaping () -> Void) {
        completion()
    }
}
