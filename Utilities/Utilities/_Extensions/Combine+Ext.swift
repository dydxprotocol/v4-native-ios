//
//  Combine+Ext.swift
//  Utilities
//
//  Created by Rui Huang on 1/30/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import Combine

public extension AnyPublisher {

    static func create<Output, Failure>(_ subscribe: @escaping (AnySubscriber<Output, Failure>) -> AnyCancellable) -> AnyPublisher<Output, Failure> {

        let passthroughSubject = PassthroughSubject<Output, Failure>()
        var cancellable: AnyCancellable?

        return passthroughSubject
            .handleEvents(receiveSubscription: { _ in

                let subscriber = AnySubscriber<Output, Failure> { _ in

                } receiveValue: { input in
                    passthroughSubject.send(input)
                    return .unlimited
                } receiveCompletion: { completion in
                    passthroughSubject.send(completion: completion)
                }

                DispatchQueue.main.async {
                    cancellable = subscribe(subscriber)
                }

            }, receiveCompletion: { _ in

            }, receiveCancel: {
                cancellable?.cancel()
            })
            .eraseToAnyPublisher()
    }
}

public extension Timer {
    static func publish(every interval: TimeInterval,
                        on runLoop: RunLoop = .main,
                        in mode: RunLoop.Mode = .common,
                        triggerNow: Bool) -> AnyPublisher<Timer.TimerPublisher.Output, Timer.TimerPublisher.Failure> {
        let publisher = Timer.publish(every: interval, on: runLoop, in: mode).autoconnect()
        if triggerNow {
            return publisher
                .prepend(Date())
                .eraseToAnyPublisher()
        } else {
            return publisher
                .eraseToAnyPublisher()
        }
    }
}
