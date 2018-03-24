//
//  HourCell.swift
//  WeatherReport
//
//  Created by Jha on 21/03/18.
//  Copyright © 2018 Jha. All rights reserved.
//

import UIKit

class HourCell: UITableViewCell {

    @IBOutlet weak var maxTempLabel: UILabel!
    @IBOutlet weak var minTempLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var weatherIconImageView: UIImageView!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var rainLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var rainTextLabel: UILabel!
    var item: WeatherModel? {
        didSet {
            guard  let item = item else {
                return
            }
            timeLabel?.text = item.time
            let degree : String = "°"
            minTempLabel?.text = String(format: "%.2f",item.minTemp!) + degree
            maxTempLabel?.text = String(format: "%.2f",item.maxTemp!) + degree  
            windLabel?.text = String(describing: item.windSpeed!)
            if let rainfall = item.rainfallInLast3Hours {
                rainLabel?.text = String(describing: rainfall)
                rainTextLabel.text = "RAIN"
            }else{
                rainLabel?.text = " "
                rainTextLabel.text = " "
            }
            humidityLabel?.text = String(describing: item.humidity!)
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
