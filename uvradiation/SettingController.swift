//
//  SettingController.swift
//  uvradiation
//
//  Created by Emily on 4/1/17.
//  Copyright © 2017 Emily. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth

class SettingController: UIViewController {
    
    let userID = FIRAuth.auth()!.currentUser!.uid
    var ref:FIRDatabaseReference!
    
    @IBAction func logout(_ sender: Any) {
        do {
            try FIRAuth.auth()?.signOut()
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "login")
            self.present(vc!, animated: true, completion: nil)
        } catch let error {
            assertionFailure("Error signing out: \(error)")
        }
    }
    
    @IBAction func adjustWeight(_ sender: Any) {

    }
    
    func presentAlert() {
        let alertController = UIAlertController(title: "Weight Change", message: "Please input your new weight below:", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
            if let field = alertController.textFields?[0] {
                self.ref.child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("weight").setValue(field.text)
            } else {
                print("user dind't fill out field")
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Email"
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
