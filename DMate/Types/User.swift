//
//  User.swift
//  DMate
//
//  Created by Laurențiu Boran on 24/04/2020.
//  Copyright © 2020 Weberco. All rights reserved.
//

import Foundation

class User {
    var uid: String
    var displayName: String
    var email: String
    
    init(uid: String, displayName: String, email: String)
    {
        self.uid = uid
        self.displayName = displayName
        self.email = email
    }
}
