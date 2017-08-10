//
//  FirstViewController.swift
//  Outlook-test
//
//  Created by ois  on 07.07.2017.
//  Copyright © 2017 ois . All rights reserved.
//


//This is the controller that logs you into the service, and application.
import UIKit

class MailViewController: UIViewController {

    @IBOutlet var logInButton: UIButton!
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
    
    //If you are allready logged in, you are just sent to the next page, so you donbt have to login again.
    //If you are not logged in, or pressed log out, you are sent to the loginpage, where you have to choose which email you want to use and log in.
    @IBAction func logInButtonTapped(sender: AnyObject) {
        if (service.isLoggedIn) {
            //Logout
            service.logout()
            setLogInState(loggedIn: false)
            
        } else {
            //Login
            service.login(from: self) {
                error in
                if let unwrappedError = error {
                    NSLog("Error logging in: \(unwrappedError)")
                } else {
                    NSLog("Successfully logged in.")
                    self.setLogInState(loggedIn: true)
                    self.loadUserData()
                    //send til nytt view
                    self.performSegue(withIdentifier: "dpSegue", sender: self)
                }
            }
        }
    }
        
    let service = OutlookService.shared()
    func setLogInState(loggedIn: Bool){
        if (loggedIn){
            logInButton.setTitle("", for: UIControlState.normal)
            activityIndicatorView.startAnimating()
        }
        else {
            logInButton.setTitle("Logg inn", for: UIControlState.normal)
         	activityIndicatorView.stopAnimating()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.isHidden = true
        setLogInState(loggedIn: service.isLoggedIn)
        if (service.isLoggedIn){
            loadUserData()
        }
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
                self.performSegue(withIdentifier: "dpSegue", sender: self)
            }
    }
}
}
