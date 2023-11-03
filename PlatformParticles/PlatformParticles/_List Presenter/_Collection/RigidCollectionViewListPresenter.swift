//
//  RigidCollectionViewListPresenter.swift
//  PresenterLib
//
//  Created by Qiang Huang on 10/12/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import ParticlesKit
import UIKit

public enum CardStyle: Int {
    case full
    case width
    case auto
}

open class RigidCollectionViewListPresenter: CollectionViewListPresenter, UICollectionViewDelegateFlowLayout {
    @IBInspectable var intStyle: Int {
        get { return style.rawValue }
        set { style = CardStyle(rawValue: newValue) ?? .full }
    }

    @IBInspectable var proportional: Bool = false

    override public var mode: PresenterMode {
        didSet {
            if mode != oldValue {
                updatePagerVisibility()
            }
        }
    }

    public var style: CardStyle = .full {
        didSet {
            if style != oldValue {
                updatePagerVisibility()
            }
        }
    }

    @IBOutlet var pager: UIPageControl? {
        didSet {
            if pager !== oldValue {
                oldValue?.removeTarget()
                pager?.addTarget(self, action: #selector(page(_:)))
                updatePagerVisibility()
                updatePage()
            }
        }
    }

    @IBOutlet var nextButton: UIButton? {
        didSet {
            if nextButton !== oldValue {
                oldValue?.removeTarget()
                nextButton?.addTarget(self, action: #selector(next(_:)))
                updateNext()
            }
        }
    }

    override open var current: [ModelObjectProtocol]? {
        didSet {
            updatePagerVisibility()
            updatePage()
        }
    }

    override open func setupLayout() {
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let section = (mode == .sections) ? sections[indexPath.section] : sections.first, let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout {
            return section.size(at: indexPath.row, layout: flowLayout, style: style, proportional: proportional)
        }
        return CGSize.zero
    }

    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if pager?.currentPage != indexPath.row {
            pager?.currentPage = indexPath.row
        }
    }

    private func updatePagerVisibility() {
        pager?.visible = (current != nil && sections.count == 1 && style == .full)
    }

    private func updatePage() {
        if pager?.visible ?? false {
            pager?.numberOfPages = sections.first?.count ?? 0
            pager?.currentPage = collectionView?.indexPathsForVisibleItems.first?.row ?? 0
        }
    }

    private func updateNext() {
        let current = collectionView?.indexPathsForVisibleItems.first?.row ?? 0
        let total = sections.first?.count ?? 0
        nextButton?.visible = (current != total - 1)
    }

    @IBAction func page(_ sender: Any?) {
        if pager?.visible ?? false, let page = pager?.currentPage {
            collectionView?.scrollToItem(at: IndexPath(row: page, section: 0), at: .left, animated: true)
        }
    }

    @IBAction func next(_ sender: Any?) {
        let current = collectionView?.indexPathsForVisibleItems.first?.row ?? 0
        let total = sections.first?.count ?? 0
        if current < total - 1 {
            collectionView?.scrollToItem(at: IndexPath(row: current + 1, section: 0), at: .left, animated: true)
        }
    }

    override open func refresh(animated: Bool, completion: (() -> Void)?) {
        if let initialPosition = initialPosition {
            view?.visible = false
            reloadData()
            completion?()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [weak self] in
                if let self = self {
                    self.collectionView?.scrollToItem(at: IndexPath(row: initialPosition, section: 0), at: .left, animated: false)
                    self.initialPosition = nil
                    if let view = self.view as? UIView {
                        UIView.animate(view, type: .fade, direction: .none, duration: UIView.defaultAnimationDuration, animations: { /* [weak self] in */
                            view.visible = true
                        }, completion: nil)
                    }
                }
            }
        } else {
            super.refresh(animated: animated, completion: completion)
        }
    }
}

public extension RigidCollectionViewListPresenter {
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        updatePage()
        updateNext()
    }
}
