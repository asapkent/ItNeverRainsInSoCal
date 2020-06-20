//
//  ViewController.swift
//  Weather
//
//  Created by Robert Jeffers on 6/14/20.
//  Copyright © 2020 Robert Jeffers. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation


class ViewController: UIViewController  {
    
    
    @IBOutlet weak var cityNameLabel: UILabel!
    
    
    @IBOutlet weak var tempLabel: UILabel!
    
    @IBOutlet weak var humidityLabel: UILabel!
    
    
    @IBOutlet weak var windSpeedLabel: UILabel!
    
    // location manager object
    var locationManager = CLLocationManager()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // delegate is located in this file.
        locationManager.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        locationManager.requestLocation()
    }

    
    func getWeatherUsingAlamoFire(lat: String, long: String) {
        
        guard let url = URL(string: APIClient.shared.getWeatherDataURL(lat: lat, lon: long)) else {
           print("Could not form url")
            
            return
        }
        
        let headers: HTTPHeaders = ["Accept":"application/json"]
        let parameters: Parameters = [:]
    
        
        
        // closures in networkng responses use [weak self] to help avoid strong rentention cycles.
        AF.request(url, method: HTTPMethod.get, parameters: parameters, encoding: URLEncoding.default, headers: headers).responseJSON { [weak self](response) in
            
            guard let strongSelf = self else {return}
            
            guard let data = response.data else {return}
            
            DispatchQueue.main.async {
                strongSelf.parseJSONWithCodeable(data: data)
            }
            
            
           /* if let jsonData = response.value as? [String:Any] {
                
                // Any time a network call is made that updates the UI needs to take place on the main thread.
                DispatchQueue.main.async {
                strongSelf.parseJSONWithCodeable(data: jsonData)
                }
            }
         }
        } */
    
        /*AF.request(url).responseJSON { (response) in
            if let jsonData = response.value as? [String:Any] {
                print(jsonData)
            }
        }*/
        }
    }
    
    func parseJSONManually(data: [String:Any]) {
        
        
        if let main = data["main"] as? [String:Any] {
            
            if let humidity = main["humidity"] as? Int {
                humidityLabel.text = "\(humidity)"
            }
            if let temp = main["temp"] as? Double {
                tempLabel.text = "\(Int(temp))"
            }
        }
        
        if let wind = data["wind"] as? [String:Any] {
            
            if let speed = wind["speed"] as? Double {
                windSpeedLabel.text = "\(speed)"
            }
        }
        
        if let name = data["name"] as? String {

                cityNameLabel.text = name
            
        }
    }
    
    
    func getWeatherDataWithURLSession(lat: String, lon: String) {
        guard let weatherURL = URL(string: APIClient.shared.getWeatherDataURL(lat: lat, lon: lon)) else {return}
        
        URLSession.shared.dataTask(with: weatherURL) { (data, response, error)in
            
            if let error = error {
                
                // in real app would want a message to infor user there was an error trying to get data.
                print(error.localizedDescription)
                return
            }
            
            guard let data = data else {return}
            
            do {
                guard let metWeatherData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                    
                     print("error converting data into JSON")
                    
                    return
                }
                print(metWeatherData)
                
            } catch {
                print("error converting data into JSON")
            }
            
        } .resume()
    }
    
    func parseJSONWithCodeable(data: Data) {
        
        do {
            
            let weatherObject = try JSONDecoder().decode(WeatherModel.self, from: data)
            
            cityNameLabel.text = weatherObject.name
            
            tempLabel.text = "\(Int(weatherObject.temp))"
            
            humidityLabel.text = "\(weatherObject.humidity)"
            
            windSpeedLabel.text = "\(weatherObject.windSpeed)"
            
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
}


extension ViewController: CLLocationManagerDelegate {
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //getting first location in array
        if let location = locations.first {
            
            let latitude = String(location.coordinate.latitude)
            
            let longitude = String(location.coordinate.longitude)
            
            getWeatherDataWithURLSession(lat: latitude, lon: longitude)
            
            print(latitude)
            
            print(longitude)
            
            //getWeatherUsingAlamoFire(lat: latitude, long: longitude)
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
               
           switch status {
               
           case .notDetermined:
               locationManager.requestWhenInUseAuthorization()
           
           case .authorizedAlways, .authorizedWhenInUse:
               locationManager.requestLocation()
               
           case .denied, .restricted:
               // create aleart
               let alertControler = UIAlertController(title: "Location is diabled.", message: "Weather app needs location.", preferredStyle: .alert)
               
               let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                   alertControler.dismiss(animated: true, completion: nil)
               }
               alertControler.addAction(cancelAction)
               
               let openAction = UIAlertAction(title: "Open", style: .default) { (action) in
                   // opens apple settings
                   if let url = NSURL(string: UIApplication.openSettingsURLString) {
                       UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
                   }
               }
               
               alertControler.addAction(openAction)
               
               present(alertControler, animated: true, completion: nil)
               
               break
               
           @unknown default:
               fatalError()
           }
           
       }
}
    
   
