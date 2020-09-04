//
//  JoinEventViewController.swift
//  wGonnaDo
//
//  Created by Rutkay Karabulak on 19.05.2020.
//  Copyright © 2020 Rutkay Karabulak. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI
import Photos

class PJoinEventViewController: UIViewController {
    @IBOutlet weak var nameOfTheEventLabel: UILabel!
    @IBOutlet weak var eventDescriptionTView: UITextView!
    @IBOutlet weak var startDateTextField: UITextField!
    @IBOutlet weak var endDateTextField: UITextField!
    @IBOutlet weak var addressTView: UITextView!
    @IBOutlet weak var eventPhotoImageView: UIImageView!
    
    private let currentUser = Auth.auth().currentUser
    private let db = Firestore.firestore()
    
    var delegate: JoinViewDelegate?
    // passedEventID will be filled from PMainViewController
    var passedEventID: String = ""
    // passedEvent will be fileld by PMainViewController
    var passedEvent: Event?
    // list of other participants in event
    private var participantList: Array<Any> = []
    // Our firebase storage
    private var storage = Storage.storage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getEventPhoto()
        nameOfTheEventLabel.text = passedEvent?.name
        eventDescriptionTView.text = passedEvent?.description
        startDateTextField.text = passedEvent?.startDate
        endDateTextField.text = passedEvent?.endDate
        addressTView.text = passedEvent?.address
        print(passedEventID)
        
    }

    
    @IBAction func joinEventPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Joining to Event", message: "Are you sure about attending this event?", preferredStyle: .alert)
        let yes = UIAlertAction(title: "Yes", style: .default) { (action) in
            // If its chosen, new ParticipantEvent document will created and user email will appen to participant array which is property of Event document
            self.db.collection(K.CollectionType.participantEvents).addDocument(data: [
                K.ParticipantEvent.name: self.passedEvent?.name,
                K.ParticipantEvent.address: self.passedEvent?.address,
                K.ParticipantEvent.description: self.passedEvent?.description,
                K.ParticipantEvent.startDate: self.passedEvent?.startDate,
                K.ParticipantEvent.endDate: self.passedEvent?.endDate,
                K.ParticipantEvent.eventID: self.passedEventID,
                K.ParticipantEvent.who: self.currentUser?.email,
                K.ParticipantEvent.whoseEvent: self.passedEvent?.owner,
                K.ParticipantEvent.otherParticipants:self.passedEvent?.participants,
                K.ParticipantEvent.eventStatus: self.passedEvent?.status,
                K.ParticipantEvent.isComment: false,
                K.ParticipantEvent.photoUrl: self.passedEvent?.photoUrl
                // whose event and other participants
            
            ]) { (error) in
                if error != nil {
                    print(error)
                }else{
                    self.passedEvent?.participants?.append(self.currentUser?.email)
                    self.db.collection(K.CollectionType.events).document(self.passedEventID).setData([
                        K.Events.participants: self.passedEvent?.participants
                    ], merge: true)
                    print("succsessfuly enrolled to event")
                    self.delegate?.didTriggerViewDidLoad()
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
        let no = UIAlertAction(title: "No", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(yes)
        alert.addAction(no)
        present(alert,animated: true, completion: nil)
    }
}

//MARK: Get event photo

extension PJoinEventViewController{
    // With firebase storage extension, we can fetch photo from database.
    private func getEventPhoto(){
        let storageRef = self.storage.reference()
        
        let photoRef = storageRef.child("eventPhotos/\(self.passedEvent!.photoUrl!)")
        
        self.eventPhotoImageView.sd_setImage(with: photoRef)
        
     
    }
}
