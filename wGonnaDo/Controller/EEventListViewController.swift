//
//  EEventListViewController.swift
//  wGonnaDo
//
//  Created by Rutkay Karabulak on 7.05.2020.
//  Copyright © 2020 Rutkay Karabulak. All rights reserved.
//
import UIKit
import Firebase
class EEventListViewcontroller: UIViewController {
  
    @IBOutlet weak var eventTableView: UITableView!
    // Current user
    private let currentUser = Auth.auth().currentUser!
    // Our database
    private let db = Firestore.firestore()
    //When cells tapped the current index stores in this variable
    private var selectedIndex: IndexPath? = nil
    // Array of events from database
    private var events: [Event] = []
    // Array of documents ID
    private var docID: [String] = []
    // Dictionary of cells and docID pair, it contain spesific
    private var dictCell: [UITableViewCell:String] = [:]
    // Selected cell
    private var selectedCell: UITableViewCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eventTableView.dataSource = self
        eventTableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadEvents()
    }
    
    // load whole events which belong to eventer and add them to events array.
    func loadEvents() {
        db.collection(K.CollectionType.events)
            .order(by: K.Events.creationDate)
            .whereField(K.Events.owner, isEqualTo: currentUser.email).whereField(K.Events.status, isEqualTo: true)
            .addSnapshotListener { (snapshot, error) in
            if error != nil {
                print("can't read data from firebase \(error)")
            } else {
                self.events = []
                if let snapshotDocument = snapshot?.documents {
                    for doc in snapshotDocument{
                        let data = doc.data()
                        if let name = data[K.Events.name] as? String, let owner = data[K.Events.owner] as? String, let address = data[K.Events.address] as? String, let endDate = data[K.Events.endDate] as? String, let startDate = data[K.Events.startDate] as? String , let location = data[K.Events.location] as? GeoPoint, let description = data[K.Events.description] as? String, let status = data[K.Events.status] as? Bool, let point = data[K.Events.point] as? Int, let creationDate = data[K.Events.creationDate] as? TimeInterval, let participants = data[K.Events.participants] as? Array<Any>,let photoUrl = data[K.Events.photoUrl] as? String{
                            let event = Event(name: name, owner: owner, address: address, startDate: startDate, endDate: endDate, status: status, location: location, description: description, point: point, creationDate: creationDate,participants: participants,photoUrl: photoUrl)
                            self.events.append(event)
                            self.docID.append(doc.documentID)
                            DispatchQueue.main.async {
                                self.eventTableView.reloadData()
                            }
                        }
                       
                        
                    }
                }
            }
        }
    }
   
    
}


//MARK: TableViewDataSource methods
extension EEventListViewcontroller: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:K.Cells.eventCell , for: indexPath)
        let event = events[indexPath.row]
        cell.textLabel?.text = event.name
        cell.detailTextLabel?.text = event.status == true ? "Active" : "Deactive"
        cell.accessoryType = event.status == true ? UITableViewCell.AccessoryType.checkmark : UITableViewCell.AccessoryType.none
        // Assign spesific sell to the doc id with spesific docID
        self.dictCell[cell] = self.docID[indexPath.row]
        return cell
    }
}

//MARK: TableViewDelegate Methods
extension EEventListViewcontroller:UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        // Tıklanıldığı annda mevcut nesneyi event detail sınıfındaki nesneye aktaralım ve genel bilgilerini oradan çekelim.
        self.selectedIndex = indexPath
        self.selectedCell = tableView.cellForRow(at: indexPath)
        performSegue(withIdentifier: "eventListToDetail", sender: self)
        // It is for testing.
        print(dictCell[tableView.cellForRow(at: indexPath)!])
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = self.selectedIndex,let selectedCell = self.selectedCell, segue.identifier == K.Segues.eventListToDetail {
            let VC = segue.destination as! EEventDetailViewController
            VC.spesificID = dictCell[selectedCell]
            VC.detailedEvent = events[indexPath.row]
           
        }
    }
}


