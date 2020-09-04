//
//  ViewController.swift
//  wGonnaDo
//
//  Created by Rutkay Karabulak on 4.05.2020.
//  Copyright © 2020 Rutkay Karabulak. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    private let db = Firestore.firestore()
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    // When app is launched, all events will check by eventDate logic whether are they expired or not.
    var eventDateLogic = EventDateLogic()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eventDateLogic.getWholeEvents()
        emailTextField.delegate = self
        passwordTextField.delegate = self
        emailTextField.placeholder = "Email"
        passwordTextField.placeholder = "Password"
        // Do any additional setup after loading the view.
    }

    @IBAction func loginButtonPressed(_ sender: Any) {
        if let email = emailTextField.text , let password = passwordTextField.text {
            Auth.auth().signIn(withEmail: email, password: password) { (resultID, error) in
                if error != nil {
                    print(error)
                    let alert = UIAlertController(title: "Error", message: "There is no such a user with this email-password pair", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "Ok", style: .default) { (action) in
                        alert.dismiss(animated: true, completion: nil)
                    }
                    alert.addAction(ok)
                    self.present(alert,animated: true, completion: nil)
                } else {
                    if let user = Auth.auth().currentUser{
                        if user.isEmailVerified {
                            self.db.collection("Users").document(user.email!).getDocument { (snapshot, error) in
                                if error != nil {
                                    print(error)
                                }else{
                                    if let data = snapshot?.data() {
                                        let userType = data["userType"] as! Bool
                                        if userType{
                                            self.performSegue(withIdentifier: K.Segues.loginToParticipant, sender: self)
                                        }
                                        else{
                                            self.performSegue(withIdentifier: K.Segues.loginToEventer, sender: self)
                                        }
                                    }
                                    
                                }
                            }
                        }else if user != nil && !user.isEmailVerified {
                        print("Please check your email adress for verication")
                            // alert sistemini yapalım
                            let alert = UIAlertController(title: "Check your email", message: "Please verify your email before login", preferredStyle: .alert)
                            let ok = UIAlertAction(title: "Ok", style: .default) { (action) in
                                alert.dismiss(animated: true, completion: nil)
                            }
                            alert.addAction(ok)
                            self.present(alert,animated: true,completion: nil)
                        }
                        else {
                            print("there is no such an user")
                        }
                    }
                  
                }
            }
        }
    }
    
    // Adjust mapview controller as a main home page of participant
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == K.Segues.loginToParticipant) {
            let tabBarController = segue.destination as? UITabBarController
            tabBarController?.selectedIndex = 1
        }
    }
    
    
    @IBAction func registerButtonPressed(_ sender: Any) {
// perform segue story board üzerinden sağlanıldı.
    }
    
}

//MARK: UITextFieldDelegate's

extension LoginViewController: UITextFieldDelegate{
    // Text field validation
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text == "" || textField.text!.count < 8 || textField.text!.count > 34 || textField.text!.contains("*") || textField.text!.contains("%") || textField.text!.contains("+") || textField.text!.contains("?") || textField.text!.contains("!") {
            textField.text = ""
            textField.placeholder = "Between 8-34 character"
            return false
        }
        else{
            return true
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailTextField.endEditing(true)
        passwordTextField.endEditing(true)
        return true
    }
}
