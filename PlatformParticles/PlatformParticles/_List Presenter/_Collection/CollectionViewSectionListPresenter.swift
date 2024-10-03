//
//  CollectionViewSectionListPresenter.swift
//  PresenterLib
//
//  Created by Qiang Huang on 10/12/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import Differ
import ParticlesKit
import UIKit
import UIToolkits
import Utilities

open class CollectionViewSectionListPresenter: XibListPresenter {
    @IBOutlet var collectionView: UICollectionView?
    @IBInspectable var sectionHeaderXib: String?
    @IBInspectable var sectionFooterXib: String?

    override open func update() {
        if collectionView != nil {
            update(move: true)
        } else {
            current = pending
        }
    }

    override open func update(diff: ExtendedDiff, updateData: () -> Void) {
        if let collectionView = collectionView,
            sequence < collectionView.numberOfSections {
            collectionView.apply(diff, updateData: {
                updateData()
            }, completion: nil, indexPathTransform: { (indexPath) -> IndexPath in
                IndexPath(row: indexPath.row, section: self.sequence)
            })
        } else {
            updateData()
        }
    }

    override open func refresh(animated: Bool, completion: (() -> Void)?) {
        if animated {
            UIView.animate(collectionView, type: .fade, direction: .none, duration: UIView.defaultAnimationDuration, animations: { [weak self] in
                if let self = self {
                    self.collectionView?.reloadData()
                    completion?()
                }
            }, completion: nil)
        } else {
            collectionView?.reloadData()
            completion?()
        }
    }

    open func cell(indexPath: IndexPath) -> UICollectionViewCell? {
        let object = self.object(at: indexPath.row)
        return cell(object: object, indexPath: indexPath)
    }

    open func cell(object: ModelObjectProtocol?, indexPath: IndexPath) -> UICollectionViewCell? {
        if let xib = xib(object: object), let collectionView = collectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: xib, for: indexPath)
            if let presenterCell = cell as? ObjectPresenterCollectionViewCell {
                presenterCell.xib = xib
                presenterCell.model = object
            }
            return cell
        }
        return nil
    }

    open func navigate(to indexPath: IndexPath) {
        select(index: indexPath.row, completion: nil)
    }

    open func size(at index: Int, layout: UICollectionViewFlowLayout, style: CardStyle, proportional: Bool) -> CGSize {
        if let collectionView = collectionView {
            let viewSize = collectionView.frame.size
            let usefulSize = CGSize(width: viewSize.width - layout.sectionInset.left - layout.sectionInset.right, height: viewSize.height - layout.sectionInset.top - layout.sectionInset.bottom)
            switch style {
            case .full:
                return usefulSize
                case .width:
                if let size = defaultSize(at: index) {
                    if layout.scrollDirection == .horizontal {
                        return adjust(size: size, height: usefulSize.height, proportional: proportional)
                    } else {
                        return adjust(size: size, width: usefulSize.width, proportional: proportional)
                    }
                }
                default:
                if let size = defaultSize(at: index) {
                    if layout.scrollDirection == .horizontal {
                        var rows = Int((usefulSize.height + layout.minimumInteritemSpacing) / (size.height + layout.minimumInteritemSpacing))
                        if rows == 0 {
                            rows = 1
                        }
                        return adjust(size: size, height: (usefulSize.height + layout.minimumInteritemSpacing) / CGFloat(rows) - layout.minimumInteritemSpacing - 1.0, proportional: proportional)
                    } else {
                        var columns = Int((usefulSize.width + layout.minimumInteritemSpacing) / (size.width + layout.minimumInteritemSpacing))
                        if columns == 0 {
                            columns = 1
                        }
                        return adjust(size: size, width: (usefulSize.width + layout.minimumInteritemSpacing) / CGFloat(columns) - layout.minimumInteritemSpacing - 1.0, proportional: proportional)
                    }
                }
            }
        }
        return CGSize.zero
    }

    private func adjust(size: CGSize, width: CGFloat, proportional: Bool) -> CGSize {
        if proportional {
            if size.width != 0 {
                return CGSize(width: width, height: width * size.height / size.width)
            } else {
                return CGSize.zero
            }
        } else {
            return CGSize(width: width, height: size.height)
        }
    }

    private func adjust(size: CGSize, height: CGFloat, proportional: Bool) -> CGSize {
        if proportional {
            if size.height != 0 {
                return CGSize(width: height * size.width / size.height, height: height)
            } else {
                return CGSize.zero
            }
        } else {
            return CGSize(width: size.width, height: height)
        }
    }
}
