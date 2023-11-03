//
//  CollectionViewGridPresenter.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 1/27/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import ParticlesKit
import UIToolkits

open class CollectionViewGridPresenter: XibGridPresenter, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    public var width: Int {
        return interactor?.width ?? 0
    }

    public var height: Int {
        return interactor?.height ?? 0
    }

    @IBOutlet public var collectionView: UICollectionView? {
        didSet {
            if collectionView !== oldValue {
                oldValue?.dataSource = nil
                oldValue?.delegate = nil
                collectionView?.dataSource = self
                collectionView?.delegate = self
                collectionViewXibRegister.collectionView = collectionView
                if interactor != nil {
                    refresh(animated: true)
                }
            }
        }
    }

    override open var visible: Bool? {
        didSet {
            if visible != oldValue, let collectionView = collectionView {
                UIView.animate(collectionView, type: .fade, direction: .none, duration: UIView.defaultAnimationDuration, animations: {
                    collectionView.isHidden = !(self.visible ?? false)
                }, completion: nil)
            }
        }
    }

    private var collectionViewXibRegister: CollectionViewXibRegister = CollectionViewXibRegister()

    override open var interactor: ModelGridProtocol? {
        didSet {
            refresh(animated: true)
        }
    }

    override open func awakeFromNib() {
        super.awakeFromNib()
        xibRegister = collectionViewXibRegister
    }

    override open var title: String? {
        return "Cards"
    }

    override open var icon: UIImage? {
        return UIImage.named("view_cards", bundles: Bundle.particles)
    }

    override open func refresh(animated: Bool) {
        if animated {
            UIView.animate(collectionView, type: .fade, direction: .none, duration: UIView.defaultAnimationDuration, animations: {
                self.collectionView?.reloadData()
            }, completion: nil)
        } else {
            collectionView?.reloadData()
        }
    }

    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (interactor?.width ?? 0) * (interactor?.height ?? 0)
    }

    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let object = self.object(at: indexPath.row), let xib = xib(object: object) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: xib, for: indexPath)
            if let presenterCell = cell as? ObjectPresenterCollectionViewCell {
                presenterCell.xib = xib
                presenterCell.model = object
            }
            return cell
        }
        return UICollectionViewCell()
    }

    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            UserInteraction.shared.sender = cell
        }
        if let object = self.object(at: indexPath.row) {
            let selection: SelectionHandlerProtocol = selectionHandler ?? SelectionHandler.standard
            selection.select(object)
        }
        collectionView.deselectItem(at: indexPath, animated: true)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberPerRow = width
        if let flow = collectionViewLayout as? UICollectionViewFlowLayout, numberPerRow != 0 {
            let viewSize = collectionView.frame.size
            let usefulSize = CGSize(width: viewSize.width - flow.sectionInset.left - flow.sectionInset.right, height: viewSize.height - flow.sectionInset.top - flow.sectionInset.bottom)

            let itemWidth = (usefulSize.width + flow.minimumInteritemSpacing) / CGFloat(numberPerRow) - flow.minimumInteritemSpacing
            return CGSize(width: itemWidth, height: itemWidth)
        }
        return CGSize.zero
    }

    override open func change(to new: [[ModelObjectProtocol]]) {
        super.change(to: new)
    }

    override open func updateLayout() {
        collectionView?.collectionViewLayout.invalidateLayout()
    }

    private func y(index: Int) -> Int {
        let width = self.width
        let height = self.height
        if width != 0 && height != 0 {
            let y = index / width
            return y < height ? y : 0
        }
        return 0
    }

    private func x(index: Int) -> Int {
        let width = self.width
        let height = self.height
        if width != 0 && height != 0 {
            return index % width
        }
        return 0
    }

    private func object(at index: Int) -> ModelObjectProtocol? {
        return object(x: x(index: index), y: y(index: index))
    }
}
