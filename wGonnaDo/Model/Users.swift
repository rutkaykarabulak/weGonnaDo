//
//  Users.swift
//  wGonnaDo
//
//  Created by Rutkay Karabulak on 13.05.2020.
//  Copyright © 2020 Rutkay Karabulak. All rights reserved.
//

import UIKit

class Users {
    private var fullname: String?
    private var username: String?
    private var email: String?
    private var gender: Bool?
    private var phonenumber: String?
    private var password: String?
    private var dateOfBirth: String?
    private var userType: Bool?
    
    var userTypeName: String {
        if(userType != nil && userType == true){
            return "Participants"
        }else if (userType != nil && userType == false) {
            return "Eventer"
        }else{
            return "non declared user type"
        }
    }
    
    var genderName: String {
        if (gender != nil && gender == true) {
            return "Men"
        }else if (gender != nil && gender == false) {
            return "Woman"
        }else{
            return "invalid type"
        }
    }
    
init(fullname: String, username: String, email: String, gender: Bool, phonenumber: String, password: String, dateofbirth: String, usertype: Bool) {
    self.fullname = fullname
    self.username = username
    self.email = email
    self.gender = gender
    self.phonenumber = phonenumber
    self.password = password
    self.dateOfBirth = dateofbirth
    self.userType = usertype
    }
}
