//
//  SignUpContact.swift
//  DMate
//
//  Created by Laurențiu Boran on 10/06/2020.
//  Copyright © 2020 Weberco. All rights reserved.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth

struct SignUpContact: View {
    
    @State private var name: String = ""
    @State private var phoneNumber: String = ""
    @State private var login: Int? = nil
     
     var body: some View {
        
        VStack {
            
            Text("Ai un număr de telefon de urgențe oferit de un cadru medical specializat sau al unei persoane ce vă poartă de grijă? Partajați-l cu noi pentru un acces rapid în apelarea acestuia, în caz de orice fel de situație de urgență medicală.")
                .lineLimit(nil).padding()
            
            TextField("Nume și prenume", text: $name).padding()
            
            TextField("Număr de telefon", text: $phoneNumber).padding()
            
            Spacer()
            
            Divider()
            
            Text("Din motive de securitate a datelor, veți putea adăuga acest număr o singură dată, acesta fiind salvat la profilul dvs. permanent!")
                .fontWeight(.bold)
                .foregroundColor(Color.red)
                .multilineTextAlignment(.center)
                .lineLimit(nil).padding()
        
            NavigationLink(destination: SignUpScore(), tag: 1, selection: $login) {
                Button(action: {
                    let docData: [String: Any] = [ "contact": self.phoneNumber, "contactName": self.name]
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
        .navigationBarTitle("Contact de urgență")
        .navigationBarBackButtonHidden(true)
        
    }
        
}

#if DEBUG
struct SignUpContact_Previews: PreviewProvider {
    static var previews: some View {
        SignUpContact()
    }
}
#endif
