//
//  ViewController.swift
//  Ubers
//
//  Created by Muhammad Ashary on 11/10/19.
//  Copyright © 2019 M. Ashary. All rights reserved.
//

import UIKit
import FirebaseAuth

class ViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var riderDriverSwitch: UISwitch!
    @IBOutlet weak var riderLabel: UILabel!
    @IBOutlet weak var driverLabel: UILabel!
    @IBOutlet weak var topButton: UIButton!
    @IBOutlet weak var bottomButton: UIButton!
    
    var signUpMode = true

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func signUpButtonTapped(_ sender: Any) {
        if emailTextField.text == "" || passwordTextField.text == "" {
            displayAlert(title: "Missing information", message: "You must provide both an email and password")
        } else {
            if let email = emailTextField.text,
                let password = passwordTextField.text {
                if signUpMode {
                    // Sign Up
                    Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                        if error != nil {
                            self.displayAlert(title: "Error", message: error!.localizedDescription)
                        } else {
                            if self.riderDriverSwitch.isOn {
                                // Driver
                                let req = Auth.auth().currentUser?.createProfileChangeRequest()
                                req?.displayName = "Driver"
                                req?.commitChanges(completion: nil)
                                self.performSegue(withIdentifier: "driverSegue", sender: nil)
                            } else {
                                // Rider
                                let req = Auth.auth().currentUser?.createProfileChangeRequest()
                                req?.displayName = "Rider"
                                req?.commitChanges(completion: nil)
                                self.performSegue(withIdentifier: "riderSegue", sender: nil)
                            }
                        }
                    }
                } else {
                    // Log In
                    Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                        if error != nil {
                            self.displayAlert(title: "Error", message: error!.localizedDescription)
                        } else {
                            if user?.user.displayName == "Driver" {
                                // Driver
                                self.performSegue(withIdentifier: "driverSegue", sender: nil)
                            } else {
                                // Rider
                                self.performSegue(withIdentifier: "riderSegue", sender: nil)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func displayAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default
            , handler: nil))
        present(alertController, animated: true)
    }
    
    @IBAction func signInButtonTapped(_ sender: Any) {
        if signUpMode {
            topButton.setTitle("Log In", for: .normal)
            bottomButton.setTitle("Swith to Sign Up", for: .normal)
            riderLabel.isHidden = true
            driverLabel.isHidden = true
            riderDriverSwitch.isHidden = true
            signUpMode = false
        } else {
            topButton.setTitle("Sign Up", for: .normal)
            bottomButton.setTitle("Swith to Log In", for: .normal)
            riderLabel.isHidden = false
            driverLabel.isHidden = false
            riderDriverSwitch.isHidden = false
            signUpMode = true
        }
    }
    
}

