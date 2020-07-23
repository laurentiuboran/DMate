//
//  SignUpLifestyle.swift
//  DMate
//
//  Created by Laurențiu Boran on 20/04/2020.
//  Copyright © 2020 Weberco. All rights reserved.
//

import SwiftUI
import MapKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

struct SignUpLifestyleTypes: View {
    
    @ObservedObject var viewModel = SessionStore()
    @ObservedObject var viewModel2 = SessionStore()
    
    @State var selectionsLifestyle: [String] = []
    @State var selectionsPreconditions: [String] = []
    @State var login: Int? = nil
    @State var valueAll: Int = 0
    
    func fetchUsers() {
        
        let db = Firestore.firestore()
         
        db.collection("users").getDocuments() { (snapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            }
            else {
                for document in snapshot!.documents {
                    if (document.documentID == Auth.auth().currentUser!.uid) {
                        
                        let familyName = document.get("familyName") as! String
                        let name = document.get("name") as! String
                        
                        self.valueAll = document.get("infectedScore") as! Int
                        
                        print(familyName, name, self.valueAll)
                        
                    } } } } }
    
    var body: some View {
        Group {
        List {
            
                Section(header: ListHeaderLS()) {
                    ForEach(viewModel.sym, id: \.names) { sy in
                        MultipleSelectionRow(title: sy.names, isSelected: self.selectionsLifestyle.contains(sy.names)) {
                            if self.selectionsLifestyle.contains(sy.names) {
                                self.selectionsLifestyle.removeAll(where: { $0 == sy.names })
                            }
                            else {
                                self.selectionsLifestyle.append(sy.names)
                                self.valueAll = self.valueAll + (sy.value)
                            }
                            self.selectionsLifestyle = self.selectionsLifestyle.sorted()
                        }
                    }
                }
            
            }
            .listStyle(GroupedListStyle())
            .onAppear() {
                self.viewModel.fetchData(databaseName: "lifestyle")
                self.fetchUsers()
            }
            
            List {
                Section(header: ListHeaderPC()) {
                    ForEach(viewModel2.sym, id: \.names) { sy in
                        MultipleSelectionRow(title: sy.names, isSelected: self.selectionsPreconditions.contains(sy.names)) {
                            if self.selectionsPreconditions.contains(sy.names) {
                                self.selectionsPreconditions.removeAll(where: { $0 == sy.names })
                            }
                            else {
                                self.selectionsPreconditions.append(sy.names)
                                self.valueAll = self.valueAll + (sy.value)
                            }
                            self.selectionsPreconditions = self.selectionsPreconditions.sorted()
                        }
                    }
                    
                }
            }
            .listStyle(GroupedListStyle())
            .onAppear() {
                self.viewModel2.fetchData(databaseName: "preconditions")
                //self.fetchUsers()
            }
            
            Spacer().frame(height: 15)
            
            NavigationLink(destination: SignUpContact(), tag: 1, selection: $login) {
                Button(action: {
                    let docData: [String: Any] = [ "lsty": self.selectionsLifestyle, "infectedScore": self.valueAll, "precond": self.selectionsPreconditions ]
                    let db = Firestore.firestore()
                    db.collection("users").document(Auth.auth().currentUser!.uid).updateData(docData)
                    self.login = 1
                }) {
                    HStack {
                        Spacer()
                        Text("Continuă")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                }
            }
            .padding()
            .background(Color.blue)
            .cornerRadius(5)
            .padding([.leading, .trailing])
    
        }
            .navigationBarTitle("Stil de viață și afecțiuni")
            .navigationBarBackButtonHidden(true)
    }
           
    struct ListHeaderLS: View {
        var body: some View {
            HStack {
                Image(systemName: "person")
                Text("Selectați câteva dintre caracteristicile stilului dvs. de viață")
            }
        }
    }
    
    struct ListHeaderPC: View {
        var body: some View {
            HStack {
                Image(systemName: "bandage")
                Text("Prezentați una sau mai multe din aceste afecțiuni?")
            }
        }
    }
    
}

/***************************************************************************************/

struct SignUpLifestyleSymptoms: View {
    
    @ObservedObject var viewModel = SessionStore()
    @State var selectionsSymptoms: [String] = []
    @State private var login: Int? = nil
    @State var valueAll: Int = 0
    
    func fetchUsers() {
        
        let db = Firestore.firestore()
         
        db.collection("users").getDocuments() { (snapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            }
            else {
                for document in snapshot!.documents {
                    if (document.documentID == Auth.auth().currentUser!.uid) {
                        
                        let familyName = document.get("familyName") as! String
                        let name = document.get("name") as! String
                        
                        self.valueAll = document.get("infectedScore") as! Int
                        
                        print(familyName, name, self.valueAll)
                        
                    } } } } }
    
    var body: some View {
        VStack {
        List {
                Section(header: ListHeader()) {
                    ForEach(viewModel.sym, id: \.names) { sy in
                        MultipleSelectionRow(title: sy.names, isSelected: self.selectionsSymptoms.contains(sy.names)) {
                            if self.selectionsSymptoms.contains(sy.names) {
                                self.selectionsSymptoms.removeAll(where: { $0 == sy.names })
                            }
                            else {
                                self.selectionsSymptoms.append(sy.names)
                                self.valueAll = self.valueAll + (sy.value)
                            }
                            self.selectionsSymptoms = self.selectionsSymptoms.sorted()
                        }
                    }
                    
                }
            }
            .listStyle(GroupedListStyle())
            
            Spacer().frame(height: 15)
            
            
            NavigationLink(destination: SignUpLifestyleTypes(), tag: 1, selection: $login) {
                Button(action: {
                    let docData: [String: Any] = [ "sy": self.selectionsSymptoms, "infectedScore": self.valueAll ]
                    let db = Firestore.firestore()
                    db.collection("users").document(Auth.auth().currentUser!.uid).updateData(docData)
                    self.login = 1
                }) {
                    HStack {
                        Spacer()
                        Text("Continuă")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                }
            }
            .padding()
            .background(Color.blue)
            .cornerRadius(5)
            .padding([.leading, .trailing])
    
        }
            .navigationBarTitle("Simptome generale")
            .navigationBarBackButtonHidden(true)
        .onAppear() {
            self.viewModel.fetchData(databaseName: "symptoms")
            self.fetchUsers()
        }
    }
           
    struct ListHeader: View {
        var body: some View {
            HStack {
                Image(systemName: "ant")
                Text("Prezentați una sau mai multe simptome enumerate aici?")
            }
        }
    }

}

struct MultipleSelectionRow: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: self.action) {
            HStack {
                Text(self.title)
                if self.isSelected {
                    Spacer()
                    Image(systemName: "checkmark")
                }
            }
        }.buttonStyle(PlainButtonStyle())
    }
}

struct SignUpLifestyle: View {
    var body: some View {
        SignUpLifestyleSymptoms()
    }
}

#if DEBUG
struct SignUpLifestyle_Previews: PreviewProvider {
    static var previews: some View {
        SignUpLifestyle()
    }
}
#endif
