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
    
    var listEventVisible: [EventObject] = [EventObject]()
    var eventEdit = EventObject()
    let uiUtils = UIUtils()
    private let userDefaults = UserDefaults.standard
    private let keyUserDefaults: String = "event_list_key"
    private(set) var eventList:[EventObject] {
        
        get {
            if let eventistData = userDefaults.object(forKey: keyUserDefaults) {
                if let eventlist = NSKeyedUnarchiver.unarchiveObject(with: eventistData as! Data) {
                    return eventlist as! [EventObject]
                }
            }
            return []
        }
        
        set(eventlist) {
            let eventistData = NSKeyedArchiver.archivedData(withRootObject: eventlist)
            userDefaults.set(eventistData, forKey: keyUserDefaults)
            userDefaults.synchronize()
        }
    }
    
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
        self.navigationItem.title = uiUtils.dateFormatter.string(from: fsCalendar.today!)
        
        
        // config calendar
        fsCalendar.select(Date())
        fsCalendar.allowsMultipleSelection = false
        fsCalendar.scope = .month
        fsCalendar.placeholderType = FSCalendarPlaceholderType.fillHeadTail
        fsCalendar.calendarHeaderView.backgroundColor = UIColor.black
        fsCalendar.calendarWeekdayView.backgroundColor = UIColor.black
        fsCalendar.backgroundColor = UIColor.black.withAlphaComponent(1)
        
        // config tableview
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 70
        
        
        self.view.addGestureRecognizer(self.scopeGesture)
        self.tableView.panGestureRecognizer.require(toFail: self.scopeGesture)
        loadData()
        tableView.reloadData()
        
        // reload page
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(ViewController.reloadPage(_:)),
                                               name: NSNotification.Name(rawValue: "addEventOK"),
                                               object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadData(){
        listEventVisible = getEventOfDate(inDate: Date())
    }
    
    // load page
    func reloadPage(_ notification: Notification){
        if (notification.name.rawValue == "addEventOK") {
            self.listEventVisible = self.getEventOfDate(inDate: self.fsCalendar.selectedDate!)
            self.fsCalendar.reloadData()
            self.tableView.reloadData()
        }
        
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
        listEventVisible = getEventOfDate(inDate: date)
        tableView.reloadData()
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let data = getEventOfDate(inDate: date)
        return data.count        
    }
    
    // MARK:- handle tableview
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listEventVisible.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell") as! EventCell
        let data = listEventVisible[indexPath.row]
        if data.eventId != 0 {
            cell.isHidden = false
            cell.lblEvent.text = data.eventName
            cell.lblNote.text = data.note
            if data.allDay {
                cell.lblDateTime.text = getTextDate(data: data)
            }else{
                cell.lblDateTime.text = getTextDate(data: data)
            }
            do{
                try cell.avatar.image = UIImage(data: Data.init(contentsOf: URL.init(fileURLWithPath: data.avatar) ))
            }catch{
                cell.avatar.image = UIImage(named: "Icon_Event.png")
            }
        }else{
            cell.isHidden = true
        }
        return cell
    }
    
    // action for row of tableview
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        // action edit
        let editAction = UITableViewRowAction(style: .default, title: "Edit", handler: { (action, indexPath) in
            self.eventEdit = self.listEventVisible[indexPath.row]
            self.performSegue(withIdentifier: "addEvent", sender: self)
        })
        editAction.backgroundColor = UIColor.orange
        
        // action delete
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete", handler: { (action, indexPath) in
            let alert = UIAlertController(title: "", message: "Do you want to delete this event", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "YES", style: UIAlertActionStyle.default, handler: { action in
                let addEventController = AddEventController()
                addEventController.saveEvent(event: self.listEventVisible[indexPath.row], isTypeAction: actionTypeOfEvent.delete)
                self.listEventVisible = self.getEventOfDate(inDate: self.fsCalendar.selectedDate!)
                self.fsCalendar.reloadData()
                self.tableView.reloadData()
            }))
            alert.addAction(UIAlertAction(title: "NO", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        })
        deleteAction.backgroundColor = UIColor.red
        
        return [deleteAction, editAction]
    }
    
    // get list event of select date
    func getEventOfDate(inDate : Date) -> [EventObject]{
        var result = [EventObject]()
        for eventItem in self.eventList {
            if inDate.isBetweenDates(startDate: eventItem.startDate, endDate: eventItem.endDate) {
                result.append(eventItem)
            }
        }
        return  result
    }
    
    func getTextDate(data: EventObject) -> String {
        if data.startDate.isSameDate(otherDate: data.endDate){
            return uiUtils.dateFormatter.string(from: data.startDate)
        }else{
            return uiUtils.dateFormatter.string(from: data.startDate)  + "-" + uiUtils.dateFormatter.string(from: data.endDate)
        }
    }
    
    // go to Today at calendar
    func gotoToday(){
        fsCalendar.select(fsCalendar.today, scrollToDate: true)
        fsCalendar.setCurrentPage(fsCalendar.today!, animated: true)
    }
    
    // goto add event screen
    func addEvent(){
        eventEdit = EventObject()
        self.performSegue(withIdentifier: "addEvent", sender: self)
    }
    
    // pass data to AddEventController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "addEvent" && self.eventEdit.eventId != 0) {
            let addEventController = segue.destination as! AddEventController
            addEventController.eventEdit = self.eventEdit
        }
    }
    
//    func createDataDummy() -> [EventObject] {
//        var listData = [EventObject]()
//        let utils = UIUtils()
//        listData.append(EventObject.init(eventId: 1, eventName: "hhhhhhhhhhh", startDate: utils.dateFormatter.date(from: "06/06/2017")!, endDate: utils.dateFormatter.date(from: "06/06/2017")!, startTime: "20:00", endTime: "22:15", note: "abcbcdsad", allDay: false))
//        listData.append(EventObject.init(eventId: 1, eventName: "Happy birthday", startDate: utils.dateFormatter.date(from: "15/06/2017")!, endDate: utils.dateFormatter.date(from: "15/06/2017")!, startTime: "20:00", endTime: "21:30", note: "abcbcdsad", allDay: false))
//        listData.append(EventObject.init(eventId: 1, eventName: "chịch", startDate: utils.dateFormatter.date(from: "26/06/2017")!, endDate: utils.dateFormatter.date(from: "26/06/2017")!, startTime: "20:00", endTime: "21:00", note: "abcbcdsad", allDay: false))
//        listData.append(EventObject.init(eventId: 1, eventName: "cc", startDate: utils.dateFormatter.date(from: "16/06/2017")!, endDate: utils.dateFormatter.date(from: "16/06/2017")!, startTime: "23:00", endTime: "00:00", note: "abcbcdsad", allDay: false))
//        listData.append(EventObject.init(eventId: 1, eventName: "sml", startDate: utils.dateFormatter.date(from: "11/06/2017")!, endDate: utils.dateFormatter.date(from: "11/06/2017")!, startTime: "21:00", endTime: "00:00", note: "abcbcdsad", allDay: false))
//        return listData
//    }
    
}

