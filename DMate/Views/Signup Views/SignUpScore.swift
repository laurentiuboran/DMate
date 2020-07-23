//
//  SignUpScore.swift
//  DMate
//
//  Created by Laurențiu Boran on 24/04/2020.
//  Copyright © 2020 Weberco. All rights reserved.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth

struct SignUpScore: View {
    
    @State var progress: CGFloat = 0.0
    @State var valueAll: Int = 0
    @State var circleText: String = ""
    @State var circleColor: Color = Color.green
    @State private var login: Int? = nil
    
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
                        self.progress = CGFloat(self.valueAll) / 24.0
                        print(self.progress)
                        
                        print(familyName, name, self.valueAll)
                        
                        if (self.valueAll >= 24)
                        {
                            self.circleColor = Color.red
                            self.circleText = "Mari"
                        }
                        else if ((self.valueAll < 24) && (self.valueAll >= 12))
                        {
                            self.circleColor = Color.yellow
                            self.circleText = "Medii"
                        }
                        else if (self.valueAll < 12)
                        {
                            self.circleColor = Color.green
                            self.circleText = "Slabe"
                        }
                        
                    } } } } }
     
     var body: some View {
         
        VStack(spacing: 20) {
            
            Spacer()
             
             ZStack {
                 Circle()
                     .stroke(Color.gray, lineWidth: 5)
                     .opacity(0.1)
                 Circle()
                     .trim(from: 0, to: progress)
                     .stroke(circleColor, lineWidth: 10)
                     .rotationEffect(.degrees(-90))
                 .overlay(
                    VStack {
                        Text("Șanse de infecție")
                        Text(self.circleText).font(.title).bold()
                    }
                )
                
             }.padding(20)
                .frame(height: 300)
             
            
            Spacer()
            
            Text("Vei fi direcționat către profil pentru mai multe informații.")
            .font(.footnote)
            .foregroundColor(.gray)
                
                NavigationLink(destination: ProfileView(), tag: 1, selection: $login) {
                    Button(action: {
                        let docData: [String: Any] = [ "infectedScore": self.circleText ]
                        let db = Firestore.firestore()
                        db.collection("locations").document(Auth.auth().currentUser!.uid).updateData(docData)
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
            
        .navigationBarTitle("Profil infecție")
        .navigationBarBackButtonHidden(true)
        .onAppear() {
            
            self.fetchUsers()
            
        }
    }
}

#if DEBUG
struct SignUpScore_Previews: PreviewProvider {
    static var previews: some View {
        SignUpScore()
    }
}
#endif
