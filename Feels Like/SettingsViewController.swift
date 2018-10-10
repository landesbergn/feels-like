//
//  SettingsViewController.swift
//  Feels Like
//
//  Created by Noah Landesberg on 10/6/18.
//  Copyright © 2018 Noah Landesberg. All rights reserved.
//

import UIKit

let defaults = UserDefaults.standard

class SettingsViewController: UITableViewController {
    
    // When the 'Powered by DarkSky' button is pressed, open up the URL
    // for DarkSky in default browser, as instructed by API terms
    // of service
    @IBAction func pressPoweredByBtn(_ sender: Any) {
        UIApplication.shared.open(URL(string: "https://darksky.net/poweredby/")! as URL
            , options: [:], completionHandler: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if (defaults.string(forKey: "units") ?? "F" == "F") {
            DispatchQueue.main.async {
                self.selectFarenheit()
            }
        } else {
            DispatchQueue.main.async {
                self.selectCelsius()
            }
        }
        
    }
    
    // some custom crap to try to resize the second cell in the table so that
    // the 'Powered by DarkSky' button is near the bottom of the screen
    // on multiple devices
    let MinHeight: CGFloat = 100.0
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath[0] == 1) {
            // if the cell is the non-settings one
            // calculate a height based on the height of the screen
            // - the 2x50px settings cells, and then .85 is the magic
            // ratio, I guess
            let temp = (tableView.bounds.height - 100.0) * 0.85
            return temp > MinHeight ? temp : MinHeight
        } else {
            // if a settings cell, 50px is a good height
            return 50.0
        }
    }
    
    func selectFarenheit() {
        
        // check and bold Farenheit
        tableView.cellForRow(at: [0, 0])?.accessoryType = .checkmark
        tableView.cellForRow(at: [0, 0])?.textLabel?.font = UIFont(name:"HelveticaNeue-Bold", size: 20.0)
        
        // uncheck and debold Celsius
        tableView.cellForRow(at: [0, 1])?.accessoryType = .none
        tableView.cellForRow(at: [0, 1])?.textLabel?.font = UIFont(name:"HelveticaNeue", size: 20.0)
        
    }
    
    func selectCelsius() {

        // check and bold Celsius
        tableView.cellForRow(at: [0, 1])?.accessoryType = .checkmark
        tableView.cellForRow(at: [0, 1])?.textLabel?.font = UIFont(name:"HelveticaNeue-Bold", size: 20.0)
        
        // uncheck and debold Farenheit
        tableView.cellForRow(at: [0, 0])?.accessoryType = .none
        tableView.cellForRow(at: [0, 0])?.textLabel?.font = UIFont(name:"HelveticaNeue", size: 20.0)

    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // if [0,0] selected, check [0,0] uncheck [0,1]
        // if [0,1] selected, check [0,1] uncheck [0,0]
        
        if (indexPath[0] != 0) {
            // Some other cell selected
            return
        } else {
            if (indexPath[1] == 0) {
                // Farenheit selected
                defaults.set("F", forKey: "units")
                self.selectFarenheit()
            } else if (indexPath[1] == 1){
                // Celsius selected
                defaults.set("C", forKey: "units")
                self.selectCelsius()
            }
        }
        
    }

}
