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
    var eventDate: Date
    var startTime: String
    var endTime: String
    
    
    init(eventId: Int, eventName: String, eventDate: Date, startTime: String, endTime: String) {
        self.eventId = eventId
        self.eventName = eventName
        self.eventDate = eventDate
        self.startTime = startTime
        self.endTime = endTime
    }
    
    override init(){
        self.eventId = 0
        self.eventName = ""
        self.eventDate = Date()
        self.startTime = ""
        self.endTime = ""
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let eventId = aDecoder.decodeInteger(forKey: "eventId")
        let eventName = aDecoder.decodeObject(forKey: "eventName") as! String
        let eventDate = aDecoder.decodeObject(forKey: "eventDate") as! Date
        let startTime = aDecoder.decodeObject(forKey: "startTime") as! String
        let endTime = aDecoder.decodeObject(forKey: "endTime") as! String
        self.init(eventId: eventId, eventName: eventName, eventDate: eventDate,startTime: startTime, endTime: endTime)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(eventId, forKey: "eventId")
        aCoder.encode(eventName, forKey: "eventName")
        aCoder.encode(eventDate, forKey: "eventDate")
        aCoder.encode(startTime, forKey: "startTime")
        aCoder.encode(endTime, forKey: "endTime")
    }
}
