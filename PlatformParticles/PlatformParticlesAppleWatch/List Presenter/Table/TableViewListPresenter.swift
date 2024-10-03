//
//  TableViewListPresenter.swift
//  PlatformParticlesAppleWatch
//
//  Created by Qiang Huang on 12/7/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import Differ
import ParticlesKit
import UIKit
import UIToolkits
import Utilities

open class TableViewListPresenter: XibListPresenter, UITableViewDataSource, UITableViewDelegate {
    @IBInspectable var parallax: Bool = false {
        didSet {
            tableViewXibRegister.parallax = parallax
        }
    }

    override open var selectionHandler: SelectionHandlerProtocol? {
        didSet {
            if selectionHandler !== oldValue {
                for section in sections {
                    section.tableView = tableView
                    section.selectionHandler = selectionHandler
                }
            }
        }
    }

    @IBInspectable var pullDownToRefresh: Bool = false {
        didSet {
            if pullDownToRefresh != oldValue {
                refreshControl = pullDownToRefresh ? UIRefreshControl() : nil
            }
        }
    }

    open var refreshControl: UIRefreshControl? {
        didSet {
            if refreshControl !== oldValue {
                if let refreshControl = refreshControl {
                    refreshControl.addTarget(self, action: #selector(pullDownToRefresh(_:)), for: .valueChanged)
                }
                tableView?.refreshControl = refreshControl
            }
        }
    }

    @IBInspectable var disclosure: Bool = false {
        didSet {
            if let cells = tableView?.visibleCells {
                for cell in cells {
                    cell.accessoryType = accessory(for: cell)
                }
            }
        }
    }

    @IBInspectable public var cellBackgroundColor: UIColor?
    @IBInspectable var sectionHeaderXib: String?
    @IBInspectable var sectionFooterXib: String?
    @IBInspectable var headerXib: String?
    @IBInspectable var footerXib: String?
    @IBInspectable var intMode: Int {
        get { return mode.rawValue }
        set { mode = PresenterMode(rawValue: newValue) ?? .linear }
    }

    @IBInspectable var animatedChange: Bool = false {
        didSet {
            if animatedChange != oldValue {
                for section in sections {
                    section.animatedChange = animatedChange
                }
            }
        }
    }

    @IBInspectable var scrollToSelection: Bool = false {
        didSet {
            if scrollToSelection != oldValue {
                for section in sections {
                    section.scrollToSelection = scrollToSelection && (visible ?? false)
                }
            }
        }
    }

    override open var visible: Bool? {
        didSet {
            if visible != oldValue {
                for section in sections {
                    section.scrollToSelection = scrollToSelection && (visible ?? false)
                }
            }
        }
    }

    @IBOutlet open var tableView: UITableView? {
        didSet {
            if tableView !== oldValue {
                oldValue?.dataSource = nil
                oldValue?.delegate = nil
                tableView?.dataSource = self
                tableView?.delegate = self
                tableViewXibRegister.tableView = tableView
                for section in sections {
                    section.tableView = tableView
                    section.selectionHandler = selectionHandler
                }
                if interactor != nil {
                    refresh(animated: false) { [weak self] in
                        self?.updateCompleted(firstContent: true)
                    }
                }
                if let headerView: UIView = XibLoader.load(from: headerXib) {
                    headerView.autoresizingMask = .flexibleWidth
                    headerView.translatesAutoresizingMaskIntoConstraints = true
                    tableView?.tableHeaderView = headerView
                }
                if let footerView: UIView = XibLoader.load(from: footerXib) {
                    footerView.autoresizingMask = .flexibleWidth
                    footerView.translatesAutoresizingMaskIntoConstraints = true
                    tableView?.tableFooterView = footerView
                }
                tableView?.refreshControl = refreshControl
            }
        }
    }

    private var debouncer: Debouncer = Debouncer()

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

    private var tableViewXibRegister: TableViewXibRegister = TableViewXibRegister()
    private var tableViewHeaderXibRegister: TableViewHeaderXibRegister = TableViewHeaderXibRegister()
    open var sections: [TableViewSectionListPresenter] = []

    override open var title: String? {
        return "List"
    }

    override open var icon: UIImage? {
        return UIImage.named("view_list", bundles: Bundle.particles)
    }

    open override func didSetInteractor(oldValue: ListInteractor?) {
        super.didSetInteractor(oldValue: oldValue)
        if interactor != oldValue {
            switch mode {
            case .linear:
                sections.removeAll()
                if let interactor = interactor {
                    sections.append(section(for: interactor, index: 0))
                }
                refresh(animated: true) { [weak self] in
                    self?.updateCompleted(firstContent: true)
                }

            case .sections:
                break
            }
        }
    }

    open override func didSetCurrent(oldValue: [ModelObjectProtocol]?) {
        super.didSetCurrent(oldValue: oldValue)
        if mode == .sections, let list = current as? [ListInteractor] {
            var index = 0
            self.sections = list.map({ (child: ListInteractor) -> TableViewSectionListPresenter in
                let tableSection = section(for: child, index: index)
                index += 1
                return tableSection
            })
        }
    }

    internal func section(for interactor: ListInteractor, index: Int) -> TableViewSectionListPresenter {
        let section = self.section(with: interactor) ?? TableViewSectionListPresenter()
        if section.xibRegister !== tableViewXibRegister {
            section.xibRegister = tableViewXibRegister
        }
        if section.headerXibRegister !== tableViewHeaderXibRegister {
            section.headerXibRegister = tableViewHeaderXibRegister
        }
        if section.xibMap != xibMap {
            section.xibMap = xibMap
        }
        if section.sequence != index {
            section.sequence = index
        }
        if section.interactor !== interactor {
            section.interactor = interactor
        }
        if section.selectionHandler !== selectionHandler {
            section.selectionHandler = selectionHandler
        }
        if section.sectionHeaderXib != sectionHeaderXib {
            section.sectionHeaderXib = sectionHeaderXib
        }
        if section.sectionFooterXib != sectionFooterXib {
            section.sectionFooterXib = sectionFooterXib
        }
        section.animatedChange = animatedChange
        section.scrollToSelection = scrollToSelection
        if section.tableView !== tableView {
            section.tableView = tableView
        }
        return section
    }

    internal func section(with interactor: ListInteractor) -> TableViewSectionListPresenter? {
        return sections.first(where: { (presenter) -> Bool in
            presenter.interactor === interactor
        })
    }

    override open func refresh(animated: Bool, completion: (() -> Void)?) {
        if animated {
            refreshControl?.endRefreshing()
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

    open func numberOfSections(in tableView: UITableView) -> Int {
        if interactor == nil {
            return 0
        } else {
            return mode == .sections ? sections.count : 1
        }
    }

    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if mode == .sections {
            let sectionPresenter = sections[section]
            return sectionPresenter.count ?? 0
        } else {
            return sections.first?.count ?? 0
        }
    }

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let section = (mode == .sections) ? sections[indexPath.section] : sections.first {
            let cell = section.cell(indexPath: indexPath) ?? UITableViewCell()
            if tableView.estimatedRowHeight <= 0 {
                tableView.estimatedRowHeight = cell.frame.size.height
            }
            cell.accessoryType = accessory(for: cell)
            if let cellBackgroundColor = cellBackgroundColor {
                cell.backgroundColor = cellBackgroundColor
            }
            if ((cell as? ObjectPresenterTableViewCell)?.presenterView as? ObjectPresenterProtocol)?.selectable ?? false {
                cell.selectionStyle = tableView.allowsMultipleSelection ? .none : .default
            } else {
                cell.selectionStyle = .none
            }
            return cell
        } else {
            return UITableViewCell()
        }
    }

    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            UserInteraction.shared.sender = cell
        }
        if let section = (mode == .sections) ? sections[indexPath.section] : sections.first {
            section.select(to: indexPath)
        }
    }

    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let section = (mode == .sections && indexPath.section < sections.count) ? sections[indexPath.section] : sections.first {
            section.deselect(indexPath: indexPath)
        }
    }

    open func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if let section = (mode == .sections && indexPath.section < sections.count) ? sections[indexPath.section] : sections.first {
            if let size = section.defaultSize(at: indexPath.row) {
                return size.height
            }
        }
        return 44
    }

    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let tableSection = (mode == .sections) ? sections[section] : sections.first {
            return tableSection.headerViewSize() ?? defaultSize(xib: tableSection.sectionHeaderXib)?.height ?? 0
        }
        return 0
    }

    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let tableSection = (mode == .sections) ? sections[section] : sections.first {
            return tableSection.headerView() ?? accessoryView(xib: tableSection.sectionHeaderXib, section: section)
        }
        return nil
    }

    open func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if let tableSection = (mode == .sections) ? sections[section] : sections.first {
            if let footerView = tableSection.footerView() {
                return footerView.frame.size.height
            } else if let size = defaultSize(xib: tableSection.sectionFooterXib) {
                return size.height
            }
        }
        return 0
    }

    open func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if let tableSection = (mode == .sections) ? sections[section] : sections.first {
            return tableSection.footerView() ?? accessoryView(xib: tableSection.sectionFooterXib, section: section)
        }
        return nil
    }

    open func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    open func accessoryView(xib: String?, section: Int) -> UIView? {
        if let view: UIView = XibLoader.load(from: xib) {
            if let presenterView: ObjectPresenterView = view as? ObjectPresenterView {
                if mode == .linear {
                    presenterView.model = interactor?.parent
                } else {
                    presenterView.model = object(at: section)
                }
            }
            return view
        }
        return nil
    }

    open func accessory(for cell: UITableViewCell) -> UITableViewCell.AccessoryType {
        return showDisclosure(cell: cell) ? .disclosureIndicator : .none
    }

    open func showDisclosure(cell: UITableViewCell) -> Bool {
        if let presentingCell = cell as? ObjectPresenterTableViewCell {
            return presentingCell.showDisclosure ?? disclosure
        }
        return disclosure
    }

    override open func update() {
        if tableView != nil {
            let firstContent = (current == nil)
            if mode == .sections {
                current = pending
                refresh(animated: true) { [weak self] in
                    self?.updateCompleted(firstContent: firstContent)
                }
            } else {
                update(move: true)
                updateCompleted(firstContent: firstContent)
            }
        } else {
            current = pending
        }
    }

    override open func update(diff: Diff, patches: [Patch<ModelObjectProtocol>], current: [ModelObjectProtocol]?) {
        tableView?.performBatchUpdates({
            for change in patches {
                switch change {
                case let .deletion(index):
                    tableView?.deleteSections(IndexSet(integer: index), with: .fade)

                case let .insertion(index: index, element: _):
                    tableView?.insertSections(IndexSet(integer: index), with: .fade)
                }
            }
        }, completion: nil)
    }

    override open func updateLayout() {
        if let handler = debouncer.debounce() {
            handler.run({ [weak self] in
                if let self = self {
                    self.tableView?.beginUpdates()
                    self.tableView?.endUpdates()
                    Console.shared.log("endUpdate/updateLayout")
                }
            }, delay: 0.5)
        }
    }

    @objc open func pullDownToRefresh(_ sender: Any?) {
    }

    override open func changed(selected: [ModelObjectProtocol]?) {
        if let tableSection = (mode == .sections) ? nil : sections.first {
            tableSection.changed(selected: selected)
        }
    }
}

extension TableViewListPresenter {
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if parallax {
            (cell as? ParallaxObjectPresenterTableViewCell)?.parallax(animated: true)
        }
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if parallax {
            if let visibleCells = tableView?.visibleCells {
                for cell in visibleCells {
                    (cell as? ParallaxObjectPresenterTableViewCell)?.parallax(animated: true)
                }
            }
        }
    }
}
