//
//  NSDateExtensions.swift
//  Hyve V0.07
//
//  Created by Jonathan Tan on 6/26/16.
//  Copyright © 2016 Jonathan Tan. All rights reserved.
//

import UIKit

extension NSDate {
    func yearsFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Year, fromDate: date, toDate: self, options: []).year
    }
    func monthsFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Month, fromDate: date, toDate: self, options: []).month
    }
    func weeksFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.WeekOfYear, fromDate: date, toDate: self, options: []).weekOfYear
    }
    func daysFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Day, fromDate: date, toDate: self, options: []).day
    }
    func hoursFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Hour, fromDate: date, toDate: self, options: []).hour
    }
    func minutesFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Minute, fromDate: date, toDate: self, options: []).minute
    }
    func secondsFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Second, fromDate: date, toDate: self, options: []).second
    }
    func offsetFrom(date:NSDate) -> String {
//        if yearsFrom(date)   > 0 { return "\(yearsFrom(date))y"   }
//        if monthsFrom(date)  > 0 { return "\(monthsFrom(date))M"  }
//        if weeksFrom(date)   > 0 { return "\(weeksFrom(date))w"   }
        var lifeRemaining:String?
        if daysFrom(date) > 1 {
            lifeRemaining = "\(daysFrom(date)) days"
        } else {
            lifeRemaining = "\(daysFrom(date)) day"
        }
        if hoursFrom(date) > 1 {
            lifeRemaining = "\(lifeRemaining), \(hoursFrom(date)) hours"
        } else {
            lifeRemaining = "\(lifeRemaining), \(hoursFrom(date)) hour, "
        }
        if minutesFrom(date) > 1 {
            lifeRemaining = "\(lifeRemaining), \(minutesFrom(date)) minutes."
            return lifeRemaining!
        } else {
            lifeRemaining = "\(lifeRemaining), \(minutesFrom(date)) minute."
            return lifeRemaining!
        }
    }
}