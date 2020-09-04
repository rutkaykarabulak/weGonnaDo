//
//  PReviewViewContoller.swift
//  wGonnaDo
//
//  Created by Rutkay Karabulak on 27.05.2020.
//  Copyright © 2020 Rutkay Karabulak. All rights reserved.
//

import UIKit
import Firebase

class PReviewViewController: UIViewController{
    // Reviews going to stay in this table view
    @IBOutlet weak var reviewTableView: UITableView!
    
    // Our current User
    private let currentUser = Auth.auth().currentUser
    // Our database
    private let db = Firestore.firestore()
    // Array of our deactivate events
    private var passiveEvents: [ParticipantEvents] = []
    // Array of passive events docID's
    private var docID: [String] = []
    // Dict o cell and doc id pair
    private var dictCell: [UITableViewCell:String] = [:]
    // Picker View for passive event selection
    private var pickerView: UIPickerView?
    // Picker view for rating
    private var ratingPView: UIPickerView?
    // rating arays
    private var ratings = [1,2,3,4,5]
    // Our text field for alert
    private var pickerTextField: UITextField?
    // Comment text field
    private var commentTextField: UITextField?
    // Rating text field
    private var ratingTextField: UITextField?
    // This index for picker view row
    private var selectedIndex: Int?
    
    // this part belongs to table view
    var reviewDocID:[String] = []
     var reviews: [Review] = []
     var reviewID: [String] = []
    // bunu kullanmadık
     var dictReview: [UITableViewCell:String] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reviewTableView.dataSource = self
        reviewTableView.delegate = self
        // getting passive events
        getPassiveEvents()
        getReviews()
    }
    
    @IBAction func addReviewPressed(_ sender: UIButton) {
        if self.passiveEvents.count == 0 {
            let alert = UIAlertController(title: "No Event", message: "There is no passive event to make review", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Ok", style: .default) { (action) in
                alert.dismiss(animated: true, completion: nil)
            }
            alert.addAction(ok)
            present(alert,animated: true,completion: nil)
        }else{
            
        
        let alert = UIAlertController(title: "Review", message: "Please select an event for adding review", preferredStyle: .alert)
        alert.addTextField { (textField) in
            self.createPickerView(to: textField)
            self.pickerTextField = textField
        }
        alert.addTextField { (textField) in
            self.createRatingPView(to: textField)
            self.ratingTextField = textField
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "Type your comment"
            textField.textAlignment = .center
            self.commentTextField = textField
            self.commentTextField?.delegate = self
        }
        // yes ve no butonları eklenecek
        let yes = UIAlertAction(title: "Yes", style: .default) { (action) in
            if self.commentTextField?.text != "" && self.ratingTextField?.text != "" && self.pickerTextField?.text != "" {
                self.db.collection(K.CollectionType.reviews).addDocument(data: [
                               K.Reviews.who: self.currentUser?.email,
                               K.Reviews.creationDate: Date().timeIntervalSince1970,
                               K.Reviews.comment: self.commentTextField?.text,
                               K.Reviews.rating: Int(self.ratingTextField!.text!),
                               K.Reviews.whichEvent: self.docID[self.selectedIndex!],
                               K.Reviews.whoseEvent: self.passiveEvents[self.selectedIndex!].whoseEvent,
                               K.Reviews.eventName: self.passiveEvents[self.selectedIndex!].name
                           ]) { (error) in
                               if error != nil {
                                   print(error)
                               }else{
                                   // Buraya mevcut passive event'in is commenti false yapılacak
                                   self.db.collection(K.CollectionType.participantEvents).document(self.docID[self.selectedIndex!]).setData([
                                       K.ParticipantEvent.isComment: true
                                   ], merge: true)
                                   print("Review has successfuly added.")
                               }
                           }
            }else {
                self.pickerTextField?.placeholder = "Select an event"
                self.commentTextField?.placeholder = "Make a comment"
                self.ratingTextField?.text = "Select a rating"
            }
            
           
        }
        let no = UIAlertAction(title: "No", style: .cancel) { (action) in
            print(self.selectedIndex)
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(yes)
        alert.addAction(no)
        present(alert,animated: true,completion: nil)
        }
    }
    
    private func createRatingPView(to: UITextField){
        self.ratingPView = UIPickerView()
        ratingPView?.delegate = self
        ratingPView?.dataSource = self
        
        to.inputView = ratingPView
        to.textAlignment = .center
        to.placeholder = "Select your rating"
    }
    
    private func createPickerView(to: UITextField){
        
        self.pickerView = UIPickerView()
        pickerView?.delegate = self
        pickerView?.dataSource = self
        
        to.inputView = pickerView
        to.textAlignment = .center
        to.placeholder = "Select Event"
    }
    
    // In this function we are going to fetch all passive events belong to our current user
    private func getPassiveEvents(){
        db.collection(K.CollectionType.participantEvents).whereField(K.ParticipantEvent.who, isEqualTo: currentUser?.email).whereField(K.ParticipantEvent.eventStatus, isEqualTo: false).whereField(K.ParticipantEvent.isComment, isEqualTo: false).addSnapshotListener { (snapshot, error) in
            if error != nil {
                print(error)
            }else{
                self.passiveEvents = []
                self.docID = []
                if let snapshotDocument = snapshot?.documents{
                    for doc in snapshotDocument{
                        let data = doc.data()
                        if let who = data[K.ParticipantEvent.who] as? String, let name = data[K.ParticipantEvent.name] as? String, let whoseEvent = data[K.ParticipantEvent.whoseEvent] as? String, let address = data[K.ParticipantEvent.address] as? String, let eventID = data[K.ParticipantEvent.eventID] as? String, let startDate = data[K.ParticipantEvent.startDate] as? String, let endDate = data[K.ParticipantEvent.endDate] as? String, let description = data[K.ParticipantEvent.description] as? String, let otherParticipants = data[K.ParticipantEvent.otherParticipants] as? Array<Any>, let eventStatus = data[K.ParticipantEvent.eventStatus] as? Bool, let isComment = data[K.ParticipantEvent.isComment] as? Bool,let photoUrl = data[K.ParticipantEvent.photoUrl] as? String{
                            let passiveEvent = ParticipantEvents(who: who, name: name, whoseEvent: whoseEvent, address: address, eventID: eventID, startDate: startDate, endDate: endDate, description: description, otherParticipants: otherParticipants, eventStatus: eventStatus, isComment: isComment,photoUrl: photoUrl)
                            self.passiveEvents.append(passiveEvent)
                            self.docID.append(doc.documentID)
                        }
                    }
                }
            }
        }
    }
    
}

//MARK: PickerView delegate
extension PReviewViewController: UIPickerViewDelegate,UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerView == self.ratingPView{
            return 1
        }else{
            // passive Event pickerView
            return 1
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == self.ratingPView{
            return self.ratings.count
        }else{
            // Passive event picker view
            return self.passiveEvents.count
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == self.ratingPView{
            return String(ratings[row])
        }else{
            // Passive event picker view
            let passiveEvent = self.passiveEvents[row]
            return passiveEvent.name
        }
        
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == self.ratingPView{
            self.ratingTextField?.text = String(ratings[row])

        }else{
            // Passive event picker view
            print("Your event name: \(passiveEvents[row].name) , Your event ID: \(docID[row])")
            self.pickerTextField?.text = self.passiveEvents[row].name
            self.selectedIndex = row

        }
        
    }
    
}
//MARK: TableView datasource
extension PReviewViewController:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.reviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.Cells.reviewCell, for: indexPath)
        cell.textLabel?.text = self.reviews[indexPath.row].eventName
        cell.detailTextLabel?.text = "Rating:\(String(self.reviews[indexPath.row].rating!))"
        return cell
    }
    
    func getReviews(){
        self.db.collection(K.CollectionType.reviews).order(by: K.Reviews.creationDate).whereField(K.Reviews.who, isEqualTo: currentUser?.email).addSnapshotListener { (snapshot, error) in
            if error != nil{
                print(error)
            }else{
                self.reviewDocID = []
                self.reviews = []
                if let snapshotDocument = snapshot?.documents{
                    for doc in snapshotDocument{
                        let data = doc.data()
                        if let who = data[K.Reviews.who] as? String, let whichEvent = data[K.Reviews.whichEvent] as? String, let comment = data[K.Reviews.comment] as? String, let eventName = data[K.Reviews.eventName] as? String, let creationDate = data[K.Reviews.creationDate] as? TimeInterval, let rating = data[K.Reviews.rating] as? Int, let whoseEvent = data[K.Reviews.whoseEvent] as? String{
                            let review = Review(who: who, whichEvent: whichEvent, whoseEvent: whoseEvent, creationDate: creationDate, rating: rating, comment: comment, eventName: eventName)
                            self.reviews.append(review)
                            self.reviewDocID.append(doc.documentID)
                            DispatchQueue.main.async {
                                self.reviewTableView.reloadData()
                            }
                        }
                    }
                }
            }
        }
    }
    
}


extension PReviewViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let review = self.reviews[indexPath.row]
        let commentAlert = UIAlertController(title: "Your comment on selected event", message: "", preferredStyle: .alert)
        commentAlert.message = "\(review.comment)"
        let ok = UIAlertAction(title: "OK", style: .cancel) { (action) in
            commentAlert.dismiss(animated: true, completion: nil)
        }
        commentAlert.addAction(ok)
        present(commentAlert,animated: true,completion: nil)
    }
}

//MARK: UTextFieldDelegate for testing

extension PReviewViewController: UITextFieldDelegate{
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text == "" || textField.text!.count < 4 || textField.text!.count > 140 {
            textField.text = ""
            textField.placeholder = "4-140 character"
            return false
        }
        return true
    }
}
