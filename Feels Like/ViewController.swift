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

    // this allows us to return to the main ViewController via an Exit
    // and unwind command
    @IBAction func unwindwToHome(segue:UIStoryboardSegue) {
        if (defaults.string(forKey: "units") ?? "F" == "F") {
            client.units = .us
        } else {
            client.units = .uk
        }
        locationManager.stopUpdatingLocation()
        locationManager.startUpdatingLocation()
    }
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var cityLbl: UILabel!
    @IBOutlet weak var feelsLikeTmpLbl: UILabel!
    @IBOutlet weak var summaryLbl: UILabel!
    @IBOutlet weak var asOfLbl: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var realTempLbl: UILabel!
    @IBOutlet weak var diffLbl: UILabel!
    @IBOutlet weak var fireIceImage: UIImageView!
    @IBOutlet weak var squigImgView: UIImageView!
    
    @IBAction func retryBtnPress(_ sender: Any) {
        locationManager.stopUpdatingLocation()
        
        UIView.animate(withDuration: 0.25, delay: 0, options: [], animations: {
            self.label.alpha = 0
            self.cityLbl.alpha = 0
            self.summaryLbl.alpha = 0
            self.errorLabel.alpha = 0
            self.diffLbl.alpha = 0
            self.realTempLbl.alpha = 0
            self.fireIceImage.alpha = 0
            self.feelsLikeTmpLbl.alpha = 0
            self.asOfLbl.alpha = 0
        }, completion: { _ in
            UIView.animate(withDuration: 0.4, delay: 0, options: [], animations: {
                self.squigImgView.alpha = 1
            }, completion: { _ in
                UIView.animate(withDuration: 0.4, delay: 0, options: [], animations: {
                    self.squigImgView.alpha = 0
                }, completion: { _ in
                    UIView.animate(withDuration: 0.4, delay: 0, options: [], animations: {
                        self.squigImgView.alpha = 1
                    }, completion: { _ in
                        UIView.animate(withDuration: 0.4, delay: 0, options: [], animations: {
                            self.squigImgView.alpha = 0
                        }, completion: { _ in
                            UIView.animate(withDuration: 0.25, delay: 0, options: [], animations: {
                                self.locationManager.startUpdatingLocation()
                                self.label.alpha = 1
                                self.cityLbl.alpha = 1
                                self.summaryLbl.alpha = 1
                                self.errorLabel.alpha = 1
                                self.diffLbl.alpha = 1
                                self.realTempLbl.alpha = 1
                                self.fireIceImage.alpha = 1
                                self.feelsLikeTmpLbl.alpha = 1
                                self.asOfLbl.alpha = 1
                            }, completion: { _ in
                            })
                        })
                    })
                })
            })
        })
    }

    // Used to start getting the users location
    let locationManager = CLLocationManager()
    
    // Load the DarkSkyClient from the ForecastIO package
    let client = DarkSkyClient(apiKey: NSDictionary(contentsOfFile: Bundle.main.path(forResource: "keys", ofType: "plist")!)!.object(forKey: "darkSkyKey") as! String)
    
    override func viewDidLoad() {
        super.viewDidLoad()
  
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        // Set location manager to update with 100 meters of horizontal movement
        locationManager.distanceFilter = 100
        
        // Set DarkSky defaults as US and English
        if (defaults.string(forKey: "units") ?? "F" == "F") {
            client.units = .us
        } else {
            client.units = .uk
        }
        client.language = .english
        
        label.text = ""
        cityLbl.text = ""
        summaryLbl.text = ""
        errorLabel.text = ""
        diffLbl.text = ""
        realTempLbl.text = "Real temp"
        fireIceImage.isHidden = true
        squigImgView.alpha = 0
        
        // set in the storyboard directly
         feelsLikeTmpLbl.text = "--"
         asOfLbl.text = "last updated: "
        
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
            print("~~~~~ Last Updated: " + date_string + " ~~~~~~")
            
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
            } else {
                self.inCaseOfError(errorClass: "Geocoder", errorString: "Problem with the data received from geocoder")
            }
            
            let location = locations.first

            self.updateWeatherForLocation(lat: (location?.coordinate.latitude)!, lon: (location?.coordinate.longitude)!)
            
        })
    }
    
    func updateWeatherForLocation(lat:Double, lon:Double) {
        self.client.getForecast(latitude: lat, longitude: lon, excludeFields: [.alerts, .daily, .flags, .minutely]) { result in
            switch result {
            case .success(let currentForecast, let requestMetadata):
                self.clearError()
                
                let forecast = currentForecast.currently!
                let DSairTemp = Double(forecast.temperature!)
                let DSwindSpeed = Double(forecast.windSpeed!)
                let DShumidity = Double(forecast.humidity! * 100.0)
                let DSapparentTemp = Double(forecast.apparentTemperature!)
                let DSsummaryInfo = String(forecast.summary!)
                // let DSiconInfo = (forecast.icon).map({ $0.rawValue })
                
                // let windChill = self.calcWindChill(airTemp: DSairTemp, windSpeed: DSwindSpeed)
                let windChill = DSapparentTemp
                // let heatIndex = self.calcHeatIndex(airTemp: DSairTemp, humidity: DShumidity)
                let heatIndex = DSapparentTemp
                
                // from https://www.meteor.iastate.edu/~ckarsten/bufkit/apparent_temperature.html
                var apparentTemp = DSairTemp
                // if temp below 50F, use windchill.
                // if temp above 60F use heat index
                var belowUseWind = 50.0
                var aboveUseHeat = 60.0
                
                if (defaults.string(forKey: "units") ?? "F" == "C") {
                    belowUseWind = self.convertFtoC(F: belowUseWind)
                    aboveUseHeat = self.convertFtoC(F: aboveUseHeat)
                }
                
                if (round(DSairTemp) < belowUseWind) && (round(windChill) < round(DSairTemp)) {
                    apparentTemp = windChill
                    DispatchQueue.main.async {
                        self.diffLbl.text = String("feels " + String(Int(round(DSairTemp) - round(apparentTemp))) + "° colder")
                        self.fireIceImage.image = UIImage(named:"ice")!
                        self.fireIceImage.isHidden = false
                    }
                } else if (round(DSairTemp) > aboveUseHeat) && (round(heatIndex) > round(DSairTemp)) {
                    apparentTemp = heatIndex
                    DispatchQueue.main.async {
                        self.diffLbl.text = String("feels " + String(Int(round(apparentTemp) - round(DSairTemp))) + "° hotter")
                        self.fireIceImage.image = UIImage(named:"fire")!
                        self.fireIceImage.isHidden = false
                    }
                } else {
                    DispatchQueue.main.async {
                        self.fireIceImage.isHidden = true
                        self.diffLbl.text = "🤘 everything is awesome 🤘"
                    }
                }
                
                print("Summary Text: " + DSsummaryInfo)
                print("Apparent Temp: " + String(Int(round(apparentTemp))))
                print("DS Apparent Temp: " + String(Int(round(DSapparentTemp))))
                print("DS Real Temp: " + String(Int(round(DSairTemp))))
                print("DS Humidity: " + String(DShumidity))
                print("DS Wind Speed: " + String(DSwindSpeed))
                
                // Update labels
                DispatchQueue.main.async {
                    self.feelsLikeTmpLbl.text = String(Int(round(apparentTemp)))
                    self.realTempLbl.text = "Real temp " + String(Int(round(DSairTemp))) + "°"
                    self.summaryLbl.text = DSsummaryInfo
                }
                
                // Get api request count
                if let requestCount: Int = requestMetadata.apiRequestsCount {
                    print("Request Count: " + String(requestCount))
                }
                
                print("-----------------------------------")
    
            case .failure(let error):
                //  Uh-oh. We have an error!
                self.inCaseOfError(errorClass: "API Call", errorString: error.localizedDescription)
            }
        }
    }
    
    func displayLocationInfo(_ placemark: CLPlacemark?) {
        if let containsPlacemark = placemark {
            
            // city name
            let locality = (containsPlacemark.locality != nil) ? containsPlacemark.locality : ""
            
            // postal code
            let postalCode = (containsPlacemark.postalCode != nil) ? containsPlacemark.postalCode : ""
            
            // state
            let administrativeArea = (containsPlacemark.administrativeArea != nil) ? containsPlacemark.administrativeArea : ""
            
            // country
            let country = (containsPlacemark.country != nil) ? containsPlacemark.country : ""
            
            // label.text = postalCode
            cityLbl.text = locality!  + ", " + administrativeArea!

        }
        
        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            //  Uh-oh. We have an error!
            self.inCaseOfError(errorClass: "Geocoder", errorString: String("Error while updating location " + error.localizedDescription))
        }
        
    }
    
    func inCaseOfError(errorClass:String, errorString:String) {
        if (errorClass == "Geocoder") {
            DispatchQueue.main.async {
                self.errorLabel.text = "Unable to retrive location"
            }
        } else if (errorClass ==  "API Call") {
            DispatchQueue.main.async {
                self.errorLabel.text = "Unable to get weather information"
            }
        } else {
            DispatchQueue.main.async {
                self.errorLabel.text = "You found a new kind of error. Cool!"
            }
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
    
    func calcWindChill(airTemp:Double, windSpeed:Double) -> Double {
        var tempAirTemp = airTemp
        var tempWindSpeed = windSpeed
        if (defaults.string(forKey: "units") ?? "F" == "C") {
            tempAirTemp = convertCtoF(C: airTemp)
            tempWindSpeed = windSpeed / 1.609
        }
        
        var returnVal = 35.74 + (0.6215 * tempAirTemp) - 35.75 * pow(tempWindSpeed, 0.16) + (0.4275 * tempAirTemp) * pow(tempWindSpeed, 0.16)
        if (defaults.string(forKey: "units") ?? "F" == "C") {
            returnVal = convertFtoC(F: returnVal)
        }
        
        return(returnVal)
    }
    
    // from https://www.wpc.ncep.noaa.gov/html/heatindex_equation.shtml
    func calcHeatIndex(airTemp:Double, humidity:Double) -> Double {
        
        var tempAirTemp = airTemp
        
        if (defaults.string(forKey: "units") ?? "F" == "C") {
            tempAirTemp = convertCtoF(C: airTemp)
        }
        
        let heatIndex = -42.379 + (2.04901523 * tempAirTemp) + (10.14333127 * humidity) - (0.22475541 * tempAirTemp * humidity) - (0.00683783 * tempAirTemp * tempAirTemp) - (0.05481717 * humidity * humidity) + (0.00122874 * tempAirTemp * tempAirTemp * humidity) + (0.00085282 * tempAirTemp * humidity * humidity) - (0.00000199 * tempAirTemp * tempAirTemp * humidity * humidity)
        
        var heatIndexAdj = 0.0
        
        if humidity < 13.0  && (tempAirTemp > 80 && tempAirTemp < 112) {
            let adj1 = (13.0 - humidity) / 4.0
            let adj2 = sqrt(17.0 - abs(tempAirTemp - 95.0)/17.0)
            heatIndexAdj = adj1 * adj2
        }
        
        if humidity > 85.0 && (tempAirTemp > 80 && tempAirTemp < 87) {
            heatIndexAdj = ((humidity - 85.0) / 10.0) * ((87.0 - tempAirTemp) / 5.0)
        }
        
        if (defaults.string(forKey: "units") ?? "F" == "C") {
            return(convertFtoC(F: (heatIndex - heatIndexAdj)))
        } else {
            return(heatIndex - heatIndexAdj)
        }
    }
    
    func convertCtoF(C:Double) -> Double {
        return((C * 9/5) + 32)
    }
    
    func convertFtoC(F:Double) -> Double {
        return((F - 32) * 5/9)
    }
    
}
