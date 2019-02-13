//
//  ViewController.swift
//  CalculateDueDate
//
//  Created by Attila Molnár on 2019. 02. 02..
//  Copyright © 2019. Attila Molnár. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let submitDateFormatter = DateFormatter()
        submitDateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let submitDateString = "2018-12-29 14:45"
        guard let submitDate = submitDateFormatter.date(from: submitDateString) else { return }
        let turnaroundTime = 54
                
        if let dueDate = DueDate.calculateDueDate(submitDate: submitDate, turnaroundTime: turnaroundTime) {
            print("turnaroundTime             : \(turnaroundTime)")
            print("Issue submit date and time : \(submitDate.localTime)")
            print("DueDate and time           : \(dueDate.localTime)")
        }
    }

}
