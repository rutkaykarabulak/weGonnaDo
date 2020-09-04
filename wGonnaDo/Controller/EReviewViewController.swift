//
//  EReviewViewController.swift
//  wGonnaDo
//
//  Created by Rutkay Karabulak on 29.05.2020.
//  Copyright © 2020 Rutkay Karabulak. All rights reserved.
//

import UIKit
import Firebase

class EReviewViewController: UIViewController{
    @IBOutlet weak var reviewTableView: UITableView!
    
    private let db = Firestore.firestore()
    private let currenUser = Auth.auth().currentUser
    
    // Array of reviews
    private var reviews: [Review] = []
    // arary of array document ID
    private var reviewDocID: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getReviews()
    }
    
    private func getReviews(){
        db.collection(K.CollectionType.reviews).order(by: K.Reviews.creationDate).whereField(K.Reviews.whoseEvent, isEqualTo: currenUser?.email).addSnapshotListener { (snapshot, error) in
            if error != nil{
                print(error)
            }else{
                self.reviews = []
                self.reviewDocID = []
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

//MARK: TableView data source

extension EReviewViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.reviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ereviewCell", for: indexPath)
        cell.textLabel?.text = "\(self.reviews[indexPath.row].eventName) | Rating:\(self.reviews[indexPath.row].rating!)"
        cell.detailTextLabel?.text = "By: \(self.reviews[indexPath.row].who)"
        return cell
    }
}

extension EReviewViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let commentAlert = UIAlertController(title: "Comment", message: "", preferredStyle: .alert)
        commentAlert.message = "\(self.reviews[indexPath.row].comment)"
        let ok = UIAlertAction(title: "OK", style: .default) { (action) in
            commentAlert.dismiss(animated: true, completion: nil)
        }
        
        commentAlert.addAction(ok)
        present(commentAlert,animated: true,completion: nil)
        
    }
}
