//
//  WeatherViewModelTests.swift
//  WeatherReport
//
//  Created by Jha on 20/03/18.
//  Copyright © 2018 Jha. All rights reserved.
//

import XCTest
@testable import WeatherReport

class WeatherViewModelTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGetWeatherDetailByCityName() {
        let viewModal = WeatherViewModel()
        let expect = expectation(description: "Fetching data")
        viewModal.getWeatherDetailByCityName(city: "London") { (status, dictionay, locationDetail) in
            XCTAssertTrue(status, "City found")
            XCTAssertNotNil(dictionay, "Contains weather report")
            XCTAssertEqual(locationDetail!, "London, GB")
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 30) { (error) in
            print("Failed to data fetch data")
        }
    }
    
    func testGetWeatherDetailByWrongCityName() {
        let viewModal = WeatherViewModel()
        let expect = expectation(description: "Fetching data")
        viewModal.getWeatherDetailByCityName(city: "Bangalore") { (status, dictionay, locationDetail) in
            XCTAssertFalse(status, "City not found")
            expect.fulfill()
        }

        waitForExpectations(timeout: 30) { (error) in
            print("Failed to data fetch data")
        }
    }
    
    func testRetreiveWeatherReport() {
        let viewModal = WeatherViewModel()
        var jsonResult = [String: AnyObject]()
        guard let pathString = Bundle(for: type(of: self)).path(forResource: "testWeatherData", ofType: "json") else {
            fatalError("UnitTestData.json not found")
        }
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: pathString), options: .mappedIfSafe)
            jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as! [String : AnyObject]
        } catch let error {
                print("parse error: \(error.localizedDescription)")
        }

        let weatherDetail = viewModal.retreiveWeatherReport(jsonResult)
        let cityAndCountryName = weatherDetail.1
        XCTAssertEqual(cityAndCountryName, "Norwich, GB")

        let dailyForeCastDict = weatherDetail.0
        let weekArray = dailyForeCastDict.keys
        XCTAssertEqual(weekArray.count, 6)
    }

    func testFetchWeatherImage() {
        let viewModal = WeatherViewModel()
        let image = viewModal.fetchWeatherImage("02d")
        XCTAssertNotNil(image)
    }
    
    func testFetchWeatherImageFromCache() {
        let viewModal = WeatherViewModel()
        let image = UIImage()
        viewModal.cache.setObject(image, forKey: "02d" as AnyObject)
        let cachedImage = viewModal.fetchWeatherImageFromCache("02d")
        XCTAssertNotNil(cachedImage)
    }

    func testGetTimeFromDateString() {
        let dateTimeString = "2018-03-23 03:00:00"
        let timeString = dateTimeString.getTimeFromDateString()
        XCTAssertEqual(timeString, "03:00") 
    }
    
}
