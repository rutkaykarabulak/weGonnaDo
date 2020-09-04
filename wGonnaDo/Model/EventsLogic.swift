//
//  EventsLogic.swift
//  wGonnaDo
//
//  Created by Rutkay Karabulak on 17.05.2020.
//  Copyright © 2020 Rutkay Karabulak. All rights reserved.
//

import UIKit
import Firebase

class EventsLogic {
    var event: [Event]?
    private var currentUser = Auth.auth().currentUser
    let db = Firestore.firestore()
    
    public func  getEventsFromFirebase(toDo: @escaping ()->()) {
    self.db.collection(K.CollectionType.events).whereField(K.Events.owner, isEqualTo: currentUser!.email).addSnapshotListener { (snapshot, error) in
            if error != nil {
                print(error)
            }else {
                if let snapshotDocument = snapshot?.documents{
                    for doc in snapshotDocument {
                        let data = doc.data()
                        if let name = data[K.Events.name] as? String, let owner = data[K.Events.owner] as? String, let address = data[K.Events.address] as? String, let endDate = data[K.Events.endDate] as? String, let startDate = data[K.Events.startDate] as? String , let location = data[K.Events.location] as? GeoPoint, let description = data[K.Events.description] as? String, let status = data[K.Events.point] as? Bool, let point = data[K.Events.point] as? Int, let creationDate = data["creationDate"] as? TimeInterval, let photoUrl = data[K.Events.photoUrl] as? String{
                            let event = Event(name: name, owner: owner, address: address, startDate: startDate, endDate: endDate, status: status, location: location, description: description, point: point, creationDate: creationDate,photoUrl: photoUrl)
                            self.event?.append(event)
                            DispatchQueue.main.async {
                              toDo()
                            }
                        }
                        
                    }
                }
            }
        }
    }
}
