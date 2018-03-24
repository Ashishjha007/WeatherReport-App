//
//  WeatherReportViewController.swift
//  WeatherReport
//
//  Created by Jha on 20/03/18.
//  Copyright © 2018 Jha. All rights reserved.
//

import UIKit
import CoreLocation

class WeatherReportViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var degreeImageView: UIImageView!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var weatherDetailTableView: UITableView!
    @IBOutlet weak var currentWeatherImage: UIImageView!
    @IBOutlet weak var currentLocation: UILabel!
    @IBOutlet weak var currentTemp: UILabel!
    @IBOutlet weak var refreshBarButton: UIBarButtonItem!
    @IBOutlet weak var searchBarButton: UIBarButtonItem!
    
    let locationManager = CLLocationManager()
    var weatherViewModel: WeatherViewModel!
    var dailyForecasts: OrderedDictionary<String, [WeatherModel]>?
    var weekArray : [String]?
    var currentCity : String?
    var activity : ActivityIndicator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        locationManager.delegate = self as CLLocationManagerDelegate
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.requestLocation()
        self.weatherViewModel = WeatherViewModel()
        self.getLocation()
        weatherDetailTableView?.register(DayCell.nib, forCellReuseIdentifier: DayCell.identifier)
        weatherDetailTableView?.register(HourCell.nib, forCellReuseIdentifier: HourCell.identifier)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupUI () {
        self.degreeImageView.isHidden = true
        self.searchBarButton.isEnabled = false
        self.refreshBarButton.isEnabled = false
        self.navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedStringKey.foregroundColor: UIColor.white,
             NSAttributedStringKey.font: UIFont(name: "Helvetica-Bold", size: 22)!]
    }
    
    // MARK: - CLLocationManagerDelegate and related methods
    func getLocation() {
        guard CLLocationManager.locationServicesEnabled() else {
            showAlert(
                title: "Please turn on location services",
                message: "This app needs location services in order to report the weather " +
                    "for your current location.\n" +
                "Go to Settings → Privacy → Location Services and turn location services on."
            )
            return
        }
        
        let authStatus = CLLocationManager.authorizationStatus()
        guard authStatus == .authorizedWhenInUse else {
            switch authStatus {
            case .denied, .restricted:
                let alert = UIAlertController(
                    title: "Location services for this app are disabled",
                    message: "In order to get your current location, please open Settings for this app, choose \"Location\"  and set \"Allow location access\" to \"While Using the App\".",
                    preferredStyle: .alert
                )
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                let openSettingsAction = UIAlertAction(title: "Open Settings", style: .default) {
                    action in
                    if let url = NSURL(string: UIApplicationOpenSettingsURLString) {
                        UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
                    }
                }
                alert.addAction(cancelAction)
                alert.addAction(openSettingsAction)
                present(alert, animated: true, completion: nil)
                //return
                
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
                
            default:
                print("Couldn't find the current location")
            }
            return
        }
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert )
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil )
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil )
    }
    
    func populateDataOnUI (_ status: Bool, _ weatherDailyForecast: OrderedDictionary<String, [WeatherModel]>?, _ currentLocation: String?) {
        if status {
            self.dailyForecasts = weatherDailyForecast
            self.weekArray = weatherDailyForecast?.keys
            
            let weekDay = self.weekArray![0]
            let weatherArray = self.dailyForecasts![weekDay]
            let weather = weatherArray![0]
            self.currentLocation.text = currentLocation
            self.currentWeatherImage.image = weather.weatherImage!
            self.currentTemp.text = String(format: "%.2f",weather.temp!)
            self.degreeImageView.isHidden = false
            self.searchBarButton.isEnabled = true
            self.refreshBarButton.isEnabled = true
            self.activity?.stopActivityIndicator()
            self.weatherDetailTableView.reloadData()
        }else{
            self.searchBarButton.isEnabled = true
            self.refreshBarButton.isEnabled = true
            self.activity?.stopActivityIndicator()
            self.showAlert(title: "Alert", message: "City not found")
        }
    }
    
    @IBAction func searchWeatherBasedOnLocation(_ sender: Any) {
        let alertController = UIAlertController(title: "Enter city name", message: " ", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
            guard let field = alertController.textFields else { return }
            let location = ((field[0]).text)?.replacingOccurrences(of: " ", with: "_")
            self.activity?.showActivityIndicator(location!)
            self.weatherViewModel.getWeatherDetailByCityName(city: location!, completionHandler: { (status, weatherDailyForecast, locationDetail) in
                if status {
                    self.currentCity = location
                }
                self.populateDataOnUI(status, weatherDailyForecast, locationDetail)
            })
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        alertController.addTextField { (textField) in
            textField.placeholder = "City name"
        }
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func refresh(_ sender: Any) {
        guard let cityName = currentCity else {
            return
        }
        self.activity?.showActivityIndicator(cityName)
        self.weatherViewModel.getWeatherDetailByCityName(city: cityName, completionHandler: { (status, weatherDailyForecast, locationDetail) in
            self.populateDataOnUI(status, weatherDailyForecast, locationDetail)
        })
    }
}

extension WeatherReportViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        manager.stopUpdatingLocation()
        manager.delegate = nil
        // Get user's current location name
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(newLocation) { (placemarksArray, error) in
            guard let array = placemarksArray else {
                self.showAlert(title: "Can't determine your location",
                               message: "The GPS and other location services aren't responding.")
                return
            }
                let placemark = array.first
                guard let cityName = placemark!.locality else {
                    return
                }
            
            let location = cityName.replacingOccurrences(of: " ", with: "_")
            self.activity = ActivityIndicator(view: self.view)
            self.activity?.showActivityIndicator(location)
            self.weatherViewModel.getWeatherDetailByCityName(city: location, completionHandler: { (status, weatherDailyForecast, locationDetail) in
                if status {
                    self.currentCity = location
                }
                self.populateDataOnUI(status, weatherDailyForecast, locationDetail)
            })
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async() {
            self.searchBarButton.isEnabled = true
            self.refreshBarButton.isEnabled = true
            self.showAlert(title: "Can't determine your location",
                                 message: "The GPS and other location services aren't responding.")
        }
        print("locationManager didFailWithError: \(error)")
    }
}

extension WeatherReportViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        guard let rowCount = self.dailyForecasts?.count else {
            return 0
        }
        return rowCount
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let item = self.dailyForecasts![self.weekArray![section]]
        return item!.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : UITableViewCell = UITableViewCell()
        switch indexPath.row {
        case 0 :
            if let cell = tableView.dequeueReusableCell(withIdentifier: DayCell.identifier, for: indexPath) as? DayCell {
                let weekDay = self.weekArray![indexPath.section]
                let weatherArray = self.dailyForecasts![weekDay]
                
                let weatherWithMinTemp = weatherArray?.min { $0.minTemp! < $1.minTemp! }
                let weatherWithMaxTemp = weatherArray?.max { $0.maxTemp! < $1.maxTemp! }
                
                var weather = weatherArray![(indexPath.row)]
                weather.minTemp = weatherWithMinTemp?.minTemp
                weather.maxTemp = weatherWithMaxTemp?.maxTemp
                if indexPath.section == 0 {
                    cell.todayLabel.isHidden = false
                } else{
                    cell.todayLabel.isHidden = true
                }
                cell.item = weather
                return cell
            }
        default:
            if let cell = tableView.dequeueReusableCell(withIdentifier: HourCell.identifier, for: indexPath) as? HourCell {
                let weekDay = self.weekArray![indexPath.section]
                let weatherArray = self.dailyForecasts![weekDay]
                let weather = weatherArray![(indexPath.row-1)]
                cell.item = weather
                return cell
            }
        }
        return cell
    }
}

extension WeatherReportViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 55.0
        default:
            return 44.0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
}









