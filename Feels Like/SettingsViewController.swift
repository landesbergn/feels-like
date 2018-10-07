//
//  SettingsViewController.swift
//  Feels Like
//
//  Created by Noah Landesberg on 10/6/18.
//  Copyright © 2018 Noah Landesberg. All rights reserved.
//

import UIKit

var units = "F"

class SettingsViewController: UITableViewController {

    @IBAction func pressPowerdByBtn(_ sender: Any) {
        UIApplication.shared.open(URL(string: "https://darksky.net/poweredby/")! as URL
            , options: [:], completionHandler: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        print(units)
        if (units == "F") {
            DispatchQueue.main.async {
                self.selectFarenhiet()
            }
        } else {
            DispatchQueue.main.async {
                self.selectCelcius()
            }
        }
        
    }
    
    func selectFarenhiet() {
        
        // check and bold Farenhiet
        tableView.cellForRow(at: [0, 0])?.accessoryType = .checkmark
        tableView.cellForRow(at: [0, 0])?.textLabel?.font = UIFont(name:"HelveticaNeue-Bold", size: 20.0)
        
        // uncheck and debold Celcius
        tableView.cellForRow(at: [0, 1])?.accessoryType = .none
        tableView.cellForRow(at: [0, 1])?.textLabel?.font = UIFont(name:"HelveticaNeue", size: 20.0)
        
        units = "F"
    }
    
    func selectCelcius() {

        // check and bold Celcius
        tableView.cellForRow(at: [0, 1])?.accessoryType = .checkmark
        tableView.cellForRow(at: [0, 1])?.textLabel?.font = UIFont(name:"HelveticaNeue-Bold", size: 20.0)
        
        // uncheck and debold Farenhiet
        tableView.cellForRow(at: [0, 0])?.accessoryType = .none
        tableView.cellForRow(at: [0, 0])?.textLabel?.font = UIFont(name:"HelveticaNeue", size: 20.0)
        
        units = "C"

    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // if [0,0] selected, check [0,0] uncheck [0,1]
        // if [0,1] selected, check [0,1] uncheck [0,0]
        
        if (indexPath[0] != 0) {
            // Some other cell selected
            return
        } else {
            if (indexPath[1] == 0) {
                // Farenhiet selected
                self.selectFarenhiet()
            } else if (indexPath[1] == 1){
                // Celcius selected
                self.selectCelcius()
            }
        }
        
    }

}
