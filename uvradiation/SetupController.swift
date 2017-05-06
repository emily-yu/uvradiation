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
    let userID = FIRAuth.auth()!.currentUser!.uid

    // Block 1 to fade in
    @IBOutlet var text1: UITextView!
    @IBOutlet var button1: UIButton!
    @IBAction func confirmBlock1(_ sender: Any) {
        if weightValue.text != "" {
            self.text1.fadeIn(completion: {
                (finished: Bool) -> Void in
            })
            self.button1.fadeIn(completion: {
                (finished: Bool) -> Void in
            })
            button1.isUserInteractionEnabled = true
            self.view.endEditing(true)
        }
        else {
            let alertController = UIAlertController(title: "Error", message: "Please input a weight.", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBOutlet var confirmImage: UIButton!
    var imagepickedtbh:UIImage!
    
    let date = Date()
    let calendar = Calendar.current
    

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
        
        // make finish button visible + userinteractionenabled
        self.text2.fadeIn(completion: {
            (finished: Bool) -> Void in
        })
        self.button2.fadeIn(completion: {
            (finished: Bool) -> Void in
        })
        button2.isUserInteractionEnabled = true
    }
    
    //same gets image picked
    var imagePicker: UIImagePickerController!
    
    // Elements to Fade Out (2)
    @IBOutlet var text2: UITextView!
    @IBOutlet var button2: UIButton!
    
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
        

        self.ref.child("users").child(userID).child("base64").setValue(base64String)
        
//        var postRef = ref.child("base64string")
//        ref.updateChildValues(["base64string": base64String])
//                postRef.observe(FIRDataEventType.value, with: { (snapshot) in //this gets the value at current pt
//                    let postDict = snapshot.value as? [String : AnyObject] ?? [:]
//                    if let unwrapped = snapshot.value {
//        //                print(unwrapped)
//                        self.ref.updateChildValues(["base64string": unwrapped]) //this shit updates the thing
//        
//                    }
//        })
//        
        dismiss(animated: true, completion: nil)
    }
    
    
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismiss(animated: true, completion:nil);
    }
    
    @IBAction func finish(_ sender: Any) {
        let userID = FIRAuth.auth()!.currentUser!.uid
        
        
        self.ref.child("users").child(userID).child("weight").setValue(self.weightValue.text!)
        self.ref.child("users").child(userID).child("skintone").setValue(0.0)
        self.ref.child("users").child(userID).child("maxDIntake").setValue(Double(weightValue.text!)!*27*0.8)
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "Home")
        self.present(vc!, animated: true, completion: nil)
        // skin color stuff
        let url = URL(string: String("http://0ca85025.ngrok.io/login?userid=\(userID)"))
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
                
            else {
                print ("aweocmeicmweiacmiwecj")
                let same:String = String.init(data: data!, encoding: String.Encoding.utf8)!
                print (same)
                let dict = self.convertToDictionary(text: same)
                print (dict?["response"])
                self.ref.child("users").child(userID).child("skintone").setValue(dict?["response"])
                
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
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.weightValue.delegate = self
        print ("AORWEFKJOACWEICMEICMEJCJECIOWEDC")
        locationManager.startUpdatingLocation()
        
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        let seconds = calendar.component(.second, from: date)
        print("hours = \(hour):\(minutes):\(seconds)")
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

