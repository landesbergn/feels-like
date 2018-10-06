//
//  SettingsViewController.swift
//  Feels Like
//
//  Created by Noah Landesberg on 10/6/18.
//  Copyright © 2018 Noah Landesberg. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBAction func pressPowerdByBtn(_ sender: Any) {
        
        UIApplication.shared.open(URL(string: "https://darksky.net/poweredby/")! as URL
            , options: [:], completionHandler: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
