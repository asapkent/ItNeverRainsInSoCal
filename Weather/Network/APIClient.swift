//
//  APIClient.swift
//  Weather
//
//  Created by Robert Jeffers on 6/15/20.
//  Copyright © 2020 Robert Jeffers. All rights reserved.
//

import Foundation

class APIClient {
    
    //singleton
    static let shared: APIClient = APIClient()
    
    
    // remove apikey before pushing.
    let apiKey = ""
    
     let baseURL: String = "https://api.openweathermap.org/data/2.5/weather?"
    
    func getWeatherDataURL(lat: String, lon: String) -> String {
        
       
        return "\(baseURL)lat=\(lat)&lon=\(lon)&APPID=\(apiKey))"
        
    }
}
