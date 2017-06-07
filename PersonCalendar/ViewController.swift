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
            if item.eventDate.compare(selectDate) == .orderedSame {
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
        listData.append(EventObject.init(eventId: 1, eventName: "Birthday Name", eventDate: dateFormatter.date(from: "06/06/2017")!, startTime: "20:00", endTime: "00:00"))
        listData.append(EventObject.init(eventId: 2, eventName: "Đá bóng", eventDate: dateFormatter.date(from: "20/06/2017")!, startTime: "17:00", endTime: "19:00"))
        listData.append(EventObject.init(eventId: 3, eventName: "Đi Địt", eventDate: dateFormatter.date(from: "22/06/2017")!, startTime: "22:00", endTime: "22:01"))
        listData.append(EventObject.init(eventId: 4, eventName: "Birthday CC", eventDate: dateFormatter.date(from: "11/06/2017")!, startTime: "11:00", endTime: "12:00"))
        listData.append(EventObject.init(eventId: 5, eventName: "SML test", eventDate: dateFormatter.date(from: "01/06/2017")!, startTime: "1:00", endTime: "2:00"))
        return listData
    }
    
}

