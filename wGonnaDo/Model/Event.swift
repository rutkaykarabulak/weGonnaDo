//
//  Event.swift
//  wGonnaDo
//
//  Created by Rutkay Karabulak on 12.05.2020.
//  Copyright © 2020 Rutkay Karabulak. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase
struct Event {
    
    var name: String
    let owner: String
    var address: String
    var startDate: String
    var endDate: String
    var status: Bool?
    var location: GeoPoint
    var description: String
    var point: Int?
    var creationDate: TimeInterval?
    var participants: Array<Any>?
    var photoUrl: String?
}

