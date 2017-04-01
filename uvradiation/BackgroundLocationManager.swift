//
//  BackgroundLocationManager.swift
//  uvradiation
//
//  Created by Kevin Fang on 4/1/17.
//  Copyright © 2017 Emily. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit
import Firebase

class BackgroundLocationManager :NSObject, CLLocationManagerDelegate {
    
    static let instance = BackgroundLocationManager()
    static let BACKGROUND_TIMER = 150.0 // restart location manager every 150 seconds
    static let UPDATE_SERVER_INTERVAL = 60 * 60 // 1 hour - once every 1 hour send location to server
    
    
    let locationManager = CLLocationManager()
    var timer:Timer?
    var currentBgTaskId : UIBackgroundTaskIdentifier?
    var lastLocationDate : NSDate = NSDate()
    var ref:FIRDatabaseReference!
    
    private override init(){
        super.init()
        self.ref = FIRDatabase.database().reference()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.activityType = .other;
        locationManager.distanceFilter = kCLDistanceFilterNone;
        if #available(iOS 9, *){
            locationManager.allowsBackgroundLocationUpdates = true
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationEnterBackground), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
    }
    
    func applicationEnterBackground(){
//        FileLogger.log("applicationEnterBackground")
        start()
    }
    
    func start(){
        if(CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
//            if #available(iOS 9, *){
//                locationManager.requestLocation()
//            } else {
                locationManager.startUpdatingLocation()
//            }
        } else {
            locationManager.requestAlwaysAuthorization()
        }
    }
    func restart (){
        timer?.invalidate()
        timer = nil
        start()
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case CLAuthorizationStatus.restricted:
            print("Restricted Access to location")
        case CLAuthorizationStatus.denied:
            print("User denied access to location")
        case CLAuthorizationStatus.notDetermined:
            print("Status not determined")
        default:
            //log("startUpdatintLocation")
            if #available(iOS 9, *){
                locationManager.requestLocation()
            } else {
                locationManager.startUpdatingLocation()
            }
        }
    }
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if(timer==nil){
            // The locations array is sorted in chronologically ascending order, so the
            // last element is the most recent
            guard let location = locations.last else {return}
            beginNewBackgroundTask()
            locationManager.stopUpdatingLocation()
            let now = NSDate()
            if(isItTime(now: now)){
                //TODO: Every n minutes do whatever you want with the new location. Like for example sendLocationToServer(location, now:now)
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
//        CrashReporter.recordError(error)
        print (error)
        beginNewBackgroundTask()
        locationManager.stopUpdatingLocation()
    }
    
    func isItTime(now:NSDate) -> Bool {
        let timePast = now.timeIntervalSince(lastLocationDate as Date)
        let intervalExceeded = Int(timePast) > BackgroundLocationManager.UPDATE_SERVER_INTERVAL
        return intervalExceeded;
    }
    
    func sendLocationToServer(location:CLLocation, now:NSDate){
        //TODO
    }
    
    func beginNewBackgroundTask(){
        var previousTaskId = currentBgTaskId;
        currentBgTaskId = UIApplication.shared.beginBackgroundTask(expirationHandler: {
            print("task expired")
        })
        if let taskId = previousTaskId{
            UIApplication.shared.endBackgroundTask(taskId)
            previousTaskId = UIBackgroundTaskInvalid
        }
        
        timer = Timer.scheduledTimer(timeInterval: BackgroundLocationManager.BACKGROUND_TIMER, target: self, selector: #selector(self.restart),userInfo: nil, repeats: false)
    }
}
