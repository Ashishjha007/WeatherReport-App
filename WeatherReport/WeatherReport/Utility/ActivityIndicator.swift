//
//  ActivityIndicator.swift
//  WeatherReport
//
//  Created by Jha on 22/03/18.
//  Copyright © 2018 Jha. All rights reserved.
//

import Foundation
import UIKit

struct ActivityIndicator {
    
    let viewForActivityIndicator = UIView()
    let view: UIView
    let activityIndicatorView = UIActivityIndicatorView()
    let loadingTextLabel = UILabel()
    let grayView = UIView()
    
    func showActivityIndicator(_ cityName : String) {
        viewForActivityIndicator.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        viewForActivityIndicator.backgroundColor = UIColor.clear
        let window = UIApplication.shared.keyWindow!
        window.addSubview(viewForActivityIndicator)
        
        grayView.frame = CGRect(x: 0.0, y: 0.0, width: 150, height: 150)
        grayView.backgroundColor = UIColor(red: 0/255, green: 145/255, blue: 147/255, alpha: 0.8)
        grayView.center = viewForActivityIndicator.center
        grayView.layer.cornerRadius = 8
        grayView.clipsToBounds = true
        activityIndicatorView.center = CGPoint(x: grayView.frame.size.width / 2.0, y: (grayView.frame.size.height) / 2.0)
        loadingTextLabel.frame = CGRect(x: 0, y: activityIndicatorView.frame.size.height + 5, width: grayView.frame.size.width , height: 40)
        loadingTextLabel.textColor = UIColor.white
        loadingTextLabel.text = "Fetching \(cityName) latest weather report"
        loadingTextLabel.font = UIFont(name: "Helvetica-Bold", size: 12)
        loadingTextLabel.numberOfLines = 0
        loadingTextLabel.textAlignment = .center
        loadingTextLabel.lineBreakMode = .byWordWrapping
        loadingTextLabel.center = CGPoint(x: activityIndicatorView.center.x, y: activityIndicatorView.center.y + 50)
        grayView.addSubview(activityIndicatorView)
        grayView.addSubview(loadingTextLabel)
        
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.activityIndicatorViewStyle = .whiteLarge
        viewForActivityIndicator.addSubview(grayView)
        activityIndicatorView.startAnimating()
    }
    
    func stopActivityIndicator() {
        viewForActivityIndicator.removeFromSuperview()
        activityIndicatorView.stopAnimating()
        activityIndicatorView.removeFromSuperview()
        grayView.removeFromSuperview()
    }
}
