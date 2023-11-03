//
//  CarouselListPresenter.swift
//  PresenterLib
//
//  Created by Qiang Huang on 11/7/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import Differ
import iCarousel
import ParticlesKit
import UIToolkits
import Utilities

open class CarouselListPresenter: XibListPresenter, iCarouselDataSource, iCarouselDelegate {
    @IBOutlet var carousel: iCarousel? {
        didSet {
            if carousel !== oldValue {
                oldValue?.dataSource = nil
                oldValue?.delegate = nil
                carousel?.dataSource = self
                carousel?.delegate = self
                carousel?.type = type
            }
        }
    }

    var type: iCarouselType = .coverFlow {
        didSet {
            carousel?.type = type
        }
    }

    @IBInspectable var intType: Int {
        get { return type.rawValue }
        set { type = iCarouselType(rawValue: newValue) ?? .linear }
    }

    @IBInspectable var margin: CGFloat = 0.0
    @IBInspectable var proportional: Bool = false

    override open var title: String? {
        return "Carousel"
    }

    override open var icon: UIImage? {
        return UIImage.named("view_carousel", bundles: Bundle.particles)
    }

    public func numberOfItems(in carousel: iCarousel) -> Int {
        return interactor?.list?.count ?? 0
    }

    public func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        let object = self.object(at: index)
        if let xib = xib(object: object) {
            if let loadedView: ObjectPresenterView = XibLoader.load(from: xib) {
                let itemWidth: CGFloat = width(carousel: carousel)
                if proportional {
                    loadedView.frame = CGRect(x: 0, y: 0, width: itemWidth, height: loadedView.frame.size.height / loadedView.frame.size.width * itemWidth)
                } else {
                    loadedView.frame = CGRect(x: 0, y: 0, width: itemWidth, height: loadedView.frame.size.height)
                }
                loadedView.model = object
                return loadedView
            }
        }
        return UIView()
    }

    public func carouselDidEndScrollingAnimation(_ carousel: iCarousel) {
        selectCurrent()
    }

    public func carousel(_ carousel: iCarousel, didSelectItemAt index: Int) {
        select(index: index, completion: nil)
    }

    open func width(carousel: iCarousel) -> CGFloat {
        return carousel.bounds.size.width - margin * 2
    }

    override open func update() {
        if carousel != nil {
            update(move: false)
        } else {
            current = pending
        }
    }

    override open func update(diff: Diff, patches: [Patch<ModelObjectProtocol>], current: [ModelObjectProtocol]?) {
        for change in patches {
            switch change {
            case let .deletion(index):
                carousel?.removeItem(at: index, animated: true)

            case let .insertion(index: index, element: _):
                carousel?.insertItem(at: index, animated: true)
            }
        }
    }

    override open func refresh(animated: Bool, completion: (() -> Void)?) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [weak self] in
            if let self = self {
                self.carousel?.reloadData()
                completion?()
            }
        }
    }

    public func scroll(to index: Int) {
        carousel?.scrollToItem(at: index, animated: true)
    }

    override open func updateLayout() {
        refresh(animated: true, completion: nil)
    }

    override open func visibleIndice() -> [Int]? {
        if (interactor?.list?.count ?? 0) > 0 {
            if let index = carousel?.currentItemIndex {
                return (index != -1) ? [index] : nil
            }
        }
        return nil
    }

    override open func selectScrollTo(index: Int, completion: @escaping () -> Void) {
        scroll(to: index)
        DispatchQueue.main.asyncAfter(deadline: .now() + UIView.defaultAnimationDuration) {
            completion()
        }
    }
}
