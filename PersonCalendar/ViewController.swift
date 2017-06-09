//
//  ViewController.swift
//  PersonCalendar
//
//  Created by Macbook on 05/06/17.
//  Copyright © 2017 Macbook. All rights reserved.
//

import UIKit
import FSCalendar

class ViewController: UIViewController,FSCalendarDataSource, FSCalendarDelegate, UIGestureRecognizerDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var fsCalendar: FSCalendar!
    @IBOutlet weak var heightCalendar: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    var currentDate:Date = Date()
    var listEvent = [EventObject]()
    
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter
    }()
    
    fileprivate lazy var scopeGesture: UIPanGestureRecognizer = {
        [unowned self] in
        let panGesture = UIPanGestureRecognizer(target: self.fsCalendar, action: #selector(self.fsCalendar.handleScopeGesture(_:)))
        panGesture.delegate = self
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 2
        return panGesture
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        let uiUtils = UIUtils()
        //btn today
        let button = uiUtils.buildButton(image: UIImage(), title: "Today", colorText: UIColor.colorFromRGB(0x3498db))
        button.addTarget(self, action: #selector(ViewController.gotoToday), for: .touchUpInside)
        let barButton = UIBarButtonItem()
        barButton.customView = button
        self.navigationItem.leftBarButtonItem = barButton
        //btn add
        let rightBtn = uiUtils.buildButton(image: UIImage(), title: "Add", colorText: UIColor.colorFromRGB(0x3498db))
        rightBtn.addTarget(self, action: #selector(ViewController.addEvent), for: .touchUpInside)
        let rightBtnBar = UIBarButtonItem()
        rightBtnBar.customView = rightBtn
        self.navigationItem.rightBarButtonItem = rightBtnBar
        self.navigationItem.title = dateFormatter.string(from: fsCalendar.today!)
        
        
        // config calendar
        fsCalendar.select(Date())
        fsCalendar.allowsMultipleSelection = false
        fsCalendar.scope = .month
        fsCalendar.placeholderType = FSCalendarPlaceholderType.fillHeadTail
        
        // config tableview
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 70
        listEvent = createDataDummy()
        
        
        self.view.addGestureRecognizer(self.scopeGesture)
        self.tableView.panGestureRecognizer.require(toFail: self.scopeGesture)
        
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:- UIGestureRecognizerDelegate
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let shouldBegin = self.tableView.contentOffset.y <= -self.tableView.contentInset.top
        if shouldBegin {
            let velocity = self.scopeGesture.velocity(in: self.view)
            switch self.fsCalendar.scope {
            case .month:
                return velocity.y < 0
            case .week:
                return velocity.y > 0
            }
        }
        return shouldBegin
    }
    
    // MARK:- handle calendar
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.heightCalendar.constant = bounds.height
        self.view.layoutIfNeeded()
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        if monthPosition == .next || monthPosition == .previous {
            calendar.setCurrentPage(date, animated: true)
        }
        currentDate = date
        tableView.reloadData()
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        var numb = 0
        for item in listEvent {
            if item.startDate.compare(date) == .orderedSame {
               numb += 1
            }
        }
        return numb
        
    }
    
    // MARK:- handle tableview
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell") as! EventCell
        let data = getDataFromDate(selectDate: currentDate)
        if data.eventId != 0 {
            cell.isHidden = false
            cell.lblDate.text = dateFormatter.string(from: currentDate)
            cell.lblEvent.text = data.eventName
            cell.lblTime.text = data.startTime + "-" + data.endTime
        }else{
            cell.isHidden = true
        }
        return cell
    }
    
    func getDataFromDate(selectDate: Date) -> EventObject{
        for item in listEvent {
            if item.startDate.compare(selectDate) == .orderedSame {
                return item
            }
        }
        return EventObject.init()
    }
    
    func gotoToday(){
        fsCalendar.select(fsCalendar.today, scrollToDate: true)
        fsCalendar.setCurrentPage(fsCalendar.today!, animated: true)
    }
    
    func addEvent(){
        self.performSegue(withIdentifier: "addEvent", sender: self)
    }
    
    func createDataDummy() -> [EventObject] {
        var listData = [EventObject]()
        
        listData.append(EventObject.init(eventId: 1, eventName: "hhhhhhhhhhh", startDate: dateFormatter.date(from: "06/06/2017")!, endDate: dateFormatter.date(from: "06/06/2017")!, startTime: "20:00", endTime: "22:15", note: "abcbcdsad", allDay: false))
        listData.append(EventObject.init(eventId: 1, eventName: "Happy birthday", startDate: dateFormatter.date(from: "15/06/2017")!, endDate: dateFormatter.date(from: "15/06/2017")!, startTime: "20:00", endTime: "21:30", note: "abcbcdsad", allDay: false))
        listData.append(EventObject.init(eventId: 1, eventName: "chịch", startDate: dateFormatter.date(from: "26/06/2017")!, endDate: dateFormatter.date(from: "26/06/2017")!, startTime: "20:00", endTime: "21:00", note: "abcbcdsad", allDay: false))
        listData.append(EventObject.init(eventId: 1, eventName: "cc", startDate: dateFormatter.date(from: "16/06/2017")!, endDate: dateFormatter.date(from: "16/06/2017")!, startTime: "23:00", endTime: "00:00", note: "abcbcdsad", allDay: false))
        listData.append(EventObject.init(eventId: 1, eventName: "sml", startDate: dateFormatter.date(from: "11/06/2017")!, endDate: dateFormatter.date(from: "11/06/2017")!, startTime: "21:00", endTime: "00:00", note: "abcbcdsad", allDay: false))
        return listData
    }
    
}

