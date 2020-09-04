//
//  EventDateLogic.swift
//  wGonnaDo
//
//  Created by Rutkay Karabulak on 30.05.2020.
//  Copyright © 2020 Rutkay Karabulak. All rights reserved.
//

import UIKit
import Firebase

class EventDateLogic{
    var peID: [String] = []
    
    var willDelete: [Event] = []
    
    var willDeleteID: [String] = []
    // öncelikle tüm sistemdeki tüm eventleri alalım
    
    private let db = Firestore.firestore()
    
     func getWholeEvents(){
        db.collection(K.CollectionType.events).whereField(K.Events.status, isEqualTo: true).getDocuments { (snapshot, error) in
            if error != nil {
                print(error)
            }else{
                if let snapshotDocument = snapshot?.documents{
                    for doc in snapshotDocument{
                        let data = doc.data()
                        if let name = data[K.Events.name] as? String, let owner = data[K.Events.owner] as? String, let address = data[K.Events.address] as? String, let endDate = data[K.Events.endDate] as? String, let startDate = data[K.Events.startDate] as? String , let location = data[K.Events.location] as? GeoPoint, let description = data[K.Events.description] as? String, let status = data[K.Events.status] as? Bool, let point = data[K.Events.point] as? Int, let creationDate = data[K.Events.creationDate] as? TimeInterval, let participants = data[K.Events.participants] as? Array<Any>, let photoUrl = data[K.Events.photoUrl] as? String{
                            let event = Event(name: name, owner: owner, address: address, startDate: startDate, endDate: endDate, status: status, location: location, description: description, point: point, creationDate: creationDate, participants: participants,photoUrl: photoUrl)
                            let referID = doc.documentID
                            DispatchQueue.main.async {
                                self.compareTwoDate(forEvent: event, ID: referID)
                            }
                        }
                    }
                }
            }
        }
    }
    // Amacımız gelen her event'in saatini kontrol edip, koşulumuz sağlanıldığı anda o event'in status'unu passive hale getirmek
    // ve o evente bağlı olan participantEvent'leri de passive hale getirmek.
    
    private func compareTwoDate(forEvent: Event, ID: String){
        let currentDate = Date()
        let formatter = DateFormatter()
        // date type of formatter
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        let convertedDate = formatter.date(from: forEvent.endDate)
        
        if(currentDate >= convertedDate!){
            db.collection(K.CollectionType.events).document(ID).setData([
                K.Events.status: false
            ],merge: true) { (error) in
                if error != nil {
                    print(error)
                }else{
                    print("\(forEvent.name) has successfuly turned to passive")
                    // burada o event'e bağlı tüm participant eventlerin statusları false yapılacak
                    self.db.collection(K.CollectionType.participantEvents).whereField(K.ParticipantEvent.eventID, isEqualTo: ID).whereField(K.ParticipantEvent.eventStatus, isEqualTo: true).getDocuments { (snapshot, error) in
                        if error != nil{
                            print(error)
                        }else{
                            if let snapshotDocument = snapshot?.documents{
                                for doc in snapshotDocument{
                                    self.db.collection(K.CollectionType.participantEvents).document(doc.documentID).setData([
                                        K.ParticipantEvent.eventStatus: false
                                    ], merge: true) { (error) in
                                        if error != nil{
                                            print(error)
                                        }else{
                                            print("\(forEvent.name) related participant events have succsessfuly turned to passive")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }else{
            print("\(forEvent.name) still have a time for turning to passive")
        }
    }
    
}
