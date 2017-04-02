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


class SetupController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate, UITextFieldDelegate {
    var ref = FIRDatabase.database().reference()
    @IBOutlet var weightValue: UITextField!
    
    // Block 1 to fade in
    @IBOutlet var text1: UITextView!
    @IBOutlet var button1: UIButton!
    
    
    @IBAction func confirmButton(_ sender: Any) {
        self.text1.alpha = 0
        self.text1.text = "To get a better idea of your skin's personal needs, please upload a portrait of your face."
        self.text1.fadeIn(completion: {
            (finished: Bool) -> Void in
            self.text1.fadeOut()
        })

    }
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
        imagePicker.allowsEditing = true
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
        let url = URL(string: String("http://41e888fa.ngrok.io/login"))
        print(url)
        
        // Handle api calls
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: url!, completionHandler: {
            (data, response, error) in
                print ("got here ag")
            // if no error
            if error != nil {
                print(error!.localizedDescription)
            }
//            print ("hallo")
                // success
            else {
                print ("success")
                let same:String = String.init(data: data!, encoding: String.Encoding.utf8)!
                print (same) //correc tindex
                self.ref.child("users").child(userID).child("skintone").setValue(same)
                
                do {
                    print("jkasdfjkaslkSDJFIOAJDFKL")
                    print(data!)
                    // set that as their pigment color
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
        self.weightValue.delegate = self
        print ("AORWEFKJOACWEICMEICMEJCJECIOWEDC")
        locationManager.startUpdatingLocation()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
}


extension UIView {
    
    
    func fadeIn(duration: TimeInterval = 1.0, delay: TimeInterval = 0.0, completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.alpha = 1.0
        }, completion: completion)  }
    
    func fadeOut(duration: TimeInterval = 1.0, delay: TimeInterval = 3.0, completion: @escaping (Bool) -> Void = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.alpha = 0.0
        }, completion: completion)
    }
    
}

