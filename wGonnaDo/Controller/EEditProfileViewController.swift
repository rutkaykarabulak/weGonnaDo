//
//  EEditProfileViewController.swift
//  wGonnaDo
//
//  Created by Rutkay Karabulak on 7.05.2020.
//  Copyright © 2020 Rutkay Karabulak. All rights reserved.
//

import UIKit
import Firebase
import Photos
import FirebaseUI
class EEditProfileViewController: UIViewController {
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var fullnameTextField: UITextField!
    @IBOutlet weak var dateofBirthTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var profilePhotoImageView: UIImageView!
    @IBOutlet weak var ratingLabel: UILabel!
    
    private let db = Firestore.firestore()
    private let currentUser = Auth.auth().currentUser!
    
    // image picker view controller
    private var imagePickerController = UIImagePickerController()
    // firebase storage
    private let storage = Storage.storage()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.imagePickerController.delegate = self
        getUserInformation()
        checkPermissions()
        getProfilePhoto()
        getReviews()
    }
    
    
    
    @IBAction func editProfileButton(_ sender: UIButton) {
        if sender.currentTitle == "Edit Profile" {
            usernameTextField.isEnabled = true
            fullnameTextField.isEnabled = true
            phoneNumberTextField.isEnabled = true
            sender.setTitle("Done", for: .normal)
        }
        else if sender.currentTitle == "Done" {
            db.collection(K.CollectionType.users).document(currentUser.email!).setData([
                K.Users.fullName: fullnameTextField.text!,
                K.Users.userName: usernameTextField.text!,
                K.Users.phoneNumber: phoneNumberTextField.text!
            ], merge: true)
            sender.setTitle("Edit Profile", for: .normal)
            usernameTextField.isEnabled = false
            fullnameTextField.isEnabled = false
            phoneNumberTextField.isEnabled = false
            viewDidLoad()
        }
        
    }
    
    @IBAction func uploadPhotoPressed(_ sender: UIButton) {
        self.imagePickerController.sourceType = .photoLibrary
        self.present(imagePickerController,animated: true,completion: nil)
    }
    
}

//MARK: Edit profile section

extension EEditProfileViewController {
    // User informations fetch from database and filling to textfields.
    func getUserInformation() {
        db.collection("Users").document(currentUser.email!).getDocument { (snapShot, error) in
            if error != nil{
                print(error!)
            }else {
                if let snapShot = snapShot {
                    let data = snapShot.data()
                    self.usernameTextField.placeholder = data!["userName"] as? String
                    self.fullnameTextField.placeholder = data!["fullName"] as? String
                    self.dateofBirthTextField.placeholder = data!["dateOfBirth"] as? String
                    self.emailTextField.placeholder = self.currentUser.email!
                    self.phoneNumberTextField.placeholder = data!["phoneNumber"] as? String
                    if data!["gender"] as? Bool == true {
                        self.genderLabel.text = "Male"
                    }
                    else{
                        self.genderLabel.text = "Female"
                    }
                }else{
                    print("Cant get any information")
                }
            }
            
        }
    }
}


//MARK: ImageViewPicker delegate and navigation controller

extension EEditProfileViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
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
        let storafeRef = self.storage.reference()
        
        let photoRef = storafeRef.child("profilePhotos/\(fileURL)")
        
        let uploadTask = photoRef.putFile(from: fileURL, metadata: nil) { (metadata, error) in
            if error != nil {
                print(error)
            }else{
                if let metadata = metadata{
                    print("Photo successfuly uploaded")
                    // url turning to string
                    let photoUrl = fileURL.absoluteString
                    self.db.collection(K.CollectionType.users).document(self.currentUser.email!).setData([
                        K.Users.photoUrl:photoUrl
                    ], merge: true)
                    self.profilePhotoImageView.sd_setImage(with: photoRef)
                }
            }
        }
    }
    private func getProfilePhoto(){
        var photoUrl:String?
        
        self.db.collection(K.CollectionType.users).document(self.currentUser.email!).getDocument { (snapshot, error) in
            if error != nil {
                print(error)
            }else{
                if let snapshot = snapshot{
                    if let data = snapshot.data() {
                        photoUrl = data[K.Users.photoUrl] as? String
                        let storageRef = self.storage.reference()
                        let photoRef = storageRef.child("profilePhotos/\(photoUrl!)")
                        self.profilePhotoImageView.sd_setImage(with: photoRef)
                    }
                    
                }
            }
        }
    }
}

//MARK: UITextFieldDelegate for testing

extension EEditProfileViewController:UITextFieldDelegate{
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text == "" || textField.text!.count < 8 || textField.text!.count > 34 || textField.text!.contains("*") || textField.text!.contains("%") || textField.text!.contains("+") || textField.text!.contains("?") || textField.text!.contains("!") || textField.text!.contains(".") || textField.text!.contains(",") {
            textField.text = ""
            textField.placeholder = "Between 8-34 character"
            return false
        }
        return true
    }
}

//MARK: Get rating point

extension EEditProfileViewController {
    func getReviews() {
        self.db.collection(K.CollectionType.reviews).whereField(K.Reviews.whoseEvent, isEqualTo: currentUser.email!).addSnapshotListener { (snapshot, error) in
            if error != nil {
                print(error)
            }else {
                var points = [Int]()
                var toplam = 0
                if let snapshotDocument = snapshot?.documents{
                    for doc in snapshotDocument{
                        let data = doc.data()
                        if let ratings = data[K.Reviews.rating] as? Int{
                            points.append(ratings)
                            toplam += ratings
                        }
                    }
                    if toplam != 0{
                        self.ratingLabel.text = String("Rating:\(toplam/points.count)/5")
                    }else{
                        self.ratingLabel.text = "No rating"
                    }
                    
                }
            }
        }
    }
}
