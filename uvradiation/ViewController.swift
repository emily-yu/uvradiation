//
//  ViewController.swift
//  uvradiation
//
//  Created by Emily on 3/31/17.
//  Copyright © 2017 Emily. All rights reserved.
//

import UIKit
import CoreLocation
import CoreMotion
import Firebase

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet var totalDIntake: UILabel!
    var pigmentColor: Double!
    var progress: Double!
    @IBOutlet var pigmentColorText: UILabel!
    @IBOutlet var totalIntake: UILabel!
    
    // OpenWeatherAPI
    private let openWeatherMapBaseURL = "http://api.openweathermap.org/v3/uvi/"
    private let ngrok = "http://41e888fa.ngrok.io"
    private let openWeatherMapAPIKey = "3b4d5042582e6a05ef5feaa2d9ef4d0d" // <YOUR API KEY>
    private var latNumb:Int!
    private var longNumb:Int!
    private var sublatNumb:String = ""
    private var sublongNumb:String = ""
    private var ref:FIRDatabaseReference!
    let session = URLSession(configuration: URLSessionConfiguration.default)
    
    let motionManager = CMMotionManager()
    var timer: Timer!
    //fkin around
    func update() {
        if let accelerometerData = motionManager.accelerometerData {
            print(accelerometerData)
        }
        if let gyroData = motionManager.gyroData {
            print(gyroData)
        }
        if let magnetometerData = motionManager.magnetometerData {
            print(magnetometerData)
        }
        if let deviceMotion = motionManager.deviceMotion {
            print(deviceMotion)
        }
    }
    
    // locationManager - get your latitutde/longitutde
    var locationManager = CLLocationManager()
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        var locValue:CLLocationCoordinate2D = manager.location!.coordinate
        print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
    
    func loadData() {
        self.locationManager.requestAlwaysAuthorization()         // Ask for Authorisation from the User.
        self.locationManager.requestWhenInUseAuthorization()            // For use in foreground
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        var locValue:CLLocationCoordinate2D = locationManager.location!.coordinate
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        print ("got here")
        ref.child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("speed").setValue(locationManager.location!.speed)
        
        
        if(locationManager.location!.speed > 3 && locationManager.location!.speed < 30) {
            let url = URL(string: String("http://41e888fa.ngrok.io/update?user=\(FIRAuth.auth()?.currentUser?.uid)&action=start"))
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
                        print(data!)
                    }
                    catch {
                        print("error in JSONSerialization")
                    }
                }
            })
        }
        else{
            print (FIRAuth.auth()?.currentUser?.uid)
            let url = URL(string: String(ngrok + "/update?user=\((FIRAuth.auth()?.currentUser?.uid)!)&action=stop"))
            print(url)
            
            let task = session.dataTask(with: url!, completionHandler: {
                (data, response, error) in
                
                if error != nil {
                    print(error!.localizedDescription)
                    print("got into here")
                }
                    // success
                else {
                    do {
                        print("wtf")
                        print(data!)
                    }
                    catch {
                        print("oph")
                        print("error in JSONSerialization")
                    }
                }
            })
        }
        
        sublatNumb = String(Int(locValue.latitude))
        sublongNumb = String(Int(locValue.longitude))
        
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

    // calculate vitamin d shit: index 1 needs 20 min sunlight
    func calculateVitaminD(skintone: Double, uvIndex: Double, timeElapsed: Double) -> Double {
        var new = skintone*27.0*0.8
        var rate = 1/uvIndex
        var elapsed = rate*timeElapsed
        return elapsed
    }
    
    var timer2: Timer?
    var currentUVIndex = 0.0
//    var initSkinTone = 1.0 // for pale people
    var tempSkinTone = 3.0 // lower is lighter (1 lightest, 6 darkest)
    
    
    var rate = 0.0
    var necessaryTime = 20.0 //min
    
    // degree to which you were fried
    func startTimer() {
        timer2 = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in
//            print("same")
        var count = 0
        var tempindex = self?.currentUVIndex
        self?.loadData()
            if (tempindex != self?.currentUVIndex){
//                var change = (self?.currentUVIndex)! - tempindex!
//                print(change)
                
                // get skin tone
                var addedprogress = self?.calculateVitaminD(skintone: (self?.pigmentColor)!, uvIndex: tempindex!, timeElapsed: Double(count))
                self?.progress = (self?.progress)! + addedprogress!
                addedprogress = 0 // reset added progress
                count = 0 // reset count
            }
            else {
                count ++
                // add one to minute count
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
        self.totalIntake.text = String(progress)
        
        let userID = FIRAuth.auth()!.currentUser!.uid
                self.ref = FIRDatabase.database().reference()
        // set pigment color
        self.ref.child("users").child(userID).child("skintone").observeSingleEvent(of: .value, with: { (snapshot) in
            if let same = snapshot.value! as? Double{ // or whatever shit it is
                self.pigmentColor = same
                print(same)
                self.ref.child("users").child(userID).child("skintone").observeSingleEvent(of: .value, with: { (snapshot) in
                    if let same2 = snapshot.value! as? Double{
                        print(same2)
                        self.pigmentColorText.text = String(same2)
                    }
                })
//                self.pigmentColorText.text = String(self.pigmentColor)
            }
        })
    
        //set daily vitamin d intake
        self.ref.child("users").child(userID).child("maxDIntake").observeSingleEvent(of: .value, with: { (snapshot) in
            if let same = snapshot.value! as? Double{
                maxVitaminDIntake = same
                print(same)
                self.totalDIntake.text = String(maxVitaminDIntake)
            }
        })
        
        self.ref.child("users").child(userID).child("maxIntake").observeSingleEvent(of: .value, with: { (snapshot) in
            if let same = snapshot.value! as? Double{
                maxVitaminDIntake = same
                print(same)
                self.totalIntake.text = String(maxVitaminDIntake)
            }
        })

        
        
        
//        totalDIntake.text = String(maxVitaminD)
        print("HEY ITS ME")
        print(maxVitaminD)
        
        self.ref = FIRDatabase.database().reference()
        // time adjustments
        rate = (tempSkinTone - tempSkinTone)*0.1 // set rate of same
        if (tempSkinTone < tempSkinTone){
            necessaryTime += (tempSkinTone - tempSkinTone)*10.0 // update time for skin color
        }
        
        motionManager.startAccelerometerUpdates()
        motionManager.startGyroUpdates()
        motionManager.startMagnetometerUpdates()
        motionManager.startDeviceMotionUpdates()
        
        timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(ViewController.update), userInfo: nil, repeats: true)
        
        BackgroundLocationManager.instance.start()

        loadData()
        startTimer()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

