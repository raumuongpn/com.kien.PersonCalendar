//
//  AddEventController.swift
//  PersonCalendar
//
//  Created by Rau Muong on 6/7/17.
//  Copyright © 2017 Macbook. All rights reserved.
//
import Foundation
import UIKit

class AddEventController: UIViewController {
    
    @IBOutlet weak var tfEventName: UITextField!
    @IBOutlet weak var tfNote: UITextView!
    @IBOutlet weak var tfStartDate: UITextField!
    @IBOutlet weak var tfEndDate: UITextField!
    @IBOutlet weak var tfStartTime: UITextField!
    @IBOutlet weak var tfEndTime: UITextField!
    @IBOutlet weak var switchAllDay: UISwitch!
    @IBOutlet weak var imgView: UIImageView!
    
    let utils = UIUtils()
    
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
    
    var eventEdit = EventObject()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        //btn save
        let rightBtn = utils.buildButton(image: UIImage(), title: "Save", colorText: UIColor.colorFromRGB(0x3498db))
        rightBtn.addTarget(self, action: #selector(AddEventController.onClickBtnSave), for: .touchUpInside)
        let rightBtnBar = UIBarButtonItem()
        rightBtnBar.customView = rightBtn
        self.navigationItem.rightBarButtonItem = rightBtnBar
        // title view
        self.navigationItem.title = "Add New Event"
        // btn back
        self.navigationItem.backBarButtonItem?.title = "Back"
        tfNote.layer.borderWidth = 1
        tfNote.layer.borderColor = UIColor.lightGray.cgColor
        tfNote.layer.cornerRadius = 5
        
        if eventEdit.eventId != 0 {
            self.navigationItem.title = "Edit Event"
            loadDataToForm()
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func onClickBtnSave() {
        let eventId = eventEdit.eventId == 0 ? self.createEventId() : eventEdit.eventId
        let eventItem = EventObject.init(eventId: eventId, eventName: tfEventName.text!, startDate: utils.dateFormatter.date(from: tfStartDate.text!)!, endDate: utils.dateFormatter.date(from: tfEndDate.text!)!, startTime: tfStartTime.text!, endTime: tfEndTime.text!, note: tfNote.text!, allDay: switchAllDay.isOn)
        saveEvent(event: eventItem, isTypeAction: eventEdit.eventId == 0 ? actionTypeOfEvent.save : actionTypeOfEvent.edit)
    }
    
    func loadDataToForm(){
        tfEventName.text = eventEdit.eventName
        tfNote.text = eventEdit.note
        tfStartDate.text = utils.dateFormatter.string(from: eventEdit.startDate)
        tfEndDate.text = utils.dateFormatter.string(from: eventEdit.endDate)
        tfStartTime.text = eventEdit.startTime
        tfEndTime.text = eventEdit.endTime
        switchAllDay.isOn = eventEdit.allDay
    }
    
    func createEventId() -> Int {
        if self.eventList.count > 0 {
            let idMax = self.eventList.map{ $0.eventId }.max()
            return (idMax! + 1)
        }
        return 1
    }
    
    
    open func saveEvent(event: EventObject, isTypeAction: actionTypeOfEvent){
        var eventList = self.eventList
        switch isTypeAction {
        case .save:
            eventList.append(event)
        case .edit:
            if let index = eventList.index(where: {$0.eventId == event.eventId} ){
                eventList.remove(at: index)
                eventList.insert(event, at: index)
            }
        case .delete:
            if let index = eventList.index(where: {$0.eventId == event.eventId} ){
                eventList.remove(at: index)
            }
        }
        self.eventList = eventList
    }
}

enum actionTypeOfEvent: Int{
    case save
    case edit
    case delete
}
