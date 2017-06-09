//
//  EventObject.swift
//  PersonCalendar
//
//  Created by Macbook on 06/06/17.
//  Copyright © 2017 Macbook. All rights reserved.
//

import Foundation


class EventObject: NSObject, NSCoding {
    var eventId: Int
    var eventName: String
    var startDate: Date
    var endDate: Date
    var startTime: String
    var endTime: String
    var note: String
    var allDay: Bool
    
    
    init(eventId: Int, eventName: String, startDate: Date, endDate: Date, startTime: String, endTime: String, note: String, allDay: Bool) {
        self.eventId = eventId
        self.eventName = eventName
        self.startDate = startDate
        self.endDate = endDate
        self.startTime = startTime
        self.endTime = endTime
        self.note = note
        self.allDay = allDay
    }
    
    convenience override init(){
        self.init(eventId: 0, eventName: "", startDate: Date(), endDate: Date(), startTime: "", endTime: "", note: "", allDay: false)
    }
//    override init() {
//        code
//    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let eventId = aDecoder.decodeInteger(forKey: "eventId")
        let eventName = aDecoder.decodeObject(forKey: "eventName") as! String
        let startDate = aDecoder.decodeObject(forKey: "startDate") as! Date
        let endDate = aDecoder.decodeObject(forKey: "endDate") as! Date
        let startTime = aDecoder.decodeObject(forKey: "startTime") as! String
        let endTime = aDecoder.decodeObject(forKey: "endTime") as! String
        let note = aDecoder.decodeObject(forKey: "note") as! String
        let allDay = aDecoder.decodeObject(forKey: "allDay") as! Bool
        self.init(eventId: eventId, eventName: eventName, startDate: startDate, endDate: endDate, startTime: startTime, endTime: endTime, note: note, allDay: allDay)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(eventId, forKey: "eventId")
        aCoder.encode(eventName, forKey: "eventName")
        aCoder.encode(startDate, forKey: "startDate")
        aCoder.encode(endDate, forKey: "endDate")
        aCoder.encode(startTime, forKey: "startTime")
        aCoder.encode(endTime, forKey: "endTime")
        aCoder.encode(note, forKey: "note")
        aCoder.encode(allDay, forKey: "allDay")
    }
    
    func isEqual(object: AnyObject?) -> Bool {
        if let object = object as? EventObject {
            return self.eventId == object.eventId &&
                self.eventName == object.eventName
        } else {
            return false
        }
    }
}
