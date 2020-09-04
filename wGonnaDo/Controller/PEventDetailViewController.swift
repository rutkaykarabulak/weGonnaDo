//
//  PEventDetailViewController.swift
//  wGonnaDo
//
//  Created by Rutkay Karabulak on 24.05.2020.
//  Copyright © 2020 Rutkay Karabulak. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI
class PEventDetailViewController: UIViewController{
    
    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var nameOfTheEvent: UILabel!
    @IBOutlet weak var descriptionTView: UITextView!
    @IBOutlet weak var startDateTextField: UITextField!
    @IBOutlet weak var endDateTextField: UITextField!
    @IBOutlet weak var addressTView: UITextView!
    @IBOutlet weak var disenrollButton: UIButton!
    
    var delegate: DisenrollEventDelegate?
    // passedEvent from event list
    var passedPEvent: ParticipantEvents?
    // passdent participant event id from list
    var passedPEventID: String?
    // variable of will updating event
    var updatedEventArray: [String]?
    // our database
    private let db = Firestore.firestore()
    // currentUser
    private let currentUser = Auth.auth().currentUser
    // Our firebase storage
    private var storage = Storage.storage()
    override func viewDidLoad() {
        super.viewDidLoad()
        getEventPhoto()
        nameOfTheEvent.text = passedPEvent?.name
        descriptionTView.text = passedPEvent?.description
        startDateTextField.text = passedPEvent?.startDate
        endDateTextField.text = passedPEvent?.endDate
        addressTView.text = passedPEvent?.address
        getWillUpdatingEvent()
        
        //Test amaçlı gelen döküman id ile uyusup uyusmadıgına bakalım
        print(self.passedPEventID)
    }
    
    
    @IBAction func dissenrollPressed(_ sender: Any) {
        // participantUser dokumani silinecek, ve bağlı olduğunu event'in participant kısmındaki kendi ismi silinecek
        
        let alert = UIAlertController(title: "Disenrolling", message: "Are you sure about disenroll yourself from \(passedPEvent?.name)", preferredStyle: .alert)
        let yes = UIAlertAction(title: "Yes", style: .default) { (action) in
            if let passedPEventID = self.passedPEventID{
                self.db.collection(K.CollectionType.participantEvents).document(passedPEventID).delete { (error) in
                    if error != nil {
                        print(error)
                    }else {
                        // burada event'e ait participant kısmından current user imiz çıkarılacak ve yeni array güncellenip set data ile dökümanı güncelleyecek
                        
                        // Kullanıcımızı silmek üzerine değişkene atıyoruz
                        let objectToRemove = self.currentUser?.email
                        // event participant tarafından disenroll edildiği için eski array'den participant'i çıkarıyoruz
                        self.updatedEventArray?.remove(object: objectToRemove!)
                        // yeni dizimizi mevcut eventimize ataylım
                        self.db.collection(K.CollectionType.events).document(self.passedPEvent!.eventID).setData([
                            K.Events.participants: self.updatedEventArray
                        ], merge: true)
                        
                        
                        print("You successfuly disenroll from the event.")
                        
                        // After disenroll button will be hidden and unpressable.
                        self.disenrollButton.isHidden = true
                        // Trigger for reloading table view for updating new event list.
                        self.delegate?.didTriggerTableViewReload()
                    }
                }
            }
        }
        let no = UIAlertAction(title: "No", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(yes)
        alert.addAction(no)
        present(alert,animated: true,completion: nil)
    }
    private func getWillUpdatingEvent(){
        if let ID = passedPEvent?.eventID {
            db.collection(K.CollectionType.events).document(ID).getDocument { (snapshot, error) in
                if error != nil {
                    print(error)
                }else {
                    if let snapshot = snapshot {
                        // Event dökümanımızın participant array'ini string olarak alıp güncellenecek diziye atyoruz.
                        self.updatedEventArray = snapshot.data()![K.Events.participants] as? [String]
                        
                    }
                }
            }
        }
    }
}

// Here is a cool and easy extension to remove elements in an array, without filtering :
 extension Array where Element: Equatable {

    // Remove first collection element that is equal to the given `object`:
    mutating func remove(object: Element) {
        guard let index = firstIndex(of: object) else {return}
        remove(at: index)
    }

}

extension PEventDetailViewController{
    private func getEventPhoto(){
        let storageRef = self.storage.reference()
        
        let photoRef = storageRef.child("eventPhotos/\(self.passedPEvent!.photoUrl!)")
        
        self.eventImageView.sd_setImage(with: photoRef)
    }
}
