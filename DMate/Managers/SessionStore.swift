//
//  SessionStore.swift
//  DMate
//
//  Created by Laurențiu Boran on 18/04/2020.
//  Copyright © 2020 Weberco. All rights reserved.
//

import Foundation
import SwiftUI
import Firebase
import Combine
import FirebaseFirestore

class SessionStore : ObservableObject {
    var didChange = PassthroughSubject<SessionStore, Never>()
    var session: User? { didSet { self.didChange.send(self) }}
    var handle: AuthStateDidChangeListenerHandle?
    @Published var sym = [Symptom]()
    @Published var loc = [Infectable]()
    
    private var db = Firestore.firestore()
    
    struct Symptom: Identifiable {
        var id: String = UUID().uuidString
        var names: String
        var value: Int
    }
    
    struct Infectable: Identifiable {
        var id: String = UUID().uuidString
        var location: String
        var infectedScore: String
    }
    
    func fetchData(databaseName: String) {
        db.collection(databaseName).addSnapshotListener{ (querySnapshot, error) in
        guard let documents = querySnapshot?.documents else {
            print("Niciun document")
            return
        }
        
        self.sym = documents.map { queryDocumentSnapshot -> Symptom in
            let data = queryDocumentSnapshot.data()
            let names = data["names"] as? String ?? ""
            let value = data["value"] as? Int ?? 0
            print(names)
            print(value)
            return Symptom(id: .init(), names: names, value: value)
        }
    }
    }
    
    func fetchDataLocation() {
        db.collection("locations").addSnapshotListener{ (querySnapshot, error) in
        guard let documents = querySnapshot?.documents else {
            print("Niciun document")
            return
        }
        
        self.loc = documents.map { queryDocumentSnapshot -> Infectable in
            let data = queryDocumentSnapshot.data()
            let location = data["location"] as? String ?? ""
            let infectedScore = data["infectedScore"] as? String ?? ""
            print(location)
            print(infectedScore)
            return Infectable(id: .init(), location: location, infectedScore: infectedScore)
        }
    }
    }
    
    func listen() -> Bool {
        
        if Auth.auth().currentUser != nil {
            return true
        } else {
            return false
        }
        
    }
    
     func signUp(
            email: String,
            password: String,
            handler: @escaping AuthDataResultCallback
            ) {
            Auth.auth().createUser(withEmail: email, password: password, completion: handler)
        }

        func signIn(
            email: String,
            password: String,
            handler: @escaping AuthDataResultCallback
            ) {
            Auth.auth().signIn(withEmail: email, password: password, completion: handler)
        }

        func signOut () -> Bool {
            do {
                try Auth.auth().signOut()
                self.session = nil
                return true
            } catch {
                return false
            }
        }
        func unbind () {
            if let handle = handle {
                Auth.auth().removeStateDidChangeListener(handle)
            }
        }
    
}

struct SessionStore_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
