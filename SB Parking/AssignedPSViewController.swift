//
//  BookedParkViewController.swift
//  Outlook-test
//
//  Created by ois  on 02.08.2017.
//  Copyright © 2017 ois . All rights reserved.
//

import Foundation
import UIKit

class AssignedPSViewController: UIViewController{
    
    let service = OutlookService.shared()
    
    //Assigned parkingspace
    @IBOutlet var tildelLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if (service.isLoggedIn){
            loadUserData()
        }
        
        //Adds information on which parkingspace you have booked
        tildelLabel.text = MainInstance.eventName
        timeLabel.text = "Dato: " + MainInstance.dateTimePicked
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadUserData() {
        service.getUserEmail() {
            email in
            if let unwrappedEmail = email {
                NSLog("Hello \(unwrappedEmail)")
            }
        }
    }
}

