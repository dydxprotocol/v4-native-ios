//
//  FullStoryTracking.swift
//  FullStoryInjections
//
//  Created by Rui Huang on 8/1/22.
//

import Utilities
import FullStory

public enum FullStoryTrackingStatus {
    case started
    case stopped
    case error(Error)
}

public protocol FullStoryTrackingStatusDelegate: NSObjectProtocol {
    func statusUpdate(_ status: FullStoryTrackingStatus)
}

public protocol FullStoryTrackingProtocol {
    func start()
    func stop()
    var delegate: FullStoryTrackingStatusDelegate? { get set }
}

public final class FullStoryTracking: NSObject, SingletonProtocol, FSDelegate, FullStoryTrackingProtocol {
    public weak var delegate: FullStoryTrackingStatusDelegate?
    
    public static var shared = FullStoryTracking()
    
    public override init() {
        super.init()
        FS.delegate = self
    }

    public func start() {
        Console.shared.log("FullStoryTracking start")

        FS.restart()
    }
    
    public func stop() {
        Console.shared.log("FullStoryTracking stop")
        
        FS.shutdown()
    }
    
    public func fullstoryDidStopSession() {
        Console.shared.log("fullstoryDidStopSession")
        delegate?.statusUpdate(.stopped)
    }
    
    public func fullstoryDidStartSession(_ sessionUrl: String) {
        Console.shared.log("fullstoryDidStartSession " +  sessionUrl)
        delegate?.statusUpdate(.started)
    }
    
    public func fullstoryDidTerminateWithError(_ error: Error) {
        Console.shared.log("fullstoryDidTerminateWithError " +  error.localizedDescription)
        delegate?.statusUpdate(.error(error))
    }
}
