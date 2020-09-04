//
//  UEditProfileViewController.swift
//  wGonnaDo
//
//  Created by Rutkay Karabulak on 5.05.2020.
//  Copyright © 2020 Rutkay Karabulak. All rights reserved.
//

import UIKit
import Firebase
import Photos
import FirebaseUI
class PEditProfileViewController : UIViewController {
    @IBOutlet weak var fullnameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var dateofbirthTextField: UITextField!
    @IBOutlet weak var userTypeLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var profilePhotoImageView: UIImageView!
    
    // Image picker
    private var imagePickerController = UIImagePickerController()
    
    private let db = Firestore.firestore()
    private let currentUser = Auth.auth().currentUser
    
    private var storage = Storage.storage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserInformation()
        self.imagePickerController.delegate = self
        checkPermissions()
        getProfilePhoto()
        
    }
    
    @IBAction func editProfileButton(_ sender: UIButton) {
        // title control is going to perform
        if (sender.currentTitle == "Edit Profile") {
            fullnameTextField.isEnabled = true
            usernameTextField.isEnabled = true
            phoneNumberTextField.isEnabled = true
            sender.setTitle("Done", for: .normal)
        }
        else if sender.currentTitle == "Done"{
            db.collection(K.CollectionType.users).document((currentUser?.email!)!).setData([
                K.Users.fullName: self.fullnameTextField.text!,
                K.Users.userName: self.usernameTextField.text! ,
                K.Users.phoneNumber: self.phoneNumberTextField.text!
            ], merge: true)
            fullnameTextField.isEnabled = false
            usernameTextField.isEnabled = false
            phoneNumberTextField.isEnabled = false
            sender.setTitle("Edit Profile", for: .normal)
            viewDidLoad()
        }
        // if title perform is equal to edit probile everything gonna be visible other wise it's gonna be done.
    }
    @IBAction func uploadPhotoPressed(_ sender: UIButton) {
        self.imagePickerController.sourceType = .photoLibrary
        self.present(self.imagePickerController,animated: true,completion: nil)
        
    }
    
    
    
}

//MARK: Getting user information from database

extension PEditProfileViewController {
    func getUserInformation() {
        db.collection(K.CollectionType.users).document(currentUser?.email as! String).getDocument { (snapShot, error) in
            if error != nil{
                print(error)
            }else{
                if let snapShot = snapShot {
                    let usersData = snapShot.data()
                    self.fullnameTextField.placeholder = usersData?["fullName"] as? String
                    self.usernameTextField.placeholder = usersData?["userName"] as? String
                    self.dateofbirthTextField.placeholder = usersData?["dateOfBirth"] as? String
                    self.emailTextField.placeholder = self.currentUser?.email
                    self.phoneNumberTextField.placeholder = usersData?["phoneNumber"] as? String
                    if usersData?["gender"] as? Bool == true {
                        self.genderLabel.text = "Male"
                    }
                    else{
                        self.genderLabel.text = "Female"
                    }
                    self.userTypeLabel.text = "Participant"
                }
            }
            
        }
    }
}
//MARK: ImagePickerDelegate, navigation delegate
extension PEditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func checkPermissions() {
        if PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.authorized {
            PHPhotoLibrary.requestAuthorization({ (status: PHAuthorizationStatus) -> Void in
                ()
            })
        }
        
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
        } else {
            PHPhotoLibrary.requestAuthorization(requestAuthroizationHandler)
        }
    }
    
    func requestAuthroizationHandler(status: PHAuthorizationStatus) {
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
            print("We have access to photos")
        } else {
            print("We dont have access to photos")
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let url = info[UIImagePickerController.InfoKey.imageURL] as? URL{
            print(url)
            uploadProfilePhoto(fileURL: url)
        }
        imagePickerController.dismiss(animated: true, completion: nil)
        
    }
    
    private func uploadProfilePhoto(fileURL: URL){
        let storageRef = self.storage.reference()
        
        let photoRef = storageRef.child("profilePictures/\(fileURL)")
        
        let uploadTask = photoRef.putFile(from: fileURL, metadata: nil) { (metadata, error) in
            if error != nil {
                print(error)
                return
            }else {
                if let metadata = metadata{
                    print("Successfully upload.")
                    // url i stringe çevirip kullanıcının dökümanına profil fotoğrafınının yolunu ekliyoruz
                    let photoUrl = fileURL.absoluteString
                    self.db.collection(K.CollectionType.users).document(self.currentUser!.email!).setData([
                        K.Users.photoUrl: photoUrl
                    ], merge: true)
                    self.profilePhotoImageView.sd_setImage(with: photoRef)
                }
            }
        }
    }
    
    private func getProfilePhoto(){
        var photoUrl:String?
        
        self.db.collection(K.CollectionType.users).document(self.currentUser!.email!).getDocument { (snapshot, error) in
            if error != nil {
                print(error)
            }else{
                if let snapshot = snapshot{
                    if let data = snapshot.data() {
                        photoUrl = data[K.Users.photoUrl] as? String
                        let storageRef = self.storage.reference()
                        let photoRef = storageRef.child("profilePictures/\(photoUrl!)")
                        self.profilePhotoImageView.sd_setImage(with: photoRef)
                    }
                    
                }
            }
        }
    }
}

//MARK: UITextFieldDelegate for test

extension PEditProfileViewController:UITextFieldDelegate{
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text == "" || textField.text!.count < 8 || textField.text!.count > 34 || textField.text!.contains("*") || textField.text!.contains("%") || textField.text!.contains("+") || textField.text!.contains("?") || textField.text!.contains("!") || textField.text!.contains(".") || textField.text!.contains(",") {
            textField.text = ""
            textField.placeholder = "Between 8-34 character"
            return false
        }
        return true
    }
}
