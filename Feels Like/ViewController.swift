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
    
    // Used to start getting the users location
    let locationManager = CLLocationManager()
    
    // Load the DarkSkyClient from the ForecastIO package
    let client = DarkSkyClient(apiKey: "74875c19c438ac203cf7176642c451f2")
    
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

    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: {(placemarks, error)->Void in
            
            if (error != nil) {
                print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                return
            }
            
            if (placemarks?.count)! > 0 {
                let pm = placemarks?[0]
                self.displayLocationInfo(pm)
                print (self.displayLocationInfo(pm))
            } else {
                print("Problem with the data received from geocoder")
            }
            
            let location = locations.first
            self.locationManager.stopUpdatingLocation()
            self.updateWeatherForLocation(lat: (location?.coordinate.latitude)!, lon: (location?.coordinate.longitude)!)
            
        })
    }
    
    func updateWeatherForLocation(lat:Double, lon:Double) {
        self.client.getForecast(latitude: lat, longitude: lon) { result in
            switch result {
            case .success(let currentForecast, let requestMetadata):
                //  We got the current forecast!
                if let currentFeelsTemperature: Double = currentForecast.currently?.temperature {
                    print(currentFeelsTemperature)
                    DispatchQueue.main.async {
                        self.feelsLikeTmpLbl.text = String(Int(round(currentFeelsTemperature)))
                    }
                }
                print(requestMetadata)
            case .failure(let error):
                //  Uh-oh. We have an error!
                print(error)
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
            print("Error while updating location " + error.localizedDescription)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}

