//
//  SecondViewController.swift
//  Outlook-test
//
//  Created by ois  on 07.07.2017.
//  Copyright © 2017 ois . All rights reserved.
//

import UIKit
import Foundation
import EventKit
import SwiftyJSON


var publicEventName : String!

class CalendarViewController: UIViewController{

    // Different variables used in the
    @IBOutlet weak var tableView: UITableView!
    var dataSource:EventsDataSource?
    let service = OutlookService.shared()

    @IBOutlet var popUpView2: UIView!
    
    @IBOutlet weak var txtField: UITextView!
    @IBOutlet weak var Eventview: UIView!
    //Booleans to check if you have booked a parkingspot today or tomorrow.
    var todayBool: Bool!
    var tomorrowBool: Bool!
    
    var EndTomorrow = MainInstance.dateTimeTomorrow
    var EndToday = MainInstance.dateTimeToday

    //button to pick tomorrow as the day you want to book
    @IBAction func tomorrowBtn(_ sender: Any) {
        //Check if you allready have a booking for tomorrow. If you do, exit the function and display a warning.
        tomorrowBool = false
        for object in MainInstance.bookingEventArray{
            /*
            //Print out the date and see if it matches todays date.
            print(object, "\n")
            print("!---- DATOEN DEN ITTERERER GJENNOM:", object.start)
            print("!---- DATOEN I DAG:", MainInstance.dateTimeTomorrow)
             */
            if (object.start == MainInstance.dateTimeTomorrow){
                tomorrowBool = true
                animateIn()
            }
        }
        // If you havnt booked a spot, you pick on, and move to the next segue. 
        if (tomorrowBool == false){
            MainInstance.dateTimePicked = MainInstance.dateTimeTomorrow
            MainInstance.dateTimePickedEnd = MainInstance.dateTimeTomorrowEnd

            //Change storyboard
            self.performSegue(withIdentifier: "ppSegue", sender: self)
        } else {
            return
        }
    }
    
    //Button to pick the current date as the date you want to book
    @IBAction func todayBtn(_ sender: Any) {
        
        //Check if you allready have a booking for today. If you do, exit the function and display a warning
        todayBool = false
        for object in MainInstance.bookingEventArray{
            print(object, "\n")
            if (object.start == MainInstance.dateTimeToday){
                todayBool = true
                animateIn()
            }
        }
        if (todayBool == false){
            MainInstance.dateTimePicked = MainInstance.dateTimeToday
            MainInstance.dateTimePickedEnd = MainInstance.dateTimeTodayEnd

            //Change storyboard
            self.performSegue(withIdentifier: "ppSegue", sender: self)
        } else {
            return
        }
    }
    
    //Button to log out of the service
    @IBAction func logOutButtonTapped(sender: AnyObject){
        service.logout()
        //send til nytt view
        self.performSegue(withIdentifier: "loginSegue", sender: self)
        
    }
    
    //Button to add events to the calendar
    @IBAction func AddEvent(sender:UIButton){
        service.addEvents(){_ in
        }
    }
    
    func loadUserData() {
        service.getUserEmail() {
            email in
            if let unwrappedEmail = email {
                NSLog("Hello \(unwrappedEmail)")
                
                self.service.getEvents() {
                    events in
                    if let unwrappedEvents = events {
                        self.dataSource = EventsDataSource(events: unwrappedEvents["value"].arrayValue)
                        MainInstance.bookingEventArray = (self.dataSource?.events)!
                    }
                }
            }
        }
    }
    
   override func viewDidLoad() {
        super.viewDidLoad()
    
        if (service.isLoggedIn) {
            loadUserData()
        }
        //Datetime
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.sss"
        dateFormatter.dateStyle = .medium
        dateFormatter.timeZone = TimeZone.current
    
        //Datetime Today
        MainInstance.dateTimeToday = dateFormatter.string(from: date)
        EndToday = MainInstance.dateTimeToday
        MainInstance.dateTimeToday = MainInstance.dateTimeToday + ", 8:00 AM"
        //Datetime tomorrow
        MainInstance.dateTimeTomorrow = dateFormatter.string(from: date.addingTimeInterval(24*60*60))
        EndTomorrow = MainInstance.dateTimeTomorrow
        MainInstance.dateTimeTomorrow = MainInstance.dateTimeTomorrow + ", 8:00 AM"
        //Datetime end
        MainInstance.dateTimeTomorrowEnd = EndTomorrow + ", 5:00 PM"
        MainInstance.dateTimeTodayEnd = EndToday + ", 5:00 PM"
        // Print out todays and tomorrows date, which are set in the global variables.
    print(">----------Current date today is: " , MainInstance.dateTimeToday)
    print(">----------Current date tomorrow is: " , MainInstance.dateTimeTomorrow)
    
        //popup-window
        popUpView2.layer.cornerRadius = 5
        popUpView2.layer.borderWidth = 2
    
    }
    
    //Animated the popup-window
    func animateIn() {
        self.view.addSubview(popUpView2)
        popUpView2.center = self.view.center
        popUpView2.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        popUpView2.alpha = 0
        
        UIView.animate(withDuration: 0.4) {
            self.popUpView2.alpha = 1
            self.popUpView2.transform = CGAffineTransform.identity
        }
    }
    
    func animateOut() {
        UIView.animate(withDuration: 0.3, animations: {
            self.popUpView2.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.popUpView2.alpha = 0
            
        }) { (success:Bool) in
            self.popUpView2.removeFromSuperview()
        }
    }
    
    //Close popup-window
    @IBAction func okBtn(_ sender: UIButton){
        animateOut()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

