//
//  ParticipantEvents.swift
//  wGonnaDo
//
//  Created by Rutkay Karabulak on 19.05.2020.
//  Copyright © 2020 Rutkay Karabulak. All rights reserved.
//

import UIKit
import Firebase
struct ParticipantEvents {
    var who: String
    var name: String
    var whoseEvent: String
    var address: String
    var eventID: String
    var startDate: String
    var endDate: String
    var description:String
    var otherParticipants: Array<Any>?
    var eventStatus: Bool
    var isComment: Bool
    var photoUrl: String?
}

