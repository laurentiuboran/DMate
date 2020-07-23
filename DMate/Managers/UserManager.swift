//
//  UserManager.swift
//  DMate
//
//  Created by Laurențiu Boran on 24/04/2020.
//  Copyright © 2020 Weberco. All rights reserved.
//

import Foundation
import SwiftUI
import Firebase
import Combine
import FirebaseFirestore
import FirebaseAuth


class UserManager {
    
    @State private var id: String
    @State private var familyName: String
    @State private var name: String
    @State private var location: String
    @State private var sex: String
    @State private var lsty: [String]
    @State private var sy: [String]
    @State private var age: Int
    @State private var infectedScore: Int
    @State private var hasTravelled: Bool
    
    init(id: String, familyName: String, name: String, location: String, sex: String, lsty: [String], sy: [String], age: Int, infectedScore: Int, hasTravelled: Bool)
       {
            self.id = id
            self.familyName = familyName
            self.name = name
            self.location = location
            self.sex = sex
            self.lsty = lsty
            self.sy = sy
            self.age = age
            self.infectedScore = infectedScore
            self.hasTravelled = hasTravelled
       }
    
    private var db = Firestore.firestore()

}

struct UserManager_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
