//
//  ViewController.swift
//  Feels Like
//
//  Created by Noah Landesberg on 9/6/18.
//  Copyright © 2018 Noah Landesberg. All rights reserved.
//

import UIKit
import CoreLocation
import ForecastIO

class ViewController: UIViewController, CLLocationManagerDelegate  {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var cityLbl: UILabel!
    @IBOutlet weak var feelsLikeTmpLbl: UILabel!
    @IBOutlet weak var summaryLbl: UILabel!
    @IBOutlet weak var asOfLbl: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var retryBtn: UIButton!
    @IBOutlet weak var dot1Lbl: UILabel!
    @IBOutlet weak var dot2Lbl: UILabel!
    @IBOutlet weak var dot3Lbl: UILabel!
    
    @IBAction func retryBtnPress(_ sender: Any) {
        locationManager.stopUpdatingLocation()
        
        // animation looks like this
        
        //        1 2 3 - do : hide 1
        //        _ 2 3 - do : hide 2
        //        _ _ 3 - do : hide 3
        //        _ _ _ - do : show 1
        //        1 _ _ - do : show 2
        //        1 2 _ -  do : show 3
        //        1 2 3

        UIView.animate(withDuration: 0.15, delay: 0, options: [], animations: {
            self.dot1Lbl.alpha = 0
        }, completion: { _ in
            UIView.animate(withDuration: 0.15, delay: 0, options: [], animations: {
                self.dot2Lbl.alpha = 0
            }, completion: { _ in
                UIView.animate(withDuration: 0.15, delay: 0, options: [], animations: {
                    self.dot3Lbl.alpha = 0
                }, completion: { _ in
                    UIView.animate(withDuration: 0.15, delay: 0, options: [], animations: {
                        self.dot1Lbl.alpha = 1
                    }, completion: { _ in
                        UIView.animate(withDuration: 0.15, delay: 0, options: [], animations: {
                            self.dot2Lbl.alpha = 1
                        }, completion: { _ in
                            UIView.animate(withDuration: 0.15, delay: 0, options: [], animations: {
                                self.dot3Lbl.alpha = 1
                            }, completion: { _ in
                                
                            })
                        })
                    })
                })
            })
        })
    
        locationManager.startUpdatingLocation()
    }
    
    // Used to start getting the users location
    let locationManager = CLLocationManager()
    
    // Load the DarkSkyClient from the ForecastIO package
    let client = DarkSkyClient(apiKey: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
  
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        // Set location manager to update with 100 meters of horizontal movement
        locationManager.distanceFilter = 100
        
        // Set DarkSky defaults as US and English
        client.units = .us
        client.language = .english
        
        label.text = ""
        cityLbl.text = ""
        summaryLbl.text = ""
        errorLabel.text = ""
        
        // set in the UI directly
        // feelsLikeTmpLbl.text = "--"
        // asOfLbl.text = "last updated: "
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: {(placemarks, error)->Void in
            
            // to do: format date in terms of 'since last update'
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .none
            dateFormatter.timeStyle = .short
            let date = Date()
            
            // some stuff to maybe use later to take the difference in dates
            // let time = date.timeIntervalSinceNow
            // print(time)
                        
            let date_string = (dateFormatter.string(from: date))
            self.asOfLbl.text = "last updated: " + date_string
            print(date_string)
            
            if (error != nil) {
                self.inCaseOfError(errorClass: "Geocoder", errorString: (error?.localizedDescription)!)
                return
            } else {
                self.clearError()
            }
            
            if (placemarks?.count)! > 0 {
                self.clearError()
                let pm = placemarks?[0]
                self.displayLocationInfo(pm)
                print (self.displayLocationInfo(pm))
            } else {
                self.inCaseOfError(errorClass: "Geocoder", errorString: "Problem with the data received from geocoder")
            }
            
            let location = locations.first
            // If I want to force stop location updates, use below:
            // self.locationManager.stopUpdatingLocation()
            self.updateWeatherForLocation(lat: (location?.coordinate.latitude)!, lon: (location?.coordinate.longitude)!)
        })
    }
    
    func updateWeatherForLocation(lat:Double, lon:Double) {
        self.client.getForecast(latitude: lat, longitude: lon, excludeFields: [.alerts, .daily, .flags, .minutely]) { result in
            switch result {
            case .success(let currentForecast, let requestMetadata):
                self.clearError()
                // We got the current forecast!
                // Get the 'Feels Like' temperature from result and update label in UI
                // (this is where the magic happens!)
                if let currentFeelsTemperature: Double = currentForecast.currently?.temperature {
                    print(currentFeelsTemperature)
                    DispatchQueue.main.async {
                        self.feelsLikeTmpLbl.text = String(Int(round(currentFeelsTemperature)))
                    }
                }
                // Get the summary string from result and update label in UI
                if let summaryInfo: String = currentForecast.currently?.summary {
                    print(summaryInfo)
                    DispatchQueue.main.async {
                        self.summaryLbl.text = summaryInfo
                    }
                }
                print(requestMetadata)
            case .failure(let error):
                //  Uh-oh. We have an error!
                self.inCaseOfError(errorClass: "API Call", errorString: error as! String)
            }
        }
    }
    
    func displayLocationInfo(_ placemark: CLPlacemark?) {
        if let containsPlacemark = placemark {
            
            let locality = (containsPlacemark.locality != nil) ? containsPlacemark.locality : ""
            let postalCode = (containsPlacemark.postalCode != nil) ? containsPlacemark.postalCode : ""
            
            //let administrativeArea = (containsPlacemark.administrativeArea != nil) ? containsPlacemark.administrativeArea : ""
            //let country = (containsPlacemark.country != nil) ? containsPlacemark.country : ""

            label.text = postalCode
            cityLbl.text = locality

        }
        
        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            //  Uh-oh. We have an error!
            self.inCaseOfError(errorClass: "Geocoder", errorString: String("Error while updating location " + error.localizedDescription))
        }
        
    }
    
    func inCaseOfError(errorClass:String, errorString:String) {
        // retryBtn.isHidden = false
        if (errorClass == "Geocoder") {
            errorLabel.text = "Unable to retrive location"
        } else if (errorClass ==  "API Call") {
            errorLabel.text = "Unable to get weather information"
        } else {
            errorLabel.text = "You found a new kind of error. Cool!"
        }
        print("[" + errorClass + "] " + errorString)
    }
    
    func clearError() {
        DispatchQueue.main.async {
            self.errorLabel.text = ""
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

