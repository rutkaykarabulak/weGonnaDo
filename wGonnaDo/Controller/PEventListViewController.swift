//
//  UEventListViewController.swift
//  wGonnaDo
//
//  Created by Rutkay Karabulak on 5.05.2020.
//  Copyright © 2020 Rutkay Karabulak. All rights reserved.
//

import UIKit
import Firebase
class PEventListViewController : UIViewController {
    @IBOutlet weak var participantEventsTableView: UITableView!
    // Our database
    private let db = Firestore.firestore()
    // Our current user
    private let currentUser = Auth.auth().currentUser
    // Array of current attending events belong to current uesr
    private var participantEvents: [ParticipantEvents] = []
    // Array of doc id's
    private var docID: [String] = []
    // This variable will keep information about selected index for cell
    private var selectedIndex: IndexPath?
    // This variable will passed to dictCell for passing event id to segue
    private var selectedCell: UITableViewCell?
    // Dictionary of cell and docID that belongs to indicated cell
    var dictCell: [UITableViewCell:String] = [:]
    override func viewDidLoad() {
        super.viewDidLoad()
        participantEventsTableView.delegate = self
        participantEventsTableView.dataSource = self
        getParticipantEvents()
    }
    
    @IBAction func logOutPressed(_ sender: Any) {
        //       performSegue(withIdentifier: "participantLogOut", sender: self)
        dismiss(animated: true, completion: nil)
        // !!!! giriş sayfasındaki text fieldlar sıfırlanacak !!!!
    }
    
    
    // First of all let's getting all events belong to current user
    func getParticipantEvents(){
        
        db.collection(K.CollectionType.participantEvents).whereField(K.ParticipantEvent.eventStatus, isEqualTo: true).whereField(K.ParticipantEvent.who, isEqualTo: currentUser?.email).addSnapshotListener { (snapshot, error) in
            if error != nil {
                print("error occured during fetching events: \(error)")
            }else{
                self.participantEvents = []
                self.docID = []
                self.dictCell = [:]
                if let snapshotDocument = snapshot?.documents{
                    for doc in snapshotDocument {
                        let data = doc.data()
                        if let who = data[K.ParticipantEvent.who] as? String, let name = data[K.ParticipantEvent.name] as? String, let whoseEvent = data[K.ParticipantEvent.whoseEvent] as? String, let address = data[K.ParticipantEvent.address] as? String, let eventID = data[K.ParticipantEvent.eventID] as? String, let startDate = data[K.ParticipantEvent.startDate] as? String, let endDate = data[K.ParticipantEvent.endDate] as? String, let description = data[K.ParticipantEvent.description] as? String, let otherParticipants = data[K.ParticipantEvent.otherParticipants] as? Array<Any>, let eventStatus = data[K.ParticipantEvent.eventStatus] as? Bool, let isComment = data[K.ParticipantEvent.isComment] as? Bool, let photoUrl = data[K.ParticipantEvent.photoUrl] as? String{
                            let participantEvents = ParticipantEvents(who: who, name: name, whoseEvent: whoseEvent, address: address, eventID: eventID, startDate: startDate, endDate: endDate, description: description, otherParticipants: otherParticipants,eventStatus: eventStatus,isComment: isComment,photoUrl: photoUrl)
                            self.participantEvents.append(participantEvents)
                            self.docID.append(doc.documentID)
                         
                            DispatchQueue.main.async {
                                self.participantEventsTableView.reloadData()
                            }
                        }
                        
                    }
                }
            }
        }
    }
    
    
    
}

//MARK: TableView data source
extension PEventListViewController:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return participantEvents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.Cells.eventCell, for: indexPath)
        let eventForCell = participantEvents[indexPath.row]
        cell.textLabel?.text = eventForCell.name
        cell.detailTextLabel?.text = String(eventForCell.startDate.prefix(7))
        self.dictCell[cell] = docID[indexPath.row]
        return cell
    }
    
    
}


//MARK: TablewView Delegate Methods

extension PEventListViewController: UITableViewDelegate{
    // When the tapped to index, related event and ID will be passed to segue
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedIndex = indexPath
        self.selectedCell = tableView.cellForRow(at: indexPath)
        performSegue(withIdentifier: K.Segues.disenrollEvent, sender: self)
        // Deneme amaclı geçirilecek participantEvents dökümanımızın ID sini görelim
        print(dictCell[tableView.cellForRow(at: selectedIndex!)!])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = selectedIndex,let selectedCell = selectedCell, segue.identifier == K.Segues.disenrollEvent {
            let VC = segue.destination as! PEventDetailViewController
            VC.passedPEvent = participantEvents[indexPath.row]
            VC.passedPEventID = dictCell[selectedCell]
            VC.delegate = self
        }
    }
}


// Delegate methot for updating viewDidLoad

extension PEventListViewController: DisenrollEventDelegate{
    func didTriggerTableViewReload() {
        // Bu delegate yöntemi sayesinde participant herhangi bir eventten kendini disenroll yapması durumunda table view'ü güncelleyecek.
        self.participantEventsTableView.reloadData()
    }
}
