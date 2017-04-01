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


class SetupController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var ref = FIRDatabase.database().reference()
    @IBOutlet var weightValue: UITextField!
    
    var imagepickedtbh:UIImage!

    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        print("same")
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
        print(chosenImage) //image
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
    
    // this shit deado
    @IBAction func firebasetest(_ sender: Any) { //does nothing basically

        
        //opens photo library
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            var imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
        
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

//        imagePicker.delegate = self
    }

}

extension SetupController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let mostRecentLocation = locations.last else {
            return
        }
        
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
        
        
        if UIApplication.shared.applicationState == .active {
            
        } else {
            print("App is backgrounded. New location is %@", mostRecentLocation)
        }
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

    
}

