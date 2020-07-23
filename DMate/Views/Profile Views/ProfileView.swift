//
//  ProfileView.swift
//  DMate
//
//  Created by Laurențiu Boran on 26/04/2020.
//  Copyright © 2020 Weberco. All rights reserved.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth
import EventKit
import MessageUI

extension StringProtocol {
    func index<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.lowerBound
    }
    func endIndex<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.upperBound
    }
    func indices<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Index] {
        var indices: [Index] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
            let range = self[startIndex...]
                .range(of: string, options: options) {
                indices.append(range.lowerBound)
                startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return indices
    }
    func ranges<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
            let range = self[startIndex...]
                .range(of: string, options: options) {
                result.append(range)
                startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
}

struct ProfileView: View {
    
    @State var userName: String = "Salut"
    @State var status: Int? = 1
    @State var contactsStatus: Int? = 0
    @State private var showingAlert = false
    @State private var showingReminderSuccess = false
    @State private var showingDMInfo = false
    @State var valueAll: Int = 0
    @State var infectionTitleString: String = ""
    @State var infectionDescString: String = ""
    @State var infectionColor: Color = .red
    
    @State var nameProfile: String = ""
    @State var ageProfile: Int = 0
    @State var syProfile: String = ""
    @State var lstyProfile: String = ""
    @State var precondProfile: String = ""
    
    @State var eventStore = EKEventStore()
    
    @State var contactName: String = ""
    @State var phoneNumber: String = ""
    
    private let mailComposeDelegate = MailDelegate()
    private let messageComposeDelegate = MessageDelegate()
    
    @State var messageText: String = ""
    @State var messageSubject: String = ""
    
    @State private var updateProfile: Int? = nil
    @State private var mapView: Int? = nil
    
    @State private var coronaDayStats: String = "0"
    
    func signOut() {
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
        } catch let signOutError as NSError {
          print ("Error signing out: %@", signOutError)
        }
        status = 0
    }
    
    func getString(array : [String]) -> String {
        let stringArray = array.map{ String($0) }
        return stringArray.joined(separator: ", ")
    }
    
    func AddReminder() {
        
        let reminder = EKReminder(eventStore: eventStore)
        
        eventStore.requestAccess(to: .reminder) { (granted, error) in
        if let error = error {
           print(error)
           return
        }
        if granted {
        
            reminder.title = "Ieșire din carantină/autoizolare"
            reminder.calendar = self.eventStore.defaultCalendarForNewReminders()
            
            let date = Date()
            let calendar = Calendar.current
            var tomorrow: Date? = nil
            
            tomorrow = calendar.date(byAdding: .day, value: 14, to: date)
            
            let alarm = EKAlarm(absoluteDate: tomorrow!)
            reminder.addAlarm(alarm)

            do{
                try self.eventStore.save(reminder, commit: true)
                self.showingReminderSuccess = true
                
            } catch let error {
                 print("Reminder failed with error \(error.localizedDescription)") }
            }
        }

    }
    
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
                    let age = document.get("age") as! Int
                    let sex = document.get("sex") as! String
                    let sy = document.get("sy") as! [String]
                    let lsty = document.get("lsty") as! [String]
                    let precond = document.get("precond") as! [String]
                    self.phoneNumber = document.get("contact") as! String
                    self.contactName = document.get("contactName") as! String
                    
                    //Profile tab info
                    
                    self.nameProfile = familyName + " " + name
                    self.ageProfile = age
                    self.syProfile = self.getString(array: sy)
                    self.lstyProfile = self.getString(array: lsty)
                    self.precondProfile = self.getString(array: precond)
                    
                    // Infection Dialog Box
                    
                    if (self.valueAll >= 24)
                    {
                        self.infectionTitleString = "Posibilitate crescută"
                        self.infectionDescString = "Datorită unei posibilități crescute de infecție, vă recomandăm apelare numărului național de urgență, vizita imediată a unui cadru medical și trecerea la o stare de carantinare sau autoizolare. În acest timp, recomandăm evitarea completă a contactului cu alte persoane sau cu obiecte sau spații frecventate de alți oameni."
                        self.infectionColor = .red
                    }
                    else if ((self.valueAll < 24) && (self.valueAll >= 12))
                    {
                        self.infectionTitleString = "Posibilitate medie"
                        self.infectionDescString = "Datorită unei posibilități medii de infecție, vă recomandăm autoizolare imediată pe o perioadă de 14 zile și consultarea unui cadru medical specializat. Pentru o ușurare a completării stării de izolare, vă recomandăm să setați un mementou din tab-ul de Utilitare."
                        self.infectionColor = .yellow
                    }
                    else if (self.valueAll < 12)
                    {
                        self.infectionTitleString = "Posibilitate slabă"
                        self.infectionDescString = "Datorită unei posibilități slabe de infecție, vă recomandăm adoptarea unui comportament precaut și de respectare a legilor de prevenție a COVID-19 impuse de guvern. Totodată, vă recomandăm consultarea utilitarelor prezente de informare din tab-urile de Acasă și Utilitare."
                        self.infectionColor = .green
                    }
                    
                    // Message/Mail Text
                    let newSy = self.getString(array: sy)
                    print(newSy)
                    let newLsty = self.getString(array: lsty)
                    print(newLsty)
                    let newPrecond = self.getString(array: precond)
                    print(newPrecond)
                    
                    self.messageText = "Nume și prenume: " + familyName + ", "
                    self.messageText = self.messageText + name
                    self.messageText = self.messageText + "\nVârstă: " + String(age)
                    self.messageText = self.messageText + "\nSex: " + sex
                    self.messageText = self.messageText + "\nSimptome: " + newSy
                    self.messageText = self.messageText + "\nDetalii stil de viață: " + newLsty
                    self.messageText = self.messageText + "\nBoli preexistente: " + newPrecond
                    self.messageText = self.messageText + "\n\nGrad posibil de infectare: " + self.infectionTitleString + "\n\nAcest profil a fost generat automat cu aplicația DMate Corona pentru diagnosticul preliminar al virusului COVID-19."
                    print(self.messageText)
                    
                    let subjectUser = "Profil COVID-19 " + familyName + " " + name
                    self.messageSubject = subjectUser
                    
                    let titleUser = "Salut, " + name
                    self.userName = titleUser
                    
                    print(self.valueAll)
                    print(familyName, name)
                    
                } } } } }
    
    func getStats() {
        
        let date = Date()
        let calendar = Calendar.current
        
        var yesterday: Date? = nil
        
        yesterday = calendar.date(byAdding: .day, value: -1, to: date)
        
        var urlString = "https://api.covid19api.com/total/country/romania/status/confirmed?from=" + String(calendar.component(.year, from: date))
        urlString = urlString + "-0" + String(calendar.component(.month, from: date))
        urlString = urlString + "-" + String(calendar.component(.day, from: yesterday!))
        urlString = urlString + "T00:00:00Z&to="
        urlString = urlString + String(calendar.component(.year, from: date))
        urlString = urlString + "-0" + String(calendar.component(.month, from: date))
        urlString = urlString + "-" + String(calendar.component(.day, from: date))
        urlString = urlString + "T00:00:00Z"
        
        print(urlString)
        
        guard let url = URL(string: urlString)
        else
        {
            return
        }

        let request = URLRequest(url: url)

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else { print(error!.localizedDescription); return }
            guard let data = data else { print("Empty data"); return }

            if var str = String(data: data, encoding: .utf8) {
                print(str)
                
                if let range = str.range(of: "Cases") {
                    
                    let casesPlus = str[range.upperBound...]
                    print(casesPlus)
                    
                    let start = str.index(range.upperBound, offsetBy: 2)
                    let end = str.index(str.endIndex, offsetBy: -54)
                    let range = start..<end
                    
                    self.coronaDayStats = String(str[range])
                }
                
                print(self.coronaDayStats)
            }
        }.resume()
        
    }
    
    var body: some View {
        
            VStack(alignment: .leading) {

                HStack {
                    
                    Spacer()
                    
                    Button(action: { self.showingAlert = true })
                    {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(self.infectionColor)
                        Text("Status infectare")
                            .font(.body)
                            .fontWeight(.bold)
                            .foregroundColor(self.infectionColor)
                    }
                    .alert(isPresented: $showingAlert) {
                        Alert(title: Text(self.infectionTitleString), message: Text(self.infectionDescString), dismissButton: .default(Text("Am înțeles")))
                    }
                    
                }
                .padding(.trailing)
                
                Divider()
                
                Spacer()
                
                TabView {
                    
                    VStack {
                    
                        Text(self.coronaDayStats)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                            .padding(.top)
                        Text("Cazuri în România")
                            .padding(.bottom)
                        
                        Divider()
                        
                        Group {
                        
                            HStack {
                                
                                Image(systemName: "envelope.badge").foregroundColor(.blue)
                                
                                Button(action: { UIApplication.shared.open(NSURL(string: "http://stirioficiale.ro")! as URL) })
                                { Text("Accesează ultimele știri oficiale") }
                                
                            }
                            .padding(.all)
                            
                            HStack {
                                
                                Image(systemName: "bandage").foregroundColor(.blue)
                                
                                Button(action: { UIApplication.shared.open(NSURL(string: "http://cetrebuiesafac.ro/")! as URL) })
                                { Text("Reguli și întrebări frecvente") }
                                
                            }
                            .padding([.leading, .bottom, .trailing])
                            
                            HStack {
                                
                                Image(systemName: "xmark.shield").foregroundColor(.blue)
                                
                                Button(action: { UIApplication.shared.open(NSURL(string: "http://www.ms.ro/recomandari-privind-conduita-sociala-responsabila-in-prevenirea-raspandirii-coronavirus-covid-19/")! as URL) })
                                { Text("Recomandări privind conduita socială") }
                                
                            }
                            .padding([.leading, .bottom, .trailing])
                            
                            HStack {
                                
                                Image(systemName: "xmark.shield").foregroundColor(.blue)
                                
                                Button(action: { UIApplication.shared.open(NSURL(string: "http://cnscbt.ro/index.php/liste-zone-afectate-covid-19")! as URL) })
                                { Text("Liste zone afectate de virus") }
                                
                            }
                            .padding([.leading, .bottom, .trailing])
                            
                            HStack {
                                
                                Image(systemName: "phone").foregroundColor(.blue)
                                
                                Button(action: {
                                    
                                    let string = "0800800358"

                                    let tel = "tel://"
                                    let formattedString = tel + string
                                    let url: NSURL = URL(string: formattedString)! as NSURL

                                    UIApplication.shared.open(url as URL)
                                    
                                })
                                { Text("Apelează telverde informativ") }
                                
                            }
                            .padding([.leading, .bottom, .trailing])
                            
                        }
                        
                        Divider()
                        
                        Group {
                                
                                 Button(action: { self.showingDMInfo = true }) {
                                                                   
                                                                   
                                    HStack {
                                                                       
                                        Image("1024")
                                        .resizable()
                                        .renderingMode(Image.TemplateRenderingMode?.init(Image.TemplateRenderingMode.original))
                                        .frame(width: 70, height: 70)
                                                                       
                                        Text("Corona")
                                        .font(.largeTitle)
                                        .fontWeight(.light)
                                                                       
                                        }
                                                                   
                                        }
                                        .alert(isPresented: $showingDMInfo) {
                                        Alert(title: Text("Despre noi"), message: Text("Companionul tău pentru prevenția și vindecarea noului COVID-19. Suntem aici să te ajutăm într-o informare corectă și eficientă în situația unei posibile infecții, printr-o interfață de utilizator minimalistă și simplu de folosit.\n\nMulțumim că aveți încredere în noi!\nEchipa DMate"), dismissButton: .default(Text("OK")))
                                                               }.padding()
                            
                        }.padding(.top)
                        
                        Text("Datele oferite au caracter pur informativ.")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                            .multilineTextAlignment(.center)
                            .lineLimit(nil)
                            .padding(.all)
                        
                        Spacer()
                        
                    }
                        .tabItem {
                            Image(systemName: "house.fill")
                            Text("Acasă")
                        }
                    
                    VStack {
                        
                        HStack {
                            
                            Image(systemName: "memories.badge.plus").foregroundColor(.blue)
                        
                            Button(action: AddReminder) { Text("Adaugă memento pentru 14 zile") }
                            .alert(isPresented: $showingReminderSuccess) {
                                Alert(title: Text("Memento adăugat cu succes"), message: Text("Te vom anunța când este mai sigur să părăsești starea de carantină/autoizolare"), dismissButton: .default(Text("Am înțeles")))
                            }
                            
                        }
                        .padding([.leading, .bottom, .trailing])
                        
                        HStack {
                            
                            Image(systemName: "map").foregroundColor(.blue)
                        
                            Button(action: { UIApplication.shared.open(NSURL(string: "http://maps.apple.com/?q=Farmacie")! as URL) })
                            { Text("Caută farmacii în apropiere") }
                            
                        }
                        .padding([.leading, .bottom, .trailing])
                        
                        HStack {
                            
                            Image(systemName: "envelope").foregroundColor(.blue)
                            
                            Button(action: {
                                self.presentMailCompose()
                            }) {
                                Text("Trimite profilul prin email")
                            }
                            
                        }
                        .padding([.leading, .bottom, .trailing])
                        
                        HStack {
                            
                            Image(systemName: "message").foregroundColor(.blue)
                            
                            Button(action: {
                                self.presentMessageCompose()
                            }) {
                                Text("Trimite profilul prin mesaj")
                            }
                        }
                        .padding([.leading, .bottom, .trailing])
                        
                        Group {
                        
                            HStack {
                                
                                Image(systemName: "questionmark.circle").foregroundColor(.blue)
                                
                                Button(action: {
                                    self.presentSuggestionMailCompose()
                                }) {
                                    Text("Ai propuneri pentru aplicație?")
                                }
                            }
                            .padding([.leading, .bottom, .trailing])
                            
                            Divider()
                                
                                VStack {
                                    
                                    HStack {
                                        
                                        Image(systemName: "map").foregroundColor(.blue)
                                    
                                        Button(action: { UIApplication.shared.open(NSURL(string: "http://maps.apple.com/?q=Spitale")! as URL) })
                                        { Text("Caută spitale în apropiere") }
                                        
                                    }
                                    .padding([.leading, .bottom, .trailing])
                                    
                                    HStack {
                                    
                                        Image(systemName: "mappin.circle.fill").foregroundColor(.blue)
                                        
                                        NavigationLink(destination: MapView(), tag: 1, selection: $mapView) {
                                            Button(action: {
                                                
                                                self.mapView = 1
                                                
                                            })
                                            {
                                                Text("Vezi hartă status utilizatori")
                                            }
                                        }
                                        
                                        }
                                        .padding([.leading, .bottom, .trailing])
                                
                                    HStack {
                                    
                                        Image(systemName: "phone").foregroundColor(.blue)
                                        
                                        Button(action: {
                                            
                                                let string = "112"

                                                let tel = "tel://"
                                                let formattedString = tel + string
                                                let url: NSURL = URL(string: formattedString)! as NSURL

                                                UIApplication.shared.open(url as URL)

                                            }) { Text("Apel de urgență") }
                                        }
                                    .padding(.horizontal)
                                    
                                }.padding()
                                
                            
                        }
                        
                        Spacer()
                        
                        //Divider()
                        
                        Group {
                        
                        NavigationLink (destination: AuthScreen(), tag: 0, selection: $status) {
                            Button(action: signOut) {Text("Deconectare")}
                            
                        }
                        .padding(.top)
                        
                        Text("DMate Corona 1.0 • Creat cu ♥️ în Timișoara")
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .padding(.bottom)
                        }
                        
                    }
                    .padding(.top)
                        .tabItem {
                            Image(systemName: "heart.circle.fill")
                            Text("Utilitare")
                        }
                    
                    VStack {
                        
                        Group {
                        
                        HStack {
                            Text("Nume și prenume")
                                .font(.headline)
                                .fontWeight(.thin)
                            
                            Spacer()
                        }.padding(.top)
                        
                        HStack {
                            Text(self.nameProfile)
                                .font(.title)
                            
                            Spacer()
                        }
                        .padding(.bottom)
                        
                        HStack {
                            Text("Vârstă")
                                .font(.headline)
                                .fontWeight(.thin)
                            
                            Spacer()
                        }
                        
                        HStack {
                            Text(String(self.ageProfile))
                                .font(.title)
                            
                            Spacer()
                        }
                            
                        Divider()
                        
                        HStack {
                            Text("Simptome")
                                .font(.headline)
                                .fontWeight(.thin)
                            
                            Spacer()
                        }.padding(.top)
                        
                        HStack {
                            Text(self.syProfile)
                                .font(.headline)
                            
                            Spacer()
                        }.padding(.bottom)
                        
                        HStack {
                            Text("Detalii stil de viață")
                                .font(.headline)
                                .fontWeight(.thin)
                            
                            Spacer()
                        }
                        
                        HStack {
                            Text(self.lstyProfile)
                                .font(.headline)
                            
                            Spacer()
                        }.padding(.bottom)
                            
                            Group {
                        
                                HStack {
                                    Text("Boli preexistente")
                                        .font(.headline)
                                        .fontWeight(.thin)
                                    
                                    Spacer()
                                }
                                
                                HStack {
                                    Text(self.precondProfile)
                                        .font(.headline)
                                    
                                    Spacer()
                                }
                            }
                        }
                        .padding(.leading)
                        
                        Spacer()
                        
                        Divider()
                        
                        VStack {
                        
                        NavigationLink(destination: SignUpLifestyle(), tag: 1, selection: $updateProfile) {
                            Button(action: {
                                
                                let docData: [String: Any] = [ "infectedScore": 0 ]
                                let db = Firestore.firestore()
                                db.collection("users").document(Auth.auth().currentUser!.uid).updateData(docData)
                                
                                self.updateProfile = 1
                                
                            })
                            {
                                HStack {
                                    Spacer()
                                    Text("Actualizează-ți profilul")
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                    Spacer()
                                }
                            }
                        }
                        .padding(.all)
                        .background(Color.blue)
                        .cornerRadius(5)
                        .padding([.top, .horizontal])
                            
                            
                                Button(action: {
                                    
                                    let string = self.phoneNumber

                                    let tel = "tel://"
                                    let formattedString = tel + string
                                    let url: NSURL = URL(string: formattedString)! as NSURL

                                    UIApplication.shared.open(url as URL)

                                }) {
                                    HStack {
                                        Spacer()
                                        Text("Contact de urgență: " + self.contactName)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                            .multilineTextAlignment(.center)
                                        Spacer()
                                    }
                                    
                                }
                            .padding(.all)
                            .background(Color.red)
                            .cornerRadius(5)
                            .padding(.all)
                        }
                        
                    }
                    
                        .tabItem {
                            Image(systemName: "person.circle.fill")
                            Text("Profil")
                        }
                }
                .font(.headline)
                
            }
            .navigationBarTitle(self.userName)
            .navigationBarHidden(false)
            .navigationBarBackButtonHidden(true)
            .onAppear() {
                self.fetchUsers()
            }
        .onAppear() { self.getStats()
        }
    }
    
}

extension ProfileView {
    
    private class MailDelegate: NSObject, MFMailComposeViewControllerDelegate {

        func mailComposeController(_ controller: MFMailComposeViewController,
                                   didFinishWith result: MFMailComposeResult,
                                   error: Error?) {
            
            controller.dismiss(animated: true)
        }

    }

    private func presentMailCompose() {
        guard MFMailComposeViewController.canSendMail() else {
            return
        }
        let vc = UIApplication.shared.keyWindow?.rootViewController

        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = mailComposeDelegate

        composeVC.setSubject(self.messageSubject)
        composeVC.setMessageBody(self.messageText, isHTML: false)

        vc?.present(composeVC, animated: true)
    }
    
    private func presentSuggestionMailCompose() {
        guard MFMailComposeViewController.canSendMail() else {
            return
        }
        let vc = UIApplication.shared.keyWindow?.rootViewController

        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = mailComposeDelegate

        composeVC.setSubject("Propuneri aplicație DMate Corona")
        composeVC.setToRecipients(["laurentiuboran@yahoo.com"])

        vc?.present(composeVC, animated: true)
    }
}

extension ProfileView {

    private class MessageDelegate: NSObject, MFMessageComposeViewControllerDelegate {
        func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
            
            controller.dismiss(animated: true)
        }

    }

    private func presentMessageCompose() {
        guard MFMessageComposeViewController.canSendText() else {
            return
        }
        let vc = UIApplication.shared.keyWindow?.rootViewController

        let composeVC = MFMessageComposeViewController()
        composeVC.messageComposeDelegate = messageComposeDelegate

        composeVC.body = "Profil diagnostic COVID-19\n\n" + self.messageText
        

        vc?.present(composeVC, animated: true)
    }
}

#if DEBUG
struct ProfileView_Previews : PreviewProvider {
    static var previews: some View {
            ProfileView()
    }
}
#endif
