//
//  SignUpAccountData.swift
//  DMate
//
//  Created by Laurențiu Boran on 20/04/2020.
//  Copyright © 2020 Weberco. All rights reserved.
//

import SwiftUI
import Firebase
import MapKit

extension CLLocation {
    func fetchCityAndCountry(completion: @escaping (_ city: String?, _ country:  String?, _ error: Error?) -> ()) {
        CLGeocoder().reverseGeocodeLocation(self) { completion($0?.first?.locality, $0?.first?.country, $1) }
    }
}

struct SignUpAccountData: View {
    

    // variables
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }
    
    @ObservedObject var locationManager = LocationManager()
    
    @State private var birthDate = Date()
    @State private var sex = ""
    @State private var login: Int? = nil
    @State private var name: String = ""
    @State private var familyName: String = ""
    @State private var location: String = "Locație curentă"
    @State private var locationRaw: String = ""
    @State private var showGreeting = false
    @State private var infectedScore: Int? = nil
    
    struct Sex {
        static let allSexes = [
            "Feminin",
            "Masculin",
            "Altele"
        ]
    }
    
    /**************************************/
    
    var body: some View {
        
        Group {
            
            Spacer().frame(height: 15)
            
            VStack(alignment: .leading) {
                Form {
                    TextField("Nume", text: $familyName)
                    
                    TextField("Prenume", text: $name)
                    
                    Button(action: {
                        
                        let location = CLLocation(latitude: self.locationManager.lastLocation?.coordinate.latitude ?? 0, longitude: self.locationManager.lastLocation?.coordinate.longitude ?? 0)
                        location.fetchCityAndCountry { city, country, error in
                            guard let city = city, let country = country, error == nil else { return }
                            self.location = (city + ", " + country)  // City, State
                        }
                        
                        self.locationRaw = "\(self.locationManager.lastLocation?.coordinate.latitude ?? 0), \(self.locationManager.lastLocation?.coordinate.longitude ?? 0)"
                        
                    }) {
                        HStack {
                            Text(self.location)
                            Image(systemName: "location").multilineTextAlignment(.trailing)
                        }
                    }
                    
                    Picker(selection: $sex,
                           label: Text("Sex")) {
                            ForEach(Sex.allSexes, id: \.self) { sex in
                                Text(sex).tag(sex)
                            }
                    }
                    
                    DatePicker(selection: $birthDate, in: ...Date(), displayedComponents: .date) {
                        Text("Data nașterii") }
                    
                }
            }.onAppear() {  }
            
            Spacer()
            
            Toggle(isOn: $showGreeting) { Text("Ați călătorit recent?") }.padding()
            
            NavigationLink(destination: SignUpLifestyle(), tag: 1, selection: $login) {
                Button(action: {
                    let today = Date()
                    
                    let calendar = Calendar.current
                           
                    let components = calendar.dateComponents([.year, .month, .day], from: self.birthDate, to: today)
                           
                    let ageYears = components.year
                    
                    if (self.showGreeting == true) {
                        
                        self.infectedScore = 24
                    }
                    else {
                        
                        self.infectedScore = 0
                    }
                    
                    let userData = [ "familyName": self.familyName, "name": self.name, "location": self.locationRaw, "hasTravelled": self.showGreeting, "infectedScore": self.infectedScore, "sex": self.sex, "age": ageYears as Any, "contact": "0" ]
                    
                    let docData: [String: Any] = [ "location": self.locationRaw ]
                    
                    let db = Firestore.firestore()
                    db.collection("users").document(Auth.auth().currentUser!.uid).setData(userData)
                    db.collection("locations").document(Auth.auth().currentUser!.uid).setData(docData)
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
            .navigationBarTitle("Informații generale")
            .navigationBarBackButtonHidden(true)
        }
    
}

#if DEBUG
struct SignUpAccountData_Previews: PreviewProvider {
    static var previews: some View {
        SignUpAccountData().environmentObject(SessionStore())
    }
}
#endif
