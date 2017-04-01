//
//  SignUpController.swift
//  uvradiation
//
//  Created by Emily on 4/1/17.
//  Copyright © 2017 Emily. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class SignUpController: UIViewController {
        var ref:FIRDatabaseReference!
    @IBOutlet var email: UITextField!
    @IBOutlet var password: UITextField!
    @IBAction func fadeButton(_ sender: Any) {
        var storyboard = UIStoryboard(name: "Main", bundle: nil)
        var ivc = storyboard.instantiateViewController(withIdentifier: "login")
        ivc.modalPresentationStyle = .custom
        ivc.modalTransitionStyle = .crossDissolve
        self.present(ivc, animated: true, completion: { _ in })
    }
    
    @IBAction func createAccount(_ sender: Any) {
                self.ref = FIRDatabase.database().reference()
        if email.text! == "" || password.text! == "" {
            let alertController = UIAlertController(title: "Error", message: "Please enter your email and password", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            present(alertController, animated: true, completion: nil)
            
        } else {
            FIRAuth.auth()?.createUser(withEmail: email.text!, password: password.text!) { (user, error) in
                
                if error == nil {
                    // set user details
                    self.ref.child("users").child((user?.uid)!).setValue([
                        "skintone": 0.0,
                        "weight": 0.0,  //in pounds
                        "maxDIntake": 0.0,
                    ])

                    //login w/ new account
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "setup")
                    self.present(vc!, animated: true, completion: nil)
                    print((user?.uid)!)
                    
                }
                else {
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

}
