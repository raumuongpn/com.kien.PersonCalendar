//
//  PopupSelectDate.swift
//  PersonCalendar
//
//  Created by Rau Muong on 6/14/17.
//  Copyright © 2017 Macbook. All rights reserved.
//

import UIKit
import FSCalendar

class PopupSelectDate:UIViewController ,FSCalendarDataSource, FSCalendarDelegate{
    
    @IBOutlet weak var fsCalendar: FSCalendar!
    let uiUtils = UIUtils()
    
    var selectDate = Date()
    var dateOf = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        // config calendar
        fsCalendar.select(selectDate)
        fsCalendar.allowsMultipleSelection = false
        fsCalendar.scope = .month
        fsCalendar.placeholderType = FSCalendarPlaceholderType.fillHeadTail
        
        showAnimate()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        if monthPosition == .next || monthPosition == .previous {
            calendar.setCurrentPage(date, animated: true)
        }
        let data = ["selectDate": uiUtils.dateFormatter.string(from: date), "dateOf": dateOf]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "selectDate"), object: nil, userInfo: data)
        
        removeAnimate()
    }
    
    func showAnimate()
    {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0;
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        });
    }
    
    func removeAnimate()
    {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0;
        }, completion:{(finished : Bool)  in
            if (finished)
            {
                self.view.removeFromSuperview()
            }
        });
    }
}
