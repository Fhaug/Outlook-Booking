//
//  Formatter.swift
//  Outlook-test
//
//  Created by ois  on 07.07.2017.
//  Copyright © 2017 ois . All rights reserved.
//

import SwiftyJSON

class Formatter {

    //Convert the time to a more readable format.
    class func dateTimeTimeZoneToString(date: JSON) -> String {
        let graphTimeZone = date["timeZone"].stringValue
        let graphDateString = date["dateTime"].stringValue
        if (graphDateString.isEmpty) {
            return ""
        }
        let toDateFormatter = DateFormatter()
        toDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.sss"
        toDateFormatter.timeZone = TimeZone(identifier: graphTimeZone)
        
        let dateObj = toDateFormatter.date(from: graphDateString)
        if (dateObj == nil) {
            return ""
        }
        //Dateformatter.style.meduim gives the date the way it is setup now :Aug 4, 2017, 8:00 AM
        let toStringFormatter = DateFormatter()
        toStringFormatter.dateStyle = DateFormatter.Style.medium
        toStringFormatter.timeStyle = DateFormatter.Style.short
        toStringFormatter.timeZone = TimeZone.current
        
        return toStringFormatter.string(from: dateObj!)
    }
}
