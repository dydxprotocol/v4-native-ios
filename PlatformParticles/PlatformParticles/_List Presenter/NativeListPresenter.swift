//
//  NativeListPresenter.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 12/21/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import Differ
import ParticlesCommonModels
import ParticlesKit
import UIToolkits
import Utilities

open class NativeListPresenter: ListPresenter {
    let kDebouncerDelay: Double = 0.0523
    @IBOutlet open var view: ViewProtocol? {
        didSet {
            updateVisibility()
        }
    }

    override open var visible: Bool {
        didSet {
            updateVisibility()
        }
    }

    @IBOutlet open var nullView: ViewProtocol? {
        didSet {
            nullView?.visible = true
        }
    }

    @IBOutlet open var loadingView: ViewProtocol? {
        didSet {
            loadingView?.visible = false
        }
    }

    @IBOutlet open var loadingSpinner: SpinnerProtocol? {
        didSet {
            loadingSpinner?.spinning = false
        }
    }

    private var browsingListInteractor: BrowsingListInteractor? {
        didSet {
            didSetBrowsingListInteractor(oldValue: oldValue)
        }
    }
    
    @objc public dynamic var isReady: Bool = true {
        didSet {
            didSetIsReady(oldValue: oldValue)
        }
    }

    public var updateDebouncer = Debouncer()

    override open func didSetCurrent(oldValue: [ModelObjectProtocol]?) {
        super.didSetCurrent(oldValue: oldValue)
        nullView?.visible = (current?.count ?? 0 == 0)
    }

    override open func didSetInteractor(oldValue: ListInteractor?) {
        super.didSetInteractor(oldValue: oldValue)
        browsingListInteractor = interactor as? BrowsingListInteractor
    }

    open func didSetBrowsingListInteractor(oldValue: BrowsingListInteractor?) {
        changeObservation(from: oldValue, to: browsingListInteractor, keyPath: #keyPath(BrowsingListInteractor.isReady)) { [weak self] _, _, _, _ in
            self?.isReady = self?.browsingListInteractor?.isReady ?? true
        }
    }

    open func didSetIsReady(oldValue: Bool) {
        loadingView?.visible = !isReady
        loadingSpinner?.spinning = !isReady
    }

    open func updateVisibility() {
        view?.visible = visible
    }

    override open func update(move: Bool) {
        if let handler = updateDebouncer.debounce() {
            let pending = self.pending
            let current = self.current
            if let pending = pending, let current = current {
                if move {
                    var diff: ExtendedDiff?
                    handler.run(background: { [weak self] in
                        if let self = self {
                            diff = self.extendedDiff(pending: pending, current: current)
                        }
                    }, final: { [weak self] in
                        if let self = self {
                            if let diff = diff {
                                if diff.elements.count > 0 {
                                    self.update(diff: diff) { [weak self] in
                                        self?.current = pending
                                    }
                                    self.updateCompleted(firstContent: false)
                                }
                            } else {
                                self.current = pending
                                self.refresh(animated: false) { [weak self] in
                                    self?.updateCompleted(firstContent: false)
                                }
                            }
                        }
                    }, delay: kDebouncerDelay)
                } else {
                    var diff: Diff?
                    var patches: [Patch<ModelObjectProtocol>]?
                    handler.run(background: { [weak self] in
                        if let self = self {
                            diff = self.diff(pending: pending, current: current)
                        }
                    }, then: { [weak self] in
                        if let self = self, let diff = diff {
                            patches = self.patches(diff: diff, pending: pending, current: current)
                        }
                    }, final: { [weak self] in
                        if let self = self {
                            self.current = pending
                            if let patches = patches, let diff = diff {
                                self.update(diff: diff, patches: patches, current: current)
                                self.updateCompleted(firstContent: false)
                            } else {
                                self.refresh(animated: false) { [weak self] in
                                    self?.updateCompleted(firstContent: false)
                                }
                            }
                        }
                    }, delay: kDebouncerDelay)
                }
            } else {
                handler.cancel()
                self.current = pending
                refresh(animated: false) { [weak self] in
                    self?.updateCompleted(firstContent: true)
                }
            }
        }
    }

    open func refresh(animated: Bool, completion: (() -> Void)?) {
        completion?()
    }

    open func updateCompleted(firstContent: Bool) {
    }

    open func diff(pending: [ModelObjectProtocol]?, current: [ModelObjectProtocol]?) -> Diff? {
        if let pending = pending, let current = current {
            return current.diff(pending) { (object1, object2) -> Bool in
                object1 === object2
            }
        }
        return nil
    }

    open func extendedDiff(pending: [ModelObjectProtocol]?, current: [ModelObjectProtocol]?) -> ExtendedDiff? {
        if let pending = pending, let current = current {
            return current.extendedDiff(pending) { (object1, object2) -> Bool in
                object1 === object2
            }
        }
        return nil
    }

    open func patches(diff: Diff?, pending: [ModelObjectProtocol]?, current: [ModelObjectProtocol]?) -> [Patch<ModelObjectProtocol>]? {
        if let diff = diff, let pending = pending, let current = current {
            return diff.patch(from: current, to: pending) { (element1, element2) -> Bool in
                switch (element1, element2) {
                case let (.insert(at1), .insert(at2)):
                    return at1 < at2
                case (.insert, .delete):
                    return false
                case (.delete, .insert):
                    return true
                case let (.delete(at1), .delete(at2)):
                    return at1 > at2
                }
            }
        }
        return nil
    }

    open func update(diff: Diff, patches: [Patch<ModelObjectProtocol>], current: [ModelObjectProtocol]?) {
    }

    open func update(diff: ExtendedDiff, updateData: () -> Void) {
    }
}
