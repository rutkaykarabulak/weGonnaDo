//
//  RegisterController.swift
//  wGonnaDo
//
//  Created by Rutkay Karabulak on 5.05.2020.
//  Copyright © 2020 Rutkay Karabulak. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
class RegisterViewController : UIViewController{
    
    @IBOutlet weak var fullnameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var maleSwitch: UISwitch!
    @IBOutlet weak var femaleSwitch: UISwitch!
    @IBOutlet weak var dateOfBirthTextField: UITextField!
    @IBOutlet weak var participantSwitch: UISwitch!
    @IBOutlet weak var eventerSwitch: UISwitch!
    
    let datePicker = UIDatePicker()
    private var user : User? {
        return Auth.auth().currentUser
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        fullnameTextField.delegate = self
        usernameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        createDatePicker()
    }
    
    var userType: Bool?
    var gender: Bool?
    @IBAction func maleSwitchPressed(_ sender: UISwitch) {
        femaleSwitch.isOn = maleSwitch.isOn == true ? false : true
        gender = maleSwitch.isOn
    }
    @IBAction func femaleSwitchPressed(_ sender: UISwitch) {
        maleSwitch.isOn = femaleSwitch.isOn == true ? false : true
        gender = femaleSwitch.isOn
    }
    
    @IBAction func participantPressed(_ sender: UISwitch) {
        eventerSwitch.isOn = participantSwitch.isOn == true ? false : true
        userType = participantSwitch.isOn
    }
    @IBAction func eventerPressed(_ sender: UISwitch) {
        participantSwitch.isOn = eventerSwitch.isOn == true ? false : true
        userType = participantSwitch.isOn
    }
    
    @IBAction func registerButtonPressed(_ sender: Any) {
        // User must select type of user
        if eventerSwitch.isOn == false && participantSwitch.isOn == false && maleSwitch.isOn == false && femaleSwitch.isOn == false{
            let alert = UIAlertController(title: "Registration problem", message: "Gender or user type part can not leave blank", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Ok", style: .default) { (action) in
                alert.dismiss(animated: true, completion: nil)
            }
            alert.addAction(ok)
            self.present(alert,animated: true,completion: nil)
            return
        }
        if let fullName = fullnameTextField.text, let username = usernameTextField.text, let password = passwordTextField.text, let email = emailTextField.text, let dateOfBirth = dateOfBirthTextField.text {
            Auth.auth().createUser(withEmail: email, password: password) { (resultID, error) in
                if error != nil{
                    print(error)
                }
                else {
                    let db = Firestore.firestore()
                    db.collection(K.CollectionType.users).document(email).setData([
                        K.Users.fullName: fullName ,
                        K.Users.userName: username ,
                        K.Users.password: password ,
                        K.Users.email: email ,
                        K.Users.gender: self.gender! ,
                        K.Users.dateOfBirth: dateOfBirth,
                        K.Users.userType: self.userType!,
                        K.Users.phoneNumber: "",
                        K.Users.photoUrl: ""
                    ])
                    }
                self.sendVericationMail()
                let alert = UIAlertController(title: "Verification", message: "Please check your email for complete your registration", preferredStyle: .alert)
                let ok = UIAlertAction(title: "Ok", style: .default) { (action) in
                    alert.dismiss(animated: true, completion: nil)
                    self.performSegue(withIdentifier: K.Segues.registerToLogin, sender: self)
                }
                alert.addAction(ok)
                self.present(alert,animated: true,completion: nil)
//                if self.userType == true{
//                    self.performSegue(withIdentifier: "registerToParticipant", sender: self)
//                }
//                else{
//                    self.performSegue(withIdentifier: "registerToEventer", sender: self)
//                }
            }
            
            
        }
    }
    
    
}

//MARK: Date picker creation and manipulating
extension RegisterViewController {
    func createDatePicker(){
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed) )
        toolbar.setItems([doneButton], animated: true)
        
        dateOfBirthTextField.inputAccessoryView = toolbar
        self.datePicker.maximumDate = Date()
        dateOfBirthTextField.inputView = datePicker
        
        datePicker.datePickerMode = .date
    }
    
    @objc func donePressed() {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none

        dateOfBirthTextField.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
}
//MARK: sending email
extension RegisterViewController {
    public func sendVericationMail() {
        if self.user != nil && !self.user!.isEmailVerified {
            self.user!.sendEmailVerification { (error) in
                if error != nil {
                    print(error)
                }else{
                    print("Validation mail has send.")
                }
            }
        }
    }
}

//MARK: UITextFieldDelegate for validation

extension RegisterViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text == "" || textField.text!.count < 8 || textField.text!.count > 34 || textField.text!.contains("*") || textField.text!.contains("%") || textField.text!.contains("+") || textField.text!.contains("?") || textField.text!.contains("!") {
            textField.text = ""
            textField.placeholder = "Between 8-34 character"
            return false
        }
        return true
    }
}
