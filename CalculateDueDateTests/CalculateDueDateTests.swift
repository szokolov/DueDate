//
//  CalculateDueDateTests.swift
//  CalculateDueDateTests
//
//  Created by Attila Molnár on 2019. 02. 02..
//  Copyright © 2019. Attila Molnár. All rights reserved.
//

import XCTest
@testable import CalculateDueDate

class CalculateDueDateTests: XCTestCase {
    
    // TODO: Tests fail if working hours length is not 8 hour. Check how can test more general
    
    var submitDateFormatter : DateFormatter!
    var submitDate : Date!

    override func setUp() {
        super.setUp()
        
        submitDateFormatter = DateFormatter()
        submitDateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        submitDate = submitDateFormatter.date(from: "2019-02-04 12:45")
    }

    override func tearDown() {
        submitDate = nil
        submitDateFormatter = nil
        submitDate = nil
        super.tearDown()
    }
    
    func test_dueDateWith8tt() {
        let tt = 8
        guard let dueDate = DueDate.calculateDueDate(submitDate: submitDate, turnaroundTime: tt)?.localTime else {
            XCTAssert(false, "error in due date calculation")
            return
        }
        let expectedDate = "2019-02-05 12:45"
        XCTAssertEqual(dueDate, expectedDate, "wrong calculation in case 8 hours turnaround time")
    }
    
    func test_dueDateWithARandomTt() {
        let tt = 11
        guard let dueDate = DueDate.calculateDueDate(submitDate: submitDate, turnaroundTime: tt)?.localTime else {
            XCTAssert(false, "error in due date calculation")
            return
        }
        let expectedDate = "2019-02-05 15:45"
        XCTAssertEqual(dueDate, expectedDate, "wrong calculation in case 11 hours turnaround time")
    }
    
    func test_dueDateWith16tt() {
        let tt = 16
        guard let dueDate = DueDate.calculateDueDate(submitDate: submitDate, turnaroundTime: tt)?.localTime else {
            XCTAssert(false, "error in due date calculation")
            return
        }
        let expectedDate = "2019-02-06 12:45"
        XCTAssertEqual(dueDate, expectedDate, "wrong calculation in case 16 hours turnaround time")
    }
    
    func test_overTheWeekend() {
        let tt = 54
        guard let dueDate = DueDate.calculateDueDate(submitDate: submitDate, turnaroundTime: tt)?.localTime else {
            XCTAssert(false, "error in due date calculation")
            return
        }
        let expectedDate = "2019-02-13 10:45"
        XCTAssertEqual(dueDate, expectedDate, "wrong calculation in case due date is in the next week")
    }
    
    func test_overTheYear() {
        let submitDate = submitDateFormatter.date(from: "2018-12-27 14:45")!
        let tt = 54
        guard let dueDate = DueDate.calculateDueDate(submitDate: submitDate, turnaroundTime: tt)?.localTime else {
            XCTAssert(false, "error in due date calculation")
            return
        }
        let expectedDate = "2019-01-07 12:45"
        XCTAssertEqual(dueDate, expectedDate, "wrong calculation in case due date is in the next week")
    }
    
    func test_dueDateIfExpectedResultIsInTheSameDay() {
        let tt = 3
        guard let dueDate = DueDate.calculateDueDate(submitDate: submitDate, turnaroundTime: tt)?.localTime else {
            XCTAssert(false, "error in due date calculation")
            return
        }
        let expectedDate = "2019-02-04 15:45"
        XCTAssertEqual(dueDate, expectedDate, "wrong calculation in case due date should be in the same day")
    }
    
    func test_dueDateWithSaturday() {
        let tt = 40
        guard let dueDate = DueDate.calculateDueDate(submitDate: submitDate, turnaroundTime: tt)?.localTime else {
            XCTAssert(false, "error in due date calculation")
            return
        }
        let expectedDate = "2019-02-11 12:45"
        XCTAssertEqual(dueDate, expectedDate, "wrong calculation in case due date should be in Saturday")
    }
    
    func test_dueDateWithSunday() {
        let tt = 48
        guard let dueDate = DueDate.calculateDueDate(submitDate: submitDate, turnaroundTime: tt)?.localTime else {
            XCTAssert(false, "error in due date calculation")
            return
        }
        let expectedDate = "2019-02-12 12:45"
        XCTAssertEqual(dueDate, expectedDate, "wrong calculation in case due date should be in Sunday")
    }
    
    func test_EdgeCaseAtStartOfTheDayWith8tt() {
        let tt = 8
        let submitDateString = "2019-02-04 09:00"
        guard let submitDate = submitDateFormatter.date(from: submitDateString) else {
            XCTAssert(false, "wrong format string")
            return
        }
        guard let dueDate = DueDate.calculateDueDate(submitDate: submitDate, turnaroundTime: tt)?.localTime else { return }
        let expectedDate = "2019-02-05 09:00"
        XCTAssertEqual(dueDate, expectedDate, "wrong calculation in case 8 hours turnaround time")
    }
    
    func test_EdgeCaseAtEndOfTheDayWith8tt() {
        let tt = 8
        let submitDateString = "2019-02-04 16:00"
        guard let submitDate = submitDateFormatter.date(from: submitDateString) else {
            XCTAssert(false, "wrong format string")
            return
        }
        guard let dueDate = DueDate.calculateDueDate(submitDate: submitDate, turnaroundTime: tt)?.localTime else {
            XCTAssert(false, "error in due date calculation")
            return
        }
        let expectedDate = "2019-02-05 16:00"
        XCTAssertEqual(dueDate, expectedDate, "wrong calculation in case 8 hours turnaround time")
    }
    
    func test_dueDateWithInvalidSubmitDate() {
        let tt = 8
        let submitDateString = "2019-02-04 19:00"
        guard let submitDate = submitDateFormatter.date(from: submitDateString) else {
            XCTAssert(false, "wrong format string")
            return
        }
        let dueDate = DueDate.calculateDueDate(submitDate: submitDate, turnaroundTime: tt)
        XCTAssertNil(dueDate, "submitDate invalid")
    }
    
    func test_StartOfTheDayExtension() {
        let submitDateString = "2019-02-04 14:00"
        guard let date = submitDateFormatter.date(from: submitDateString) else {
            XCTAssert(false, "wrong format string")
            return
        }
        let startOfTheDay = date.startOfTheDay
        let startOfTheDayString = submitDateFormatter.string(from: startOfTheDay)
        let expectedDate = "2019-02-04 00:00"
        XCTAssertEqual(expectedDate, startOfTheDayString, "something wrong with startOfTheDay Date extension")
    }
    
    func test_timeStampExtension() {
        let dateString = "1970-01-01 00:00"
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.init(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        guard let date = dateFormatter.date(from: dateString) else {
            XCTAssert(false, "wrong format string")
            return
        }
        print(date)
        XCTAssertEqual(date.timeStamp, 0, "bk")
    }
    
    func test_SpringDST() {
        let tt = 8
        let submitDateString = "2019-03-29 15:00"
        guard let submitDate = submitDateFormatter.date(from: submitDateString) else {
            XCTAssert(false, "wrong format string")
            return
        }
        guard let dueDate = DueDate.calculateDueDate(submitDate: submitDate, turnaroundTime: tt)?.localTime else {
            XCTAssert(false, "error in due date calculation")
            return
        }
        let expectedDate = "2019-04-01 15:00"
        XCTAssertEqual(dueDate, expectedDate, "wrong calculation in case spring DST state change")
    }
    
    func test_AutumnDST() {
        let tt = 8
        let submitDateString = "2019-10-25 15:00"
        guard let submitDate = submitDateFormatter.date(from: submitDateString) else {
            XCTAssert(false, "wrong format string")
            return
        }
        guard let dueDate = DueDate.calculateDueDate(submitDate: submitDate, turnaroundTime: tt)?.localTime else {
            XCTAssert(false, "error in due date calculation")
            return
        }
        let expectedDate = "2019-10-28 15:00"
        XCTAssertEqual(dueDate, expectedDate, "wrong calculation in case autumn DST state change")
    }
    
}
