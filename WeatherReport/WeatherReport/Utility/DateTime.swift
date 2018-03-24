//
//  DateTime.swift
//  WeatherReport
//
//  Created by Jha on 21/03/18.
//  Copyright © 2018 Jha. All rights reserved.
//

import Foundation

struct DateTime {
    
    let year: Int
    let month: Int
    let day: Int
    let weekDay : Int
    
    static func fromComponents(components: DateComponents) -> DateTime {
        return DateTime(year: components.year!, month: components.month!, day: components.day!, weekDay: components.weekday!)
    }
    
    func dateComponents() -> DateComponents {
        var component = DateComponents()
        component.year = year
        component.month = month
        component.day = day
        component.weekday = weekDay
        return component
    }
    
    func date() -> Date? {
        return NSCalendar.current.date(from: dateComponents() as DateComponents)! as Date
    }
    
    func getDayName() -> String {
        switch weekDay {
        case 1:
            return "Sunday"
        case 2:
            return "Monday"
        case 3:
            return "Tueday"
        case 4:
            return "Wednesday"
        case 5:
            return "Thursday"
        case 6:
            return "Friday"
        case 7:
            return "Saturday"
        default:
            print("Error fetching days")
            return "Day"
        }
    }
}

