//
//  SetupController.swift
//  uvradiation
//
//  Created by Emily on 4/1/17.
//  Copyright © 2017 Emily. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase
import AVFoundation
import MobileCoreServices
import CoreTelephony
import CoreLocation
import Darwin
import APScheduledLocationManager



class SetupController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate, APScheduledLocationManagerDelegate {
    var ref = FIRDatabase.database().reference()
    @IBOutlet var weightValue: UITextField!
    
    var imagepickedtbh:UIImage!

    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
        manager.requestAlwaysAuthorization()
        return manager
    }()
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
//        print("same")
        picker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func pickImage(_ sender: Any) {
        var imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true, completion: nil)
        //        }
        print("hey it's me");

    }
    
    //same gets image picked
    var imagePicker: UIImagePickerController!
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        //get image thing
        print("haeoijfaociweacmwiejcmaowiecmaowiec")
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage //2
//        imageView.image = chosenImage
//        print(chosenImage)
        imagepickedtbh = chosenImage
        //        print(imagepickedtbh)
        
        //base64 thing
        //Use image name from bundle to create NSData
        //Now use image to create into NSData format
        let imageData: Data! = UIImageJPEGRepresentation(imagepickedtbh!, 0.1)
        
        let base64String = (imageData as NSData).base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        
        var postRef = ref.child("base64string")
        ref.updateChildValues(["base64string": base64String])
                postRef.observe(FIRDataEventType.value, with: { (snapshot) in //this gets the value at current pt
                    let postDict = snapshot.value as? [String : AnyObject] ?? [:]
                    if let unwrapped = snapshot.value {
        //                print(unwrapped)
                        self.ref.updateChildValues(["base64string": unwrapped]) //this shit updates the thing
        
                    }
        })
        
        dismiss(animated: true, completion: nil)
    }
    
    
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismiss(animated: true, completion:nil);
    }
    
    @IBAction func finish(_ sender: Any) {
        let userID = FIRAuth.auth()!.currentUser!.uid
        self.ref.child("users").child(userID).setValue([
            "weight": self.weightValue.text!,
            "skintone": 0.0 // do shit?
        ])
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "Home")
        self.present(vc!, animated: true, completion: nil)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print ("AORWEFKJOACWEICMEICMEJCJECIOWEDC")
        locationManager.startUpdatingLocation()
        manager = APScheduledLocationManager(delegate: self)
        manager.startUpdatingLocation(interval: 60, acceptableLocationAccuracy: 100)

//        imagePicker.delegate = self
    }
    
    private var manager: APScheduledLocationManager!
    
    func scheduledLocationManager(_ manager: APScheduledLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        
        let l = locations.first!
        print (l)
    }
    
    func scheduledLocationManager(_ manager: APScheduledLocationManager, didFailWithError error: Error) {
        
    }
    
    func scheduledLocationManager(_ manager: APScheduledLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
    }

}

