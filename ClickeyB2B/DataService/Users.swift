//
//  userObject.swift
//  Yona
//
//  Created by Ben Smith on 31/03/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

struct Users{
    var userID: String!
    var firstName: String!

    init(userData: BodyDataDictionary) {
        
        userID = "NOID"
        firstName = ""
    }

}