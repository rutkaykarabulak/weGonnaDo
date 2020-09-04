//
//  K.swift
//  wGonnaDo
//
//  Created by Rutkay Karabulak on 10.05.2020.
//  Copyright © 2020 Rutkay Karabulak. All rights reserved.
//

import UIKit
// Texts in applications would be dangerous sometime, for example if you made typo or something else your whole app could crashed.


// Constants help you to store your main texts for your application, and when you need it they are already static objects. They can be reached any part of your app.
struct K {
    
    // This part for segues
    struct Segues {
        static let loginToParticipant = "loginToParticipant"
        static let loginToEventer = "loginToEventer"
        static let loginToRegister = "loginToRegister"
        static let registerToLogin = "registerToLogin"
        static let createEventSegue = "createEventSegue"
        static let eventListToDetail = "eventListToDetail"
        static let joinEvent = "joinEvent"
        static let disenrollEvent = "disenrollEvent"
    }
    
    struct Users{
        static let dateOfBirth = "dateOfBirth"
        static let email = "email"
        static let fullName = "fullName"
        static let gender = "gender"
        static let password = "password"
        static let phoneNumber = "phoneNumber"
        static let userName = "userName"
        static let userType = "userType"
        static let photoUrl = "photoUrl"
        
    }
    
    struct Reviews{
        static let comment = "comment"
        static let creationDate = "creationDate"
        static let rating = "rating"
        static let whichEvent = "whichEvent"
        static let who = "who"
        static let whoseEvent = "whoseEvent"
        static let eventName = "eventName"
    }
    
    struct CollectionType {
        static let users = "Users"
        static let events = "Events"
        static let participantEvents = "ParticipantEvents"
        static let reviews = "Reviews"
    }
    
    struct ParticipantEvent {
        static let address = "address"
        static let who = "who"
        static let whoseEvent = "whoseEvent"
        static let eventID = "eventID"
        static let startDate = "startDate"
        static let endDate = "endDate"
        static let otherParticipants = "otherParticipants"
        static let description = "description"
        static let name = "name"
        static let eventStatus = "eventStatus"
        static let isComment = "isComment"
        static let photoUrl = "photoUrl"
        
    }
    
    struct Events{
        static let name = "name"
        static let description = "description"
        static let startDate = "startDate"
        static let endDate = "endDate"
        static let location = "location"
        static let participants = "participants"
        static let owner = "owner"
        static let point = "point"
        static let status = "status"
        static let address = "address"
        static let creationDate = "creationDate"
        static let photoUrl = "photoUrl"
    }
    
    struct Cells {
        static let eventCell = "eventCell"
        static let reviewCell = "reviewCell"
    }

    
}
