//
//  ViewController.swift
//  PersonCalendar
//
//  Created by Macbook on 05/06/17.
//  Copyright © 2017 Macbook. All rights reserved.
//

import UIKit
import FSCalendar

class ViewController: UIViewController,FSCalendarDataSource, FSCalendarDelegate {

    @IBOutlet weak var fsCalendar: FSCalendar!
    @IBOutlet weak var heightCalendar: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // config calendar
        fsCalendar.select(Date())
        fsCalendar.allowsMultipleSelection = false
        fsCalendar.scope = .month
        fsCalendar.backgroundColor = UIColor.clear.withAlphaComponent(0.12)
        fsCalendar.calendarHeaderView.backgroundColor = UIColor.gray.withAlphaComponent(1)
        fsCalendar.calendarWeekdayView.backgroundColor = UIColor.white.withAlphaComponent(1)
        fsCalendar.placeholderType = FSCalendarPlaceholderType.fillHeadTail
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK:- handle calendar
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.heightCalendar.constant = bounds.height
        self.view.layoutIfNeeded()
    }

}

