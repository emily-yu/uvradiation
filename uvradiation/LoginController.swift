//
//  LoginController.swift
//  uvradiation
//
//  Created by Emily on 4/1/17.
//  Copyright © 2017 Emily. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class LoginController: UIViewController {
    @IBOutlet var email: UITextField!
    @IBOutlet var password: UITextField!
    @IBAction func fadeButton(_ sender: Any) {
        var storyboard = UIStoryboard(name: "Main", bundle: nil)
        var ivc = storyboard.instantiateViewController(withIdentifier: "signup")
        ivc.modalPresentationStyle = .custom
        ivc.modalTransitionStyle = .crossDissolve
        self.present(ivc, animated: true, completion: { _ in })
    }
    
    @IBAction func loginButton(_ sender: Any) {
        if self.email.text == "" || self.password.text == "" {
            
            //Alert to tell the user that there was an error because they didn't fill anything in the textfields because they didn't fill anything in
            
            let alertController = UIAlertController(title: "Error", message: "Please enter an email and password.", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
            
        } else {
            
            FIRAuth.auth()?.signIn(withEmail: self.email.text!, password: self.password.text!) { (user, error) in
                
                if error == nil {
                    
                    //Print into the console if successfully logged in
                    print("You have successfully logged in")
                    
                    //Go to the HomeViewController if the login is sucessful
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "Home")
                    self.present(vc!, animated: true, completion: nil)
                    
                } else {
                    
                    //Tells the user that there is an error and then gets firebase to tell them the error
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
