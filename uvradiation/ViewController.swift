//
//  ViewController.swift
//  uvradiation
//
//  Created by Emily on 3/31/17.
//  Copyright © 2017 Emily. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet var weightValue: UITextField! //weight
    
    // OpenWeatherAPI
    private let openWeatherMapBaseURL = "http://api.openweathermap.org/v3/uvi/"
    private let openWeatherMapAPIKey = "3b4d5042582e6a05ef5feaa2d9ef4d0d" // <YOUR API KEY>
    private var latNumb:Int!
    private var longNumb:Int!
    private var sublatNumb:String = ""
    private var sublongNumb:String = ""
    let session = URLSession(configuration: URLSessionConfiguration.default)
    
    // locationManager - get your latitutde/longitutde
    var locationManager = CLLocationManager()
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        var locValue:CLLocationCoordinate2D = manager.location!.coordinate
        print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
    
    func loadData() {
        // Do any additional setup after loading the view, typically from a nib.
        
        // Get User Initial Location
        self.locationManager.requestAlwaysAuthorization()         // Ask for Authorisation from the User.
        self.locationManager.requestWhenInUseAuthorization()            // For use in foreground
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        var locValue:CLLocationCoordinate2D = locationManager.location!.coordinate
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        sublatNumb = String(Int(locValue.latitude))
        sublongNumb = String(Int(locValue.longitude))
        print(sublatNumb)
        print(sublongNumb)
        //        let url = URL(string: String("\(openWeatherMapBaseURL)?APPID=\(openWeatherMapAPIKey)&lat=\(sublatNumb)&lon=\(sublongNumb)"))
        let url = URL(string: String("\(openWeatherMapBaseURL)\(sublatNumb),\(sublongNumb)/2017-03-01Z.json?appid=3b4d5042582e6a05ef5feaa2d9ef4d0d"))
        print(url)
        
        // Handle api calls
        let task = session.dataTask(with: url!, completionHandler: {
            (data, response, error) in
            
            // if no error
            if error != nil {
                print(error!.localizedDescription)
            }
                // success
            else {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any]{
                        //Implement your logic
                        print(json)
                        
                        let number = json["data"] as? Double
                        print(number) // uv index
                        self.currentUVIndex = Double(number!)
                        
                    }
                }
                catch {
                    print("error in JSONSerialization")
                }
            }
        })
        task.resume()
    }

    
    weak var timer: Timer?
    var currentUVIndex = 0.0
    var initSkinTone = 6 // for pale people
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
print("same")
        var tempindex = self?.currentUVIndex
        self?.loadData()
            if (tempindex != self?.currentUVIndex){
                var change = (self?.currentUVIndex)! - tempindex!
                print(change)
            }
            
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
    }
    
    // if appropriate, make sure to stop your timer in `deinit`
//    
//    deinit {
//        stopTimer()
//    }
//    
//    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        startTimer()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

