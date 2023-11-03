//
//  CollectionViewListPresenter.swift
//  PresenterLib
//
//  Created by Qiang Huang on 10/12/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import Differ
import ParticlesKit
import UIToolkits

open class CollectionViewListPresenter: XibListPresenter, UICollectionViewDataSource, UICollectionViewDelegate, ScrollingProtocol {
    @IBInspectable @objc public dynamic var autoScroll: Bool = false
    @objc public dynamic var isAtEnd: Bool = true

    @IBInspectable var sectionHeaderXib: String?
    @IBInspectable var sectionFooterXib: String?
    @IBOutlet @objc open dynamic var collectionView: UICollectionView? {
        didSet {
            if collectionView !== oldValue {
                oldValue?.dataSource = nil
                oldValue?.delegate = nil
                collectionView?.dataSource = self
                collectionView?.delegate = self
                collectionViewXibRegister.collectionView = collectionView
                setupLayout()
                for section in sections {
                    section.collectionView = collectionView
                    section.selectionHandler = selectionHandler
                }
                if interactor != nil {
                    refresh(animated: false) { [weak self] in
                        self?.updateCompleted(firstContent: true)
                    }
                }
            }
        }
    }

    override open var selectionHandler: SelectionHandlerProtocol? {
        didSet {
            if selectionHandler !== oldValue {
                for section in sections {
                    section.collectionView = collectionView
                    section.selectionHandler = selectionHandler
                }
            }
        }
    }

    internal var flowLayout: UICollectionViewFlowLayout? {
        return collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
    }

    @IBInspectable var intMode: Int {
        get { return mode.rawValue }
        set { mode = PresenterMode(rawValue: newValue) ?? .linear }
    }

    public var mode: PresenterMode = .linear {
        didSet {
            if mode != oldValue {
                if let handler = updateDebouncer.debounce() {
                    handler.run({ [weak self] in
                        if let self = self {
                            self.current = self.pending
                            self.refresh(animated: true) { [weak self] in
                                self?.updateCompleted(firstContent: false)
                            }
                        }
                    }, delay: nil)
                }
            }
        }
    }
    
    public var initialPosition: Int?

    private var collectionViewXibRegister: CollectionViewXibRegister = CollectionViewXibRegister()
    public var sections: [CollectionViewSectionListPresenter] = []
    @objc override open dynamic var current: [ModelObjectProtocol]? {
        didSet {
            switch mode {
            case .sections:
                if let list = current as? [ListInteractor] {
                    var index = 0
                    self.sections = list.map({ (child: ListInteractor) -> CollectionViewSectionListPresenter in
                        let tableSection = section(for: child, index: index)
                        index += 1
                        return tableSection
                    })
                }

            case .linear:
                self.sections.first?.current = current
            }
        }
    }

    override open var interactor: ListInteractor? {
        didSet {
            switch mode {
            case .linear:
                sections.removeAll()
                if let interactor = interactor {
                    sections.append(section(for: interactor, index: 0))
                }
                refresh(animated: false) { [weak self] in
                    self?.updateCompleted(firstContent: true)
                }

            default:
                break
            }
        }
    }

    override open var title: String? {
        return "Cards"
    }

    override open var icon: UIImage? {
        return UIImage.named("view_cards", bundles: Bundle.particles)
    }

    open func setupLayout() {
        if #available(iOS 11.0, *) {
            flowLayout?.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        }
    }

    internal func section(for interactor: ListInteractor, index: Int) -> CollectionViewSectionListPresenter {
        let section = CollectionViewSectionListPresenter()
        section.collectionView = collectionView
        section.xibRegister = collectionViewXibRegister
        section.xibMap = xibMap
        section.sequence = index
        section.interactor = interactor
        section.selectionHandler = selectionHandler
        section.sectionHeaderXib = sectionHeaderXib
        section.sectionFooterXib = sectionFooterXib
        return section
    }

    override open func update() {
        if collectionView != nil {
            if mode == .sections {
                current = pending
                refresh(animated: true, completion: nil)
            } else {
                update(move: true)
            }
        } else {
            current = pending
        }
    }

    override open func update(diff: Diff, patches: [Patch<ModelObjectProtocol>], current: [ModelObjectProtocol]?) {
        collectionView?.performBatchUpdates({
            for change in patches {
                switch change {
                case let .deletion(index):
                    collectionView?.deleteSections(IndexSet(integer: index))

                case let .insertion(index: index, element: _):
                    collectionView?.insertSections(IndexSet(integer: index))
                }
            }
        }, completion: nil)
    }

    override open func refresh(animated: Bool, completion: (() -> Void)?) {
        UIView.animate(collectionView, type: animated ? .fade : .none, direction: .none, duration: UIView.defaultAnimationDuration, animations: { [weak self] in
            if let self = self {
                self.reloadData()
                if self.autoScroll {
                    self.scrollToEnd(animated: false)
                } else if let index = self.initialPosition {
//                    self.reallyScrollTo(index: index, animated: false)
//                    self.initialPosition = nil
                }
                completion?()
            }
        }, completion: nil)
    }

    open func reloadData() {
        collectionView?.reloadData()
    }

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        if interactor == nil {
            return 0
        } else {
            return mode == .sections ? sections.count : 1
        }
    }

    open func object(indexPath: IndexPath) -> ModelObjectProtocol? {
        switch mode {
        case .linear:
            return sections.first?.object(at: indexPath.row)

        case .sections:
            return sections.at(indexPath.section)?.object(at: indexPath.row)
        }
    }

    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if mode == .sections {
            let sectionPresenter = sections[section]
            return sectionPresenter.count ?? 0
        } else {
            return sections.first?.count ?? 0
        }
    }

    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let section = (mode == .sections) ? sections[indexPath.section] : sections.first {
            return section.cell(indexPath: indexPath) ?? UICollectionViewCell()
        } else {
            return UICollectionViewCell()
        }
    }

    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            UserInteraction.shared.sender = cell
        }
        if let section = (mode == .sections) ? sections[indexPath.section] : sections.first {
            section.navigate(to: indexPath)
        }
        collectionView.deselectItem(at: indexPath, animated: true)
    }

    override open func updateLayout() {
        collectionView?.collectionViewLayout.invalidateLayout()
    }

    private func lastIndexPath() -> IndexPath? {
        if let lastIndex = sections.lastIndex(where: { (section) -> Bool in
            (section.current?.count ?? 0) > 0
        }), let last = sections.at(lastIndex), let count = last.current?.count, count > 0 {
            return IndexPath(item: count - 1, section: lastIndex)
        } else {
            return nil
        }
    }

    public func scrollToEnd(animated: Bool) {
        if animated {
            DispatchQueue.main.async { [weak self] in
                if let self = self {
                    if let indexPath = self.lastIndexPath() {
                        self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: animated)
                    }
                }
            }
        } else {
            if let indexPath = lastIndexPath() {
                collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: animated)
                scrollToEnd(animated: true)
            }
        }
    }

    override open func selectScrollTo(index: Int, completion: @escaping () -> Void) {
        if current?.count ?? 0 > index {
            reallyScrollTo(index: index, animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + UIView.defaultAnimationDuration) {
                completion()
            }
        } else {
            initialPosition = index
            completion()
        }
    }
    
    private func reallyScrollTo(index: Int, animated: Bool) {
        if mode == .sections {
            collectionView?.scrollToItem(at: IndexPath(row: NSNotFound, section: index), at: .left, animated: animated)
        } else {
            collectionView?.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: animated)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        (cell as? ObjectPresenterCollectionViewCell)?.isCellHighlighted = true
    }
    
    public func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        (cell as? ObjectPresenterCollectionViewCell)?.isCellHighlighted = false
    }
}
