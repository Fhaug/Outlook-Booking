//
//  OutlookService.swift
//  Outlook-test
//
//  Created by ois  on 07.07.2017.
//  Copyright © 2017 ois . All rights reserved.
//

import Foundation
import p2_OAuth2
import SwiftyJSON


class OutlookService {
  
    //Configure the OAuth2 framework for Azure
    private var userEmail: String
    
    //The setings for verification and security
    //Client id = the app id from azure.
    // If you want it only to be used with companies, swith common with organization in authorize_uri and token_uri.
    private static let oauth2Settings = [
        "client_id" : "fb0c85f0-7e39-4f73-97d1-f316e894a0f0",
        "authorize_uri": "https://login.microsoftonline.com/common/oauth2/v2.0/authorize",
        "token_uri": "https://login.microsoftonline.com/common/oauth2/v2.0/token",
        "scope": "openid profile offline_access User.Read Mail.Read Calendars.ReadWrite",
        "redirect_uris": ["urn:ietf:wg:oauth:2.0:oob"],
        "verbose": true,
        ] as OAuth2JSON
    
   private static var sharedService: OutlookService = {
       let service = OutlookService()
       return service
    }()
    
    private var oauth2: OAuth2CodeGrant
    
    private init(){
        userEmail = ""
        oauth2 = OAuth2CodeGrant(settings: OutlookService.oauth2Settings)
        oauth2.authConfig.authorizeEmbedded = true
        oauth2.authConfig.ui.useSafariView = false
    }

    class func shared() -> OutlookService {
        return sharedService
    }
    
    var isLoggedIn: Bool {
        get {
            return oauth2.hasUnexpiredAccessToken() || oauth2.refreshToken != nil
        }
    }
    
    //Use the oauth2.accesstoken to verify you as a user.
    func login(from: AnyObject, callback: @escaping (String? ) -> Void) -> Void {
        oauth2.authorizeEmbedded(from: from) {
            result, error in
            if let unwrappedError = error {
                callback(unwrappedError.description)
            }
            else {
                if let unwrappedResult = result, let token = unwrappedResult["access_token"] as? String {
                    //Print the access token to debug log
                    NSLog("Access token: \(token)")
                    callback(nil)
                }
            }
        }
    }
    
    func logout() -> Void {
        oauth2.forgetTokens()
    }
    
    //Call the GRAPH-API and login.
    func makeApiCall(api: String, params: [String: String]? = nil, callback: @escaping (JSON?) -> Void) -> Void {
        //Build the request URL
        var urlBuilder = URLComponents(string: "https://graph.microsoft.com")!
        urlBuilder.path = api
        
        
        if let unwrappedParams = params {
            //Add query parameters to URL
            urlBuilder.queryItems = [URLQueryItem]()
            for (paramName, paramValue) in unwrappedParams {
                urlBuilder.queryItems?.append(URLQueryItem(name: paramName, value: paramValue))
            }
        }
        
        let apiUrl = urlBuilder.url!
        NSLog("Making request to \(apiUrl)")
        
        var req = oauth2.request(forURL: apiUrl)
        req.addValue("application/json", forHTTPHeaderField: "Accept")
        if(!userEmail.isEmpty) {
            //Add X-AnchorMailbox header to optimize
            //API routing
            req.addValue(userEmail, forHTTPHeaderField: "X-AnchorMailbox")
            
        }
        let loader = OAuth2DataLoader(oauth2: oauth2)
        
        //Uncomment this line to get verbose request/response info in
        //Xcode output window
        //loader.logger = OAuth2DebugLogger(.trace)
        loader.perform(request: req) {
            response in
            do {
                let dict = try response.responseJSON()
                DispatchQueue.main.async {
                    let result = JSON(dict)
                    callback(result)
                }
            }
            catch let error {
                DispatchQueue.main.async {
                    let result = JSON(error)
                    callback(result)
                }
            }
        }
        
    }
    
    //Get the email for login.
    func getUserEmail(callback: @escaping (String?) -> Void) -> Void {
        // If we don't have the user's email, get it from
        // the API
        if (userEmail.isEmpty) {
            makeApiCall(api: "/v1.0/me") {
                result in
                if let unwrappedResult = result {
                    let email = unwrappedResult["mail"].stringValue
                    self.userEmail = email
                    callback(email)
                } else {
                    callback(nil)
                }
            }
        } else {
            callback(userEmail)
        }
    }
    
    //Collects the users events that have anything to do with the parkingsplace. Only lists the last 50
    func getEvents(callback: @escaping (JSON?) -> Void) -> Void {
        let apiParams = [
            "$filter": "startswith(subject, 'Parkeringsplass')",
            "$select": "subject,start,end",
            "$top": "50"
        ]
        
        makeApiCall(api: "/v1.0/me/events", params: apiParams) {
            result in
            callback(result)
        }
    }
    
    //Delete events (Not fully implemented)
    func deleteEvents(callback: @escaping (JSON?) -> Void) -> Void {
        let apiParams: [String: Any] = [
            "$filter": "startswith(subject, 'Parkeringsplass')",
            "$select": "subject,start,end",
            "$top": "50"
        ]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: apiParams)
        let url = URL(string: "https://graph.microsoft.com/v1.0/me/events")!
        var request = oauth2.request(forURL	: url)
        request.httpMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        _ = URLSession.shared.dataTask(with: request) {
            data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                print(responseJSON)
            }
        }
    }
    
    //Add new events to the calendar
    //Subject = Parkeringspace
    //Start = Time started
    //End = Time Ended
    //Location = The location of the parkingspot(HK, Oslo..)
    //Attendees = The email adress of parkingspot. If email is set as a person, it will be occupied
    //Reminder and minutesbeforeStart = A reminder(popup)
    func addEvents(callback: @escaping (JSON?) -> Void) -> Void{
        let json: [String: Any] = [
            "subject": MainInstance.eventName,
            "start": [
                "dateTime": MainInstance.dateTimePicked,
                "timeZone": "Europe/Berlin"
            ],
            "end": [
                "dateTime": MainInstance.dateTimePickedEnd,
                "timeZone": "Europe/Berlin"
            ],
            "location":[
            "displayName": MainInstance.parkingSpot as Any!,
            "address": nil
            ],
            "attendees":[
                [
            "type":" required",
            "status":[
                "response": "none",
                "time": "0001-01-01T00:00:00Z"
                ],
            "emailAddress":[
                "name": "Parkeringsplass 1",
                "address": "TestP01@statsbygg.no"]
            ]
                ],
            "webLink": "https://mobil.statsbygg.no/owa/#path=/calendar",
            "isReminderOn": true,
            "reminderMinutesBeforeStart": 60
            ]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        let url = URL(string: "https://graph.microsoft.com/v1.0/me/events")!
        var request = oauth2.request(forURL	: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        //postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                print(responseJSON)
            }
        }
        task.resume()
        }
    }

