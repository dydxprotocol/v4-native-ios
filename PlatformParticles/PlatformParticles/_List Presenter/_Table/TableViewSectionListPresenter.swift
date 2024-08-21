//
//  TableViewSectionListPresenter.swift
//  PresenterLib
//
//  Created by John Huang on 10/9/18.
//  Copyright © 2019 dYdX. All rights reserved.
//

import Differ
import ParticlesKit
import UIToolkits
import Utilities
import UIKit

open class TableViewSectionListPresenter: XibListPresenter {
    @IBOutlet var tableView: UITableView?
    @IBInspectable var sectionHeaderXib: String?
    @IBInspectable var sectionFooterXib: String?
    @IBInspectable var animatedChange: Bool = false
    @IBInspectable var scrollToSelection: Bool = false {
        didSet {
            if scrollToSelection != oldValue {
                if scrollToSelection {
                    if let pendingScroll = pendingScroll {
                        if let handler = scrollDebouncer.debounce() {
                            handler.run({ [weak self] in
                                self?.scroll(to: pendingScroll)
                                self?.pendingScroll = nil
                            }, delay: 0.51)
                        }
                    }
                }
            }
        }
    }

    private var header: UIView?
    public var autoScroll: Bool = false
    private var pendingScroll: ModelObjectProtocol?

    override open func update() {
        if tableView != nil {
            update(move: true)
        } else {
            current = pending
        }
    }

    override open func update(diff: ExtendedDiff, updateData: () -> Void) {
        let wasAtEnd = isTableAtEnd()
        updateData()
        if animatedChange {
            if let tableView = tableView,
                sequence < tableView.numberOfSections {
                let animation: DiffRowAnimation = animatedChange ? .fade : .none
                tableView.apply(diff, deletionAnimation: animation, insertionAnimation: animation, indexPathTransform: { (indexPath) -> IndexPath in
                    IndexPath(row: indexPath.row, section: self.sequence)
                })
            }
            if wasAtEnd && autoScroll {
                scrollToEnd(animated: true)
            }
        } else {
            tableView?.reloadData()
            if wasAtEnd && autoScroll {
                scrollToEnd(animated: false)
            }
        }
        header?.bringToFront()
    }

    override open func update(diff: Diff, patches: [Patch<ModelObjectProtocol>], current: [ModelObjectProtocol]?) {
        let wasAtEnd = isTableAtEnd()
        super.update(diff: diff, patches: patches, current: current)
        if wasAtEnd && autoScroll {
            scrollToEnd(animated: true)
        }
    }

    private func lastIndexPath() -> IndexPath? {
        if let count = current?.count, count > 0 {
            return IndexPath(item: count - 1, section: sequence)
        } else {
            return nil
        }
    }

    public func isTableAtEnd() -> Bool {
        if let indexPath = lastIndexPath() {
            if let visible = tableView?.indexPathsForVisibleRows {
                return visible.contains(indexPath)
            }
        }
        return true
    }

    public func scrollToEnd(animated: Bool) {
        if animated {
            DispatchQueue.main.async { [weak self] in
                if let self = self {
                    if let indexPath = self.lastIndexPath() {
                        self.tableView?.scrollToRow(at: indexPath, at: .bottom, animated: animated)
                    }
                }
            }
        } else {
            if let indexPath = lastIndexPath() {
                tableView?.scrollToRow(at: indexPath, at: .bottom, animated: animated)
                scrollToEnd(animated: true)
            }
        }
    }

    override open func refresh(animated: Bool, completion: (() -> Void)?) {
        if animated {
            UIView.animate(tableView, type: .fade, direction: .none, duration: UIView.defaultAnimationDuration, animations: { [weak self] in
                if let self = self {
                    self.tableView?.reloadData()
                    completion?()
                }
            }, completion: nil)
        } else {
            tableView?.reloadData()
            completion?()
        }
    }

    open func cell(indexPath: IndexPath) -> UITableViewCell? {
        let object = self.object(at: indexPath.row)
        return cell(object: object, indexPath: indexPath)
    }

    open func cell(object: ModelObjectProtocol?, indexPath: IndexPath) -> UITableViewCell? {
        if let xib = xib(object: object), let tableView = tableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: xib, for: indexPath)
            (cell as? SelectableProtocol)?.isSelected = tableView.indexPathsForSelectedRows?.contains(indexPath) ?? false
            let height = cell.frame.size.height
            cell.frame = CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: height)
            let backgroundView = UIView()
            backgroundView.backgroundColor = UIColor.clear
            cell.selectedBackgroundView = backgroundView
            if let presenterCell = cell as? ObjectPresenterTableViewCell {
                presenterCell.setXib(xib, parentViewController: tableView.viewController())
                let selected = (object as? SelectableProtocol)?.isSelected ?? false
                presenterCell.isSelected = selected
                presenterCell.model = object
                presenterCell.isFirst = indexPath.row == 0
                if let count = current?.count {
                    presenterCell.isLast = indexPath.row == count - 1
                } else {
                    presenterCell.isLast = false
                }
            }
            return cell
        }
        return nil
    }

    open func select(to indexPath: IndexPath) {
        select(index: indexPath.row) { [weak self] deselect in
            if deselect {
                self?.tableView?.deselectRow(at: indexPath, animated: true)
            } else {
                (self?.tableView as? UXTableView)?.updateLayout()
            }
        }
    }

    open func deselect(indexPath: IndexPath) {
        deselect(index: indexPath.row)
        (tableView as? UXTableView)?.updateLayout()
    }

    open func headerView() -> UIView? {
        header = headerView(interactor: interactor)
        return header
    }

    open func headerView(interactor: ListInteractor?) -> UIView? {
        if let interactor = interactor, interactor.title != nil, let xib = headerXib(object: interactor) {
            let view = tableView?.dequeueReusableHeaderFooterView(withIdentifier: xib)
            (view as? XibTableViewHeaderFooterView)?.xib = xib
            (view as? ObjectPresenterProtocol)?.model = interactor
            return view
        }
        return nil
    }

    open func headerViewSize() -> CGFloat? {
        return headerViewSize(interactor: interactor)
    }

    open func headerViewSize(interactor: ListInteractor?) -> CGFloat? {
        if let interactor = interactor, interactor.title != nil, let xib = xib(object: interactor) {
            return defaultSize(xib: xib)?.height
        }
        return nil
    }

    open func footerView() -> UIView? {
        return footerView(interactor: interactor)
    }

    open func footerView(interactor: ListInteractor?) -> UIView? {
        return nil
    }

    open func footerViewSize() -> CGFloat? {
        return footerViewSize(interactor: interactor)
    }

    open func footerViewSize(interactor: ListInteractor?) -> CGFloat? {
        return nil
    }

    private var scrollDebouncer: Debouncer = Debouncer()

    override open func changed(selected: [ModelObjectProtocol]?) {
        if let tableView = tableView {
            let selectedIndexPaths = Set(tableView.indexPathsForSelectedRows ?? [IndexPath]())
            for i in 0 ..< (current?.count ?? 0) {
                let object = self.object(at: i)
                let indexPath = IndexPath(row: i, section: sequence)
                if let selected = selected, selected.contains(where: { (item) -> Bool in
                    item === object
                }) {
                    if !selectedIndexPaths.contains(indexPath) {
                        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
                        if let handler = scrollDebouncer.debounce() {
                            handler.run({ [weak self] in
                                self?.scroll(to: object)
                            }, delay: 0.51)
                        }
                    }
                } else {
                    if selectedIndexPaths.contains(indexPath) {
                        tableView.deselectRow(at: IndexPath(row: i, section: sequence), animated: true)
                    }
                }
            }
        }
    }

    open func scroll(to object: ModelObjectProtocol?) {
        if scrollToSelection {
            if let row = index(of: object) {
                let indexPath = IndexPath(row: row, section: sequence)
                if let visible = tableView?.indexPathsForVisibleRows, let first = visible.first, let last = visible.last {
                    if indexPath.section < first.section {
                        tableView?.scrollToRow(at: indexPath, at: .top, animated: true)
                    } else if indexPath.section > last.section {
                        tableView?.scrollToRow(at: indexPath, at: .bottom, animated: true)
                    } else if indexPath.section == first.section {
                        if indexPath.row < first.row {
                            tableView?.scrollToRow(at: indexPath, at: .top, animated: true)
                        } else if indexPath.row > last.row {
                            tableView?.scrollToRow(at: indexPath, at: .bottom, animated: true)
                        } else if indexPath.row == first.row {
                            tableView?.scrollToRow(at: indexPath, at: .middle, animated: true)
                        } else if indexPath.row == last.row {
                            tableView?.scrollToRow(at: indexPath, at: .middle, animated: true)
                        }
                    }
                }
            }
        } else {
            pendingScroll = object
        }
    }
}
