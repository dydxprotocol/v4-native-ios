//
//  CalendarViewListPresenter.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 12/21/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import JTCalendar
import ParticlesKit

open class CalendarViewListPresenter: NativeListPresenter, JTCalendarDelegate {
    open var dates: [Date: [DateModelObjectProtocol]]? {
        didSet {
            manager?.reload()
            updateSelected()
        }
    }

    private var selected: Date? {
        didSet {
            if selected != oldValue {
                updateSelected()
            }
        }
    }

    @IBOutlet public var menu: JTCalendarMenuView? {
        didSet {
            if menu !== oldValue {
                updateManager()
            }
        }
    }

    @IBOutlet public var calendar: JTHorizontalCalendarView? {
        didSet {
            if calendar !== oldValue {
                updateManager()
            }
        }
    }

    @IBOutlet public var selectedListPresenter: ListPresenter? {
        didSet {
            selectedListPresenter?.visible = true
            updateSelected()
        }
    }

    public var manager: JTCalendarManager? {
        didSet {
            if manager !== oldValue {
                oldValue?.delegate = nil
                manager?.delegate = self
            }
        }
    }

    override open var title: String? {
        return "Calendar"
    }

    override open var icon: UIImage? {
        return UIImage.named("view_calendar", bundles: Bundle.particles)
    }

    private func updateManager() {
        if let menu = menu, let calendar = calendar {
            manager = JTCalendarManager()
            manager?.menuView = menu
            manager?.contentView = calendar
            let now = DateService.shared?.now() ?? Date()
            manager?.setDate(now)
        } else {
            manager = nil
        }
    }

    @objc(calendar:prepareDayView:)
    public func calendar(_ calendar: JTCalendarManager?, prepareDayView dayView: (UIView & JTCalendarDay)?) {
        if let dayView = dayView, let day = dayView.date() {
            let hasData = (dates?[day] != nil)
            let selectedMonth = !dayView.isFromAnotherMonth()
            let now = DateService.shared?.now() ?? Date()
            let today = manager?.dateHelper?.date(now, isTheSameDayThan: day) ?? false
            let selected = manager?.dateHelper?.date(self.selected, isTheSameDayThan: day) ?? false
            if today && self.selected == nil {
                self.selected = day
            }

            update(dayView: dayView as! JTCalendarDayView, today: today, selectedMonth: selectedMonth, selected: selected, hasData: hasData)
        }
    }

    @objc func update(dayView: JTCalendarDayView, today: Bool, selectedMonth: Bool, selected: Bool, hasData: Bool) {
        /* Appearance we can set:
         textLabel: font and color
         circleView: visibility and background color
         dotView: visibility and background color
         */
        /*
         Use dot to indicate whether there is data
         Use circle to indicate selected date or today
         Use font color to indicate whether it is in the selected month
         */

        let showCircle = selected || today

        dayView.dotView.isHidden = !hasData
        dayView.dotView.backgroundColor = showCircle ? UIColor.white : UIColor.orange

        dayView.circleView.isHidden = !showCircle
        if showCircle {
            if today {
                dayView.circleView.backgroundColor = UIColor.blue
            } else {
                dayView.circleView.backgroundColor = UIColor.red
            }
        }

        if showCircle {
            dayView.textLabel.textColor = selectedMonth ? UIColor.white : UIColor.lightGray
        } else {
            dayView.textLabel.textColor = selectedMonth ? UIColor.black : UIColor.gray
        }
    }

    @objc(calendar:didTouchDayView:)
    public func calendar(_ calendar: JTCalendarManager?, didTouchDayView dayView: (UIView & JTCalendarDay)?) {
        if let dayView = dayView as? JTCalendarDayView {
            // Use to indicate the selected date
            selected = dayView.date()
            if let _ = selected {
                // Animation for the circleView
                dayView.circleView.transform =
                    CGAffineTransform.identity.scaledBy(x: 0.1, y: 0.1)
                UIView.transition(with: dayView, duration: 0.3, options: [], animations: {
                    dayView.circleView.transform = CGAffineTransform.identity
                    self.manager?.reload()
                })

                // Load the previous or next page if touch a day from another month
                if let manager = manager, let date = calendar?.date(), let dayViewDate = dayView.date {
                    if !(manager.dateHelper?.date(date, isTheSameMonthThan: dayView.date()) ?? false) {
                        if calendar?.date().compare(dayViewDate) == .orderedAscending {
                            self.calendar?.loadNextPageWithAnimation()
                        } else {
                            self.calendar?.loadPreviousPageWithAnimation()
                        }
                    }
                }
            }
        }
    }

    override open func update() {
        current = pending
        refresh(animated: true, completion: nil)
    }

    override open func refresh(animated: Bool, completion: (() -> Void)?) {
        update(with: current)
        completion?()
    }

    open func update(with objects: [ModelObjectProtocol]?) {
        if let objects = objects {
            var dates: [Date: [DateModelObjectProtocol]] = [:]
            for item in objects {
                if let dateItem = item as? (DateModelObjectProtocol), let date = dateItem.date {
                    var list = dates[date]
                    if list == nil {
                        list = []
                    }
                    list?.append(dateItem)
                    dates[date] = list
                }
            }
            self.dates = dates
        } else {
            dates = nil
        }
    }

    open func updateSelected() {
        if let selected = selected {
            let items = dates?[selected]
            let interactor = ListInteractor()
            interactor.list = items
            selectedListPresenter?.interactor = interactor
        } else {
            selectedListPresenter?.interactor = nil
        }
    }
}
