//
//  DueDate.swift
//  CalculateDueDate
//
//  Created by Attila Molnár on 2019. 02. 02..
//  Copyright © 2019. Attila Molnár. All rights reserved.
//

import Foundation

struct DueDate {
    private let workStart : Int = 9
    private let workEnd : Int = 17
    
    private let numberOfSecondsInAnHour = 3600
    private let numberOfHoursInADay = 24
    
    /**
    Calculate dueDate based on turnaround time and submit date
     - Parameters:
        - submitDate : date of the issue submission
        - turnaroundTime : turnaround time in hours
     - Returns:
        - turnaroundDate : a date when the issue is to be solved
    */
    public static func calculateDueDate(submitDate : Date, turnaroundTime : Int) -> Date? {
        do {
            return try DueDate().calculateDueDate(submitDate: submitDate, turnaroundTime: turnaroundTime)
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
    }
    
    private func calculateDueDate(submitDate : Date, turnaroundTime : Int) throws -> Date {
        if checkSubmitDateValidity(submitDate: submitDate) {
            let shift = calculateShift(submitDate: submitDate, turnaroundTime: turnaroundTime)
            let calendar = Calendar.init(identifier: Calendar.Identifier.iso8601)
            
            guard var finalDate = calendar.date(byAdding: Calendar.Component.second, value: shift, to: submitDate) else {
                throw NSError(domain: "Unknown error in date calculation", code: -1, userInfo: nil)
            }
            
            let weekendShift = skipWeekend(date: finalDate)
            if weekendShift != 0 {
                finalDate = calendar.date(byAdding: Calendar.Component.second, value: weekendShift, to: finalDate) ?? finalDate
            }
            
            let dstShift = checkDaylightSavingTimeChange(dateFrom: submitDate, dateTo: finalDate)
            if dstShift != 0 {
                finalDate = calendar.date(byAdding: Calendar.Component.second, value: dstShift, to: finalDate) ?? finalDate
            }
            
            return finalDate
        } else {
            throw NSError(domain: "Provided submit date is out of working hours range", code: -1, userInfo: nil)
        }
    }
    
    private func calculateShift(submitDate : Date, turnaroundTime : Int) -> Int {
        let workingHoursLength = workEnd - workStart
        let reminder = turnaroundTime % workingHoursLength
        let result = Int(turnaroundTime / workingHoursLength)
        var shift = (result * numberOfHoursInADay + reminder) * numberOfSecondsInAnHour
        if result < 1 { // turnaround time is less than a full working day
            let nonWorkingHoursLength = numberOfHoursInADay - (workEnd - workStart)
            let submitDateAsTimeStamp = submitDate.timeStamp
            let eobAsTimeStamp = submitDate.startOfTheDay.timeStamp + workEnd * numberOfSecondsInAnHour
            let diff = eobAsTimeStamp - submitDateAsTimeStamp
            if diff < shift { // issue will be solved in the next day
                shift = shift + nonWorkingHoursLength * numberOfSecondsInAnHour
            }
        }
        return shift
    }
    
    private func skipWeekend(date : Date) -> Int {
        let calendar = Calendar.init(identifier: Calendar.Identifier.iso8601)
        if calendar.isDateInWeekend(date) {
            return 2 * numberOfSecondsInAnHour * numberOfHoursInADay
        }
        return 0
    }
    
    private func checkSubmitDateValidity(submitDate : Date) -> Bool {
        let calendar = Calendar(identifier: Calendar.Identifier.iso8601)
        let hour = calendar.component(Calendar.Component.hour, from: submitDate)
        if hour < workStart || hour > workEnd {
            return false
        }
        return true
    }
    
    private func checkDaylightSavingTimeChange(dateFrom : Date, dateTo : Date) -> Int {
        var ret : Int = 0
        // autumn change
        if TimeZone.current.isDaylightSavingTime(for: dateFrom) &&
            !TimeZone.current.isDaylightSavingTime(for: dateTo) {
            ret = numberOfSecondsInAnHour
        }
        // spring change
        if !TimeZone.current.isDaylightSavingTime(for: dateFrom) &&
            TimeZone.current.isDaylightSavingTime(for: dateTo) {
            ret = -numberOfSecondsInAnHour
        }
        return ret
    }
}

extension Date {
    var timeStamp : Int {
        return Int(self.timeIntervalSince1970)
    }
}

extension Date {
    var startOfTheDay : Date {
        let calendar = Calendar.init(identifier: Calendar.Identifier.iso8601)
        return calendar.startOfDay(for: self)
    }
}

extension Date {
    var localTime : String {
        let timeUTC = self
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd HH:mm"
        formatter.timeZone = TimeZone(identifier: TimeZone.current.identifier)
        return formatter.string(from: timeUTC)
    }
}
