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
    
//    var eventEdit = EventObject()


    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func saveEvent(event: EventObject){
        var eventList = self.eventList
        eventList.append(event)
        self.eventList = eventList
    }
    
    func removeEvent(event: EventObject) {
        var eventList = self.eventList
        if let index = eventList.index(where: {$0.eventId == event.eventId} ){
            eventList.remove(at: index)
            self.eventList = eventList
        }
    }

}
