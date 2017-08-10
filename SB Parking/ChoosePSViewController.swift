//
//  ParkingViewController.swift
//  Outlook-test
//
//  Created by ois  on 01.08.2017.
//  Copyright © 2017 ois . All rights reserved.
//

import Foundation
import UIKit

class ChoosePSViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet var eventTextField: UITextField!
    let picker = UIPickerView()
    
    //A hardcoded list of parkingspots. When you get confirmation from outlook or a database, populate this list with that data.
    var parking = ["Velg parkeringsplass", "Parkeringsplass 1", "Parkeringsplass 2", "Parkeringsplass 3", "Parkeringsplass 4", "Parkeringsplass 5", "Parkeringsplass 6", "Parkeringsplass 7", "Parkeringsplass 8"]
    
    @IBOutlet var popUpView: UIView!
    
    @IBAction func histBtn(_ sender: UIButton) {
        //Change storyboard
        self.performSegue(withIdentifier: "MBSegue", sender: self)
    }
    let service = OutlookService.shared()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        if (service.isLoggedIn){
            loadUserData()
        }
        //popup-window
        popUpView.layer.cornerRadius = 5
        popUpView.layer.borderWidth = 2
        
        picker.delegate = self
        picker.dataSource = self
         
        //binding textfield to picker
        eventTextField.inputView = picker
    }
    
    //Animated the popup-window
    func animateIn() {
        self.view.addSubview(popUpView)
        popUpView.center = self.view.center
        popUpView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        popUpView.alpha = 0
        
        UIView.animate(withDuration: 0.4) {
            self.popUpView.alpha = 1
            self.popUpView.transform = CGAffineTransform.identity
        }
    }
    
    //Function that close the popup-window
    func animateOut() {
        UIView.animate(withDuration: 0.3, animations: {
            self.popUpView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.popUpView.alpha = 0
            
        }) { (success:Bool) in
            self.popUpView.removeFromSuperview()
        }
    }
    
    @IBAction func pickBtn(_ sender: UIButton) {
        MainInstance.eventName = eventTextField.text!
        
        //Checks if the user has chosen a parkingspace before moving on
        if MainInstance.eventName.range(of: "Parkeringsplass") != nil {
            
            //Add event
            service.addEvents(){_ in
            }
            
            //Change storyboard
            self.performSegue(withIdentifier: "tildelSegue", sender: self)
        }
            
        else {
            //Open popup-window
            animateIn()
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
    
    func loadUserData() {
        service.getUserEmail() {
            email in
            if let unwrappedEmail = email {
                NSLog("Hello \(unwrappedEmail)")
            }
        }
    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return parking.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return parking[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        eventTextField.text = parking[row]
        self.view.endEditing(false)
    }
}

