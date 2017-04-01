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

var maxVitaminD = 0.0

class SetupController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {
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
            "skintone": 0.0, // do shit
            "maxDIntake": Double(weightValue.text!)!*27*0.8
        ])
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "Home")
        self.present(vc!, animated: true, completion: nil)

        // skin color stuff
        let url = URL(string: String("http://28f3ca05.ngrok.io/login"))
        print(url)
        
        // Handle api calls
        let session = URLSession(configuration: URLSessionConfiguration.default)
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
                    // set that as their pigment color
                    self.ref.child("users").child(userID).setValue([
                        "skintone": String(describing: data!)
                    ]);
                }
                catch {
                    print("error in JSONSerialization")
                }
            }
        })
        task.resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print ("AORWEFKJOACWEICMEICMEJCJECIOWEDC")
        locationManager.startUpdatingLocation()
    }
    
   }

