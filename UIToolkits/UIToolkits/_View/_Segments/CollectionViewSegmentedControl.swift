//
//  CollectionViewSegmentedControl.swift
//  CollectionViewSegmentedControl
//
//  Created by Qiang Huang on 8/25/21.
//  Copyright © 2021 dYdX. All rights reserved.
//

import UIKit

@objc open class CollectionViewSegmentedControl: CustomSegmentedControl, UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate {
    @IBInspectable var rightAligned: Bool = false {
        didSet {
            if rightAligned != oldValue {
                orientCollecitonView()
            }
        }
    }

    @IBOutlet var collectionView: UICollectionView? {
        didSet {
            oldValue?.dataSource = nil
            oldValue?.delegate = nil
            collectionView?.dataSource = self
            collectionView?.delegate = self
            collectionView?.allowsSelection = true
            collectionView?.allowsMultipleSelection = false
            orientCollecitonView()

            if let cellXib = cellXib, let nib = UINib.safeLoad(xib: cellXib, bundles: Bundle.particles) {
                collectionView?.register(nib, forCellWithReuseIdentifier: "cell")
            }
        }
    }

    public static func segments(with titles: [String]) -> SegmentedProtocol {
        let control = CollectionViewSegmentedControl()
        let collectionView = UICollectionView()
        control.collectionView = collectionView
        control.fill(titles: titles)
        return control
    }

    public static func segments(segments: [ControlSegment]) -> SegmentedProtocol {
        let control = CollectionViewSegmentedControl()
        let collectionView = UICollectionView()
        control.collectionView = collectionView
        control.fill(segments: segments)
        return control
    }

    open override func didSetSegments(oldValue: [ControlSegment]?) {
        collectionView?.reloadData()
    }
    
    open override func didSetSelectedIndex(oldValue: Int) {
        super.didSetSelectedIndex(oldValue: oldValue)
        if selectedIndex != -1 {
            collectionView?.selectItem(at: indexPath(from: selectedIndex), animated: true, scrollPosition: .centeredHorizontally)
        } else {
            if oldValue != -1 {
                collectionView?.deselectItem(at: indexPath(from: oldValue), animated: true)
            }
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        if let textCell = cell as? SegmentCollectionViewCell {
            let index = index(from: indexPath)
            textCell.text = segments?[index].text
            textCell.image = segments?[index].image
            textCell.selectedImage = segments?[index].selectedImage
            return cell
        }
        return cell
    }

    open func index(from indexPath: IndexPath) -> Int {
        if rightAligned {
            return (segments?.count ?? 0) - indexPath.row - 1
        } else {
            return indexPath.row
        }
    }

    open func indexPath(from index: Int) -> IndexPath {
        if rightAligned {
            return IndexPath(row: (segments?.count ?? 0) - index - 1, section: 0)
        } else {
            return IndexPath(row: index, section: 0)
        }
    }

    open func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if rightAligned {
            cell.contentView.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
    }

    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return segments?.count ?? 0
    }

    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        userInteracting = true
        selectedIndex = index(from: indexPath)
        userInteracting = false
    }

    open func orientCollecitonView() {
        if rightAligned {
            collectionView?.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
    }
}

@objc open class SnapCollectionViewSegmentedControl: CollectionViewSegmentedControl, UICollectionViewDelegateFlowLayout {
    @IBInspectable public var stretchItems: Bool = false
    @IBInspectable public var itemSpacing: CGFloat = 8.0

    override public var collectionView: UICollectionView? {
        didSet {
            if stretchItems {
                let layout = CollectionViewGridLayout()
                layout.itemSpacing = itemSpacing
                layout.lineSize = collectionView?.frame.height ?? 44
                collectionView?.collectionViewLayout = layout
            }
        }
    }

    override var segments: [ControlSegment]? {
        didSet {
            (collectionView?.collectionViewLayout as? CollectionViewGridLayout)?.lineItemCount = UInt(segments?.count ?? 1)
        }
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.bounds.size.height
        if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout {
            let width = collectionView.bounds.size.width
            let contentWidth: CGFloat = (width - flowLayout.sectionInset.left - flowLayout.sectionInset.right + flowLayout.minimumLineSpacing)
            let itemWidth = contentWidth / CGFloat(segments?.count ?? 1) - flowLayout.minimumLineSpacing
            return CGSize(width: itemWidth, height: height)
        } else {
            assertionFailure("only support flow layout here")
            return CGSize(width: 120, height: height)
        }
    }
}

@objc open class ScrollableCollectionViewSegmentedControl: CollectionViewSegmentedControl {
    public override var collectionView: UICollectionView? {
        didSet {
            changeObservation(from: oldValue, to: collectionView, keyPath: #keyPath(UICollectionView.collectionViewLayout)) { [weak self] _, _, _, _ in
                if let self = self {
                    if let flowLayout = self.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
                        flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
                    }
                }
            }
        }
    }
}
