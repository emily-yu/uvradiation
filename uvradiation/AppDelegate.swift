//
//  AppDelegate.swift
//  uvradiation
//
//  Created by Emily on 3/31/17.
//  Copyright © 2017 Emily. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
var timer2: Timer!
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FIRApp.configure()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        self.locationManager.stopUpdatingLocation()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = 45
        self.locationManager.distanceFilter = 9999
        self.locationManager.startUpdatingLocation()
        
        
//        print ("got here ")
//        DispatchQueue.main.async {
//            self.timer2 = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
//                print(timer)
//                print("HAI")
//            }
//        }
        //        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(hallo), userInfo: nil, repeats: true)
        //

        
    }
    
    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
        manager.requestAlwaysAuthorization()
        return manager
    }()
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        }

    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let mostRecentLocation = locations.last else {
            return
        }
        print ("asdfasdf");
        
        let userId = (FIRAuth.auth()?.currentUser?.uid)!
        let ref = FIRDatabase.database().reference()
        ref.child("users").child(userId).child("latitude").setValue(mostRecentLocation.coordinate.latitude)
        ref.child("users").child(userId).child("longitude").setValue(mostRecentLocation.coordinate.longitude)
        
        print ("got into hereee")
        print(mostRecentLocation.speed)
        
        let mph = mostRecentLocation.speed*2.23694
        if(mph > 3 && mph < 30){
            ref.child("users").child(userId).child("speed").child("state").setValue("outside")
        }
        else{
            ref.child("users").child(userId).child("speed").child("state").setValue("inside")
        }
        
        let signal = getSignalStrength()
        ref.child("users").child(userId).child("signal").observeSingleEvent(of: .value, with: { snapshot in
            
            //            let value = snapshot.value as? String;
            
            if !snapshot.exists() {
                ref.child("users").child(userId).child("signal").child("now").setValue("\(signal)")
            }
            else {
                if let dict = snapshot.value as? [String:AnyObject]{
                    if let value = dict["last"] as? Int{
                        ref.child("users").child(userId).child("signal").child("last").setValue("\(value)")
                        ref.child("users").child(userId).child("signal").child("now").setValue("\(signal)")
                        if let state = dict["state"] as? String{
                            if (((signal + 2) < value) || (signal - 2) > value){
                                if(state == "inside"){
                                    ref.child("users").child(userId).child("signal").child("state").setValue("outside")
                                }
                                else{
                                    ref.child("users").child(userId).child("signal").child("state").setValue("inside")
                                }
                            }
                        }
                    }
                }
            }
        })
        
        let url = URL(string: "http://28f3ca05.ngrok.io/update?user=\(userId)")
        
        let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
            //            print(NSString(data: data!, encoding: NSUTF8StringEncoding))
        }
        
        task.resume()
        
        
        self.locationManager.allowDeferredLocationUpdates(untilTraveled: CLLocationDistanceMax, timeout: 10)
    }
    
    func getSignalStrength() -> Int {
        
        let application = UIApplication.shared
        let statusBarView = application.value(forKey: "statusBar") as! UIView
        let foregroundView = statusBarView.value(forKey: "foregroundView") as! UIView
        let foregroundViewSubviews = foregroundView.subviews
        
        var dataNetworkItemView:UIView!
        
        for subview in foregroundViewSubviews {
            if subview.isKind(of: NSClassFromString("UIStatusBarSignalStrengthItemView")!) {
                dataNetworkItemView = subview
                break
            } else {
                return 0 //NO SERVICE
            }
        }
        
        return dataNetworkItemView.value(forKey: "signalStrengthBars") as! Int
        
    }


    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}
