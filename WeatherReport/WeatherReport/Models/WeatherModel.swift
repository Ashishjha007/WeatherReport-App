//
//  WeatherModel.swift
//  WeatherReport
//
//  Created by Jha on 20/03/18.
//  Copyright © 2018 Jha. All rights reserved.
//

import Foundation
import UIKit

struct WeatherModel {
    
    var dateAndTime: NSDate?
    var time: String?
    var day : String?
    var city: String?
    var country: String?
    var weatherID: Int?
    var mainWeather: String?
    var weatherDescription: String?
    var weatherImage: UIImage?
    var humidity: Double?
    var pressure: Double?
    var cloudCover: Double?
    var windSpeed: Double?
    var windDirection: Double?
    var rainfallInLast3Hours: Double?
    var temp: Double?
    var minTemp: Double?
    var maxTemp: Double?
}

