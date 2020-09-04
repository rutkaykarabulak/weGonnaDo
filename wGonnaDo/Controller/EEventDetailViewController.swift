//
//  EEventDetailViewController.swift
//  wGonnaDo
//
//  Created by Rutkay Karabulak on 18.05.2020.
//  Copyright © 2020 Rutkay Karabulak. All rights reserved.
//

import UIKit
import Firebase
import Photos
import FirebaseUI
class EEventDetailViewController: UIViewController {
    @IBOutlet weak var nameOfEventLabel: UILabel!
    @IBOutlet weak var eventDescriptionTView: UITextView!
    @IBOutlet weak var startDateTField: UITextField!
    @IBOutlet weak var endDateTField: UITextField!
    @IBOutlet weak var addressTView: UITextView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var eventPhotoImageView: UIImageView!
    @IBOutlet weak var participantsTextView: UITextView!
    @IBOutlet weak var participantCount: UILabel!
    // Event comes from Event List
    var detailedEvent: Event?
    // Doc id comes from Event list
    var spesificID: String?
    // Our current user
    private let currentUser = Auth.auth().currentUser
    // Our database
    private let db = Firestore.firestore()
    // With this array, if user attend to cancel event, related participantEvents will be deleted from this array
    private var docWillDelete: [String] = []
    // Our firebase storage
    private var storage = Storage.storage()
    // List of participants belongs to current event which is showing on detail page
    private var listOfUsers = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameOfEventLabel.text = detailedEvent?.name
        eventDescriptionTView.text = detailedEvent?.description
        startDateTField.text = detailedEvent?.startDate
        endDateTField.text = detailedEvent?.endDate
        addressTView.text = detailedEvent?.address
        getEventPhoto()
        //Test amaçlı gelen id ile buradaki id uyusuyor mu bakıyoruz
        print(spesificID)
        //
        getOtherParticipantEvents()
    }
    // buraya bu eventle alakalı olan participantEvent'lerin de silinmelei sağlanacak
    @IBAction func cancelPressed(_ sender: UIButton) {
      // In this section we're going to delete spesific event belongs to user
        let alert = UIAlertController(title: "Delete an event", message: "Are you sure about deleting this event?", preferredStyle: .alert)
        let yes = UIAlertAction(title: "Yes", style: .default) { (action) in
            if let spesificID = self.spesificID{
                self.db.collection(K.CollectionType.events).document(spesificID).delete { (error) in
                    if error != nil{
                        print(error)
                    }else{
                        // burada o event'e katılmış olan tüm participantEvents dökümanlarını da sileceğiz
                        // lets do deleting event with for loop
                        for doc in self.docWillDelete{
                            self.db.collection(K.CollectionType.participantEvents).document(doc).delete { (error) in
                                if error != nil{
                                    print("Error while trying to delete related participantEvents \(error)")
                                }else{
                                    print("Related event deleted succsessfuly")
                                }
                            }
                        }
                        print("Whole process done properly.")
                    }
                }
            }
            self.cancelButton.isHidden = true
        }
        let no = UIAlertAction(title: "No", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(yes)
        alert.addAction(no)
        present(alert,animated: true,completion: nil)
    }
 
    private func getOtherParticipantEvents(){
        // This function helps you get all participantEvents document for deleting them after
        db.collection(K.CollectionType.participantEvents).whereField(K.ParticipantEvent.eventID, isEqualTo: spesificID).getDocuments { (snapshot, error) in
            if error != nil{
                print(error)
            }else{
                if let snapshotDocument = snapshot?.documents{
                    for doc in snapshotDocument{
                        self.docWillDelete.append(doc.documentID)
                        self.listOfUsers.append((doc.data()["who"] as? String)!)
                        var str = ""
                        for i in self.listOfUsers{
                            str += "\(i) \n"
                            self.participantsTextView.text = str
                            self.participantCount.text = "\(self.docWillDelete.count)/50"
                        }
                        print(self.docWillDelete)
                    }
                }
            }
        }
    }
    
}

//MARK: Get event photo from firebase storage

extension EEventDetailViewController{
    private func getEventPhoto(){
        let storageRef = self.storage.reference()
        
        let photoRef = storageRef.child("eventPhotos/\(self.detailedEvent!.photoUrl!)")
        
        self.eventPhotoImageView.sd_setImage(with: photoRef)
    }
}
