//
//  WeatherModel.swift
//  Weather
//
//  Created by Robert Jeffers on 6/20/20.
//  Copyright © 2020 Robert Jeffers. All rights reserved.
//Codeable is the perfered way to parse JSON in swift. especially when things strat getting big.

import Foundation

class WeatherModel: NSObject, Codable {
    
    var name: String = ""
    
    var temp: Double = 0.0
    
    var humidity: Int = 0
    
    var windSpeed: Double = 0.0
    
    enum CodingKeys: String, CodingKey {
        
        case name
        
        case main
        
        case wind
        
        case humidity
        
        case temp
        
        case speed
        
    }
    
    func encode(to encoder: Encoder) throws {
        <#code#>
    }
    
    override init() {
        
    }
    
   convenience required init(from decoder: Decoder) throws {
  
    self.init()
    
    //Creating container
    let continer = try decoder.container(keyedBy: CodingKeys.self)
    
    // for the container in the API call main []
    let main = try continer.nestedContainer(keyedBy: CodingKeys.self, forKey: .main)
    
    // for the container in the API call wind []
    let wind = try continer.nestedContainer(keyedBy: CodingKeys.self, forKey: .wind)
    
    name = try continer.decode(String.self, forKey: .name)
    
    temp = try continer.decode(Double.self, forKey: .temp)
    
    humidity = try main.decode(Int.self, forKey: .humidity)
    
    windSpeed = try wind.decode(Double.self, forKey: .speed)
    
    
    
    
    }
    
}
