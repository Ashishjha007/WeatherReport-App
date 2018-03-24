//
//  DayCell.swift
//  WeatherReport
//
//  Created by Jha on 21/03/18.
//  Copyright © 2018 Jha. All rights reserved.
//

import UIKit

class DayCell: UITableViewCell {

    @IBOutlet weak var dayNameLabel: UILabel!
    @IBOutlet weak var weatherIconImageView: UIImageView!
    @IBOutlet weak var weatherMainLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var todayLabel: UILabel!
    
    var item: WeatherModel? {
        didSet {
            guard  let item = item else {
                return
            }
            dayNameLabel?.text = item.day
            let degree : String = "°"
            let minTemp = String(format: "%.2f",item.minTemp!) + degree  
            let maxTemp = String(format: "%.2f",item.maxTemp!) + degree
            tempLabel?.text = "\(minTemp)/ \(maxTemp)"
            weatherMainLabel?.text = item.mainWeather!
            weatherIconImageView?.image = item.weatherImage
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
}
