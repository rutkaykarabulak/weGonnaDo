//
//  EventCreateViewController.swift
//  wGonnaDo
//
//  Created by Rutkay Karabulak on 11.05.2020.
//  Copyright © 2020 Rutkay Karabulak. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation
import FirebaseUI
import Photos
class EEventCreateViewController: UIViewController{
    @IBOutlet weak var eventAdressTextField: UITextField!
    @IBOutlet weak var eventNameTextField: UITextField!
    @IBOutlet weak var eventDescriptionTextField: UITextField!
    @IBOutlet weak var startDatePicker: UITextField!
    @IBOutlet weak var endDatePicker: UITextField!
    @IBOutlet weak var eventPhotoImageView: UIImageView!
    
    var address: String?
    var eventLocation: CLLocationCoordinate2D?
    var realEventLocation: GeoPoint?
    
    private var currentDate = Date()
    private let datePicker = UIDatePicker()
    
    private let db = Firestore.firestore()
    private let currentUser = Auth.auth().currentUser!
    
    private let storage = Storage.storage()
    // Image picker controller
    private var imagePickerController = UIImagePickerController()
    // Photo url will comes from upload photo action
    private var photoUrl: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkPermissions()
        imagePickerController.delegate = self
        if eventLocation != nil {
            realEventLocation = GeoPoint(latitude: eventLocation!.latitude, longitude: eventLocation!.longitude)
        }
        createDatePicker(to: startDatePicker)
        createDatePicker(to: endDatePicker)
        eventAdressTextField.placeholder = address
    }
    // When the create button tapped, event will be add to database and new object will be created.
    @IBAction func createButtonPressed(_ sender: Any) {
        if let name = eventNameTextField.text, let description = eventDescriptionTextField.text, let startDate = startDatePicker.text, let endDate = endDatePicker.text {
            var ref: DocumentReference? = nil
            ref = db.collection(K.CollectionType.events).addDocument(data: [
                K.Events.name: name,
                K.Events.owner: currentUser.email,
                K.Events.address: self.address,
                K.Events.startDate: startDate,
                K.Events.endDate: endDate,
                K.Events.location: realEventLocation,
                K.Events.description: description,
                K.Events.status: true,
                K.Events.point: 0,
                K.Events.creationDate: Date().timeIntervalSince1970,
                K.Events.participants: [],
                K.Events.photoUrl: self.photoUrl
                
            ]) { (error) in
                if let error = error{
                    print(error)
                }else {
                    print("Event has created succesfully")
                }
            }
            print(ref!.documentID)
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func uploadPhotoPressed(_ sender: UIButton) {
        self.imagePickerController.sourceType = .photoLibrary
        self.present(imagePickerController,animated: true,completion: nil)
    }
}



//MARK: datepicker create

extension EEventCreateViewController {
    func createDatePicker(to: UITextField) {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        if(to == startDatePicker){
            let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(startDonePressed))
            toolbar.setItems([doneBtn], animated: true)
        }else{
            let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(endDonePressed))
            toolbar.setItems([doneBtn], animated: true)
        }
        datePicker.minimumDate = Date()
        datePicker.datePickerMode = .dateAndTime
        to.inputAccessoryView = toolbar
        to.inputView = datePicker
    }
    
    @objc func startDonePressed() {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        startDatePicker.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
    @objc func endDonePressed(){
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        endDatePicker.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
}

//MARK: ImagePickerView delegate and NavigationController delegate

extension EEventCreateViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate{
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
            self.photoUrl = url.absoluteString
            uploadEventPhoto(fileURL: url)
        }
        imagePickerController.dismiss(animated: true, completion: nil)
    }
    
    private func uploadEventPhoto(fileURL: URL){
        let storageRef = self.storage.reference()
        
        let photoRef = storageRef.child("eventPhotos/\(fileURL)")
        
        let uploadTask = photoRef.putFile(from: fileURL, metadata: nil) { (metadata, error) in
            if error != nil {
                print(error)
            }else{
                print("Photo has successfuly uploaded.")
                self.eventPhotoImageView.sd_setImage(with: photoRef)
            }
        }
    }
}

//MARK: UITextFieldDelegate for testing
extension EEventCreateViewController: UITextFieldDelegate{
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField == self.eventDescriptionTextField{
            if textField.text == "" || textField.text!.count < 8 || textField.text!.count > 140 {
                textField.text = ""
                textField.placeholder = "Between 8-140 character"
                return false
            }
        }else{
            if textField.text == "" || textField.text!.count < 8 || textField.text!.count > 34 || textField.text!.contains("*") || textField.text!.contains("%") || textField.text!.contains("+") || textField.text!.contains("?") || textField.text!.contains("!") || textField.text!.contains(".") || textField.text!.contains(",") || textField.text!.contains("(") || textField.text!.contains(")") {
                textField.text = ""
                textField.placeholder = "Between 8-34 character"
                return false
            }
        }
         return true
    }
}
