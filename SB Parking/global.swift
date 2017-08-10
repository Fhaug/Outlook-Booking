//
//  global.swift
//  Outlook-test
//
//  Created by ois  on 28.07.2017.
//  Copyright © 2017 ois . All rights reserved.
//


//These are the global variables we created. Each variable has a default value,
//so you can print it out and see where it eventually failes.
import Foundation

class Main{
    
    var eventName: String
    var dateTimeToday: String
    var dateTimeTomorrow: String
    var dateTimePicked: String
    var dateTimePickedEnd: String
    var dateTimeTodayEnd: String
    var dateTimeTomorrowEnd: String
    var parkingSpot: String
    var bookingEventArray: [Event]
    
    
    init(eventName: String, dateTimeToday: String, dateTimeTomorrow: String, dateTimePicked: String, dateTimePickedEnd: String,  dateTimeTodayEnd: String,dateTimeTomorrowEnd: String, parkingSpot : String, bookingEventArray : [Event]){
        self.eventName = eventName
        self.dateTimeToday = dateTimeToday
        self.dateTimeTomorrow = dateTimeTomorrow
        self.dateTimePicked = dateTimePicked
        self.dateTimePickedEnd = dateTimePickedEnd
        self.dateTimeTodayEnd = dateTimeTodayEnd
        self.dateTimeTomorrowEnd = dateTimeTomorrowEnd
        self.parkingSpot = parkingSpot
        self.bookingEventArray = bookingEventArray
    }
}
var MainInstance = Main(eventName: "Hallo",
                        dateTimeToday:"2001-01-01",
                        dateTimeTomorrow:"2002-01-01",
                        dateTimePicked:"2003-01-01",
                        dateTimePickedEnd: "2004-01-01",
                        dateTimeTodayEnd:"2005-01-01",
                        dateTimeTomorrowEnd: "2006-01-01",
                        parkingSpot: "Parkingsplass 0",
                        bookingEventArray: [Event(subject: "Her har det skjedd en feil", start: "Jan 1, 2000, 8:00 AM", end: " Jan 1, 2000, 5:00 PM")])

