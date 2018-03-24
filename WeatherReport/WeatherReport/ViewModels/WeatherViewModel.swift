//
//  WeatherViewModel.swift
//  WeatherReport
//
//  Created by Jha on 20/03/18.
//  Copyright © 2018 Jha. All rights reserved.
//

import Foundation
import UIKit

enum Units: String {
    case Metric = "metric"
    case Imperial = "imperial"
}

class WeatherViewModel {
    
    private let baseURL = "http://api.openweathermap.org/data/2.5/forecast?"
    private let imageBaseURL = "http://openweathermap.org/img/w/"
    private let apiKey = "c5b47e8db40d437271c4d6c3d055f536"
    var cache: NSCache<AnyObject, AnyObject> = NSCache()
    
    // fetch weather detail by city name
    func getWeatherDetailByCityName(city: String, completionHandler : @escaping (_ success: Bool, _ weatherDictionary : OrderedDictionary<String , [WeatherModel]>?, _ city :String?) -> ()) {
        
        let weatherRequestURL = NSURL(string: "\(baseURL)APPID=\(apiKey)&q=\(city)\(",GB")&units=\(Units.Metric)")! as URL
        let session = URLSession.shared
        session.configuration.timeoutIntervalForRequest = 5
        // data task to retrieves the data.
        let dataTask = session.dataTask(with: weatherRequestURL) {
            (data:Data?, response:URLResponse?, error:Error?) in
            if error != nil {
                completionHandler(false, nil, nil)
            }
            else {
                do {
                    if let httpResponse = response as? HTTPURLResponse {
                        if httpResponse.statusCode != 404 {
                            let weatherData = try JSONSerialization.jsonObject(with: data!,
                                                                               options: .mutableContainers) as! [String: AnyObject]
                            let weatherDetail = self.retreiveWeatherReport(weatherData)
                            OperationQueue.main.addOperation {
                                completionHandler(true, weatherDetail.0, weatherDetail.1)
                            }
                            } else{
                                OperationQueue.main.addOperation {
                                    completionHandler(false, nil, nil)
                                }
                            }
                        }
                    }
                    catch {
                        OperationQueue.main.addOperation {
                            completionHandler(false, nil, nil)
                        }
                    }
                }
            }
        dataTask.resume()
    }
    
    func retreiveWeatherReport(_ weatherData : [String: AnyObject]) -> (OrderedDictionary<String , [WeatherModel]>, String) {
        
        let calendar = NSCalendar.current
        var dayDictionary : OrderedDictionary<String , [WeatherModel]> = [:]
        if let list = weatherData["list"] as? [Any] {
            for item in list {
                let dictionary = item as! [String : AnyObject]
                var weather = WeatherModel()
                
                let dateTime = NSDate(timeIntervalSince1970: dictionary["dt"] as! TimeInterval)
                let comps = calendar.dateComponents([.day, .month, .year, .hour, .weekday], from: dateTime as Date)
                let day = DateTime.fromComponents(components: comps as DateComponents)
                weather.day = day.getDayName()
                weather.dateAndTime = dateTime
                
                let time = (dictionary["dt_txt"] as! String).getTimeFromDateString()
                weather.time = time
                
                let weatherArray = dictionary["weather"] as! [Any]
                let weatherDict = weatherArray[0] as! [String: AnyObject]
                weather.weatherID = weatherDict["id"] as? Int
                weather.mainWeather = weatherDict["main"] as? String
                weather.weatherDescription = weatherDict["description"] as? String
                let weatherImageName = weatherDict["icon"] as! String
                weather.weatherImage =  self.fetchWeatherImage(weatherImageName)
                
                let mainDict = dictionary["main"] as! [String: AnyObject]
                weather.temp = mainDict["temp"] as? Double
                weather.minTemp = mainDict["temp_min"] as? Double
                weather.maxTemp = mainDict["temp_max"] as? Double
                weather.humidity = mainDict["humidity"] as? Double
                weather.pressure = mainDict["pressure"] as? Double
                
                weather.cloudCover = dictionary["clouds"]!["all"] as? Double
                
                let windDict = dictionary["wind"] as! [String: AnyObject]
                weather.windSpeed = windDict["speed"] as? Double
                weather.windDirection = windDict["deg"] as? Double
                
                if dictionary["rain"] != nil {
                    let rainDict = dictionary["rain"] as! [String: AnyObject]
                    weather.rainfallInLast3Hours = rainDict["3h"] as? Double
                }
                else {
                    weather.rainfallInLast3Hours = nil
                }
                if dayDictionary[weather.day!] != nil {
                    var array : [WeatherModel] = dayDictionary[weather.day!]!
                    array.append(weather)
                    dayDictionary[weather.day!] = array
                } else {
                    var hourlyForecast = [WeatherModel]()
                    hourlyForecast.append(weather)
                    dayDictionary[weather.day!] = hourlyForecast
                }
            }
        }
        var cityAndCountryName = ""
        if let cityDictionary = weatherData["city"] as? [String : AnyObject]  {
            let city = cityDictionary["name"] as! String
            let country = cityDictionary["country"] as! String
            cityAndCountryName = "\(city), \(country)"
        }
        return (dayDictionary, cityAndCountryName)
    }
    
    // Download weather image if not found in cache
     func fetchWeatherImage(_ imageName : String ) -> UIImage? {
        if (self.cache.object(forKey: imageName as AnyObject) != nil) {
            return self.fetchWeatherImageFromCache(imageName)
        }else{
            let imageUrl = "\(imageBaseURL)\(imageName).png"
            let url = URL(string: imageUrl)
            do {
                let imageData = try Data(contentsOf: url!)
                let image = UIImage(data: imageData)
                self.cache.setObject(image!, forKey: imageName as AnyObject)
                return image!
            } catch {
                return nil
            }
        }
    }
    
    // fetch weather image fro cache if it is already downloaded
    func fetchWeatherImageFromCache (_ imageName : String) -> UIImage {
        let image = (self.cache.object(forKey: imageName as AnyObject) as? UIImage)!
        return image
    }
}

extension String {
    func getTimeFromDateString() -> String {
        let result = self.components(separatedBy: " ")
        let timeString = result[1] as String
        let time = timeString.prefix(5)
        return String(time)
    }
}

