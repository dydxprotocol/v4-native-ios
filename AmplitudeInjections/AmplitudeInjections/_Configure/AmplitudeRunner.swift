//
//  AmplitudeRunner.swift
//  AmplitudeInjections
//
//  Created by John Huang on 4/19/22.
//

import Amplitude_iOS
import Utilities

public final class AmplitudeRunner: NSObject, SingletonProtocol {
    public static var optionsFile: String?

    public static var shared: AmplitudeRunner = AmplitudeRunner()
    
    public var apiKey: String? {
        didSet {
            didSetApiKey(oldValue: oldValue)
        }
    }
    
    private func didSetApiKey(oldValue: String?) {
        if apiKey != oldValue {
            if let apiKey = apiKey {
                Amplitude.instance().initializeApiKey(apiKey)
            }
        }
    }
}
