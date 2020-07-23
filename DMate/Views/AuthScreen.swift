//
//  SignInView.swift
//  DMate
//
//  Created by Laurențiu Boran on 18/04/2020.
//  Copyright © 2020 Weberco. All rights reserved.
//

import SwiftUI
import UIKit

struct SignInView : View {
        
        @State var email: String = ""
        @State var password: String = ""
        @State var loading = false
        @State var error = false
        @State var login: Int? = nil
        
        @EnvironmentObject var session: SessionStore
        
        func signIn () {
            loading = true
            error = false
            session.signIn(email: email, password: password) { (result, error) in
                self.loading = false
                if error != nil {
                    self.error = true
                } else {
                    
                    self.login = 1
                }
            }
        }
        
        var body: some View {
            
            VStack {
                
                Spacer()
                
                Group {
                    Image("1024")
                        .resizable()
                        .frame(width: 150, height: 150)
                        .padding()

                    Text("Bun venit!").font(.largeTitle).padding(.bottom)
                }

                Spacer()
                
                Group {
                    Divider()
                   
                    CustomInput(text: $email, name: "Email")
                        .padding()
                    
                    SecureField("Parolă", text: $password)
                        .modifier(InputModifier())
                        .padding([.leading, .trailing])

                    if (error) {
                        InlineAlert(
                            title: "Ceva nu a mers.",
                            subtitle: "Verifică email-ul și parola și încearcă din nou"
                            ).padding([.horizontal, .top])
                        
                    }
                    
                    NavigationLink (destination: ProfileView(), tag: 1, selection: $login) {
                        Button(action: signIn) {
                            HStack {
                                Spacer()
                                Text("Autentificare")
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                Spacer()
                            }
                        }
                        .disabled(loading)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(5)
                    }
                .padding()
                
                }
                
                VStack {
                    Divider()
                    HStack(alignment: .center) {
                        Text("Nu ai cont?")
                            .font(.footnote)
                            .foregroundColor(.gray)
                        
                        NavigationLink(destination: SignUpView()) {
                            Text("Înregistrează-te").font(.footnote)
                        }
                        }
                        .padding()
                }
                
            }
            .navigationBarBackButtonHidden(true)
            
        }
        
    }

struct SignUpView : View {
    
    @State var email: String = ""
    @State var password: String = ""
    @State var loading = false
    @State var error = false
    @State var login: Int? = nil
    
    @EnvironmentObject var session: SessionStore
    
    func signUp () {
        print("Înregistrează-mă")
        loading = true
        error = false
        session.signUp(email: email, password: password) { (result, error) in
            self.loading = false
            if error != nil {
                print("\(String(describing: error))")
                self.error = true
            } else {
                self.login = 1
            }
        }
    }
    
    var body : some View {
        VStack {
            
            Spacer()
            
            Text("Creează un cont")
                .font(.title)
                .padding(.horizontal)
            
            Group {
            CustomInput(text: $email, name: "Email")
                .padding()
            
            VStack(alignment: .leading) {
                SecureField("Parolă", text: $password).modifier(InputModifier())
                Text("Este nevoie de cel puțin 8 caractere valide.").font(.footnote).foregroundColor(Color.gray)
            }.padding(.horizontal)
            
            if (error) {
                InlineAlert(
                    title: "Ceva nu a mers.",
                    subtitle: "Ești sigur că ai introdus datele corecte?"
                ).padding([.horizontal, .top])
               
            }
            
            NavigationLink (destination: SignUpWelcome(), tag: 1, selection: $login) {
                Button(action: signUp) {
                    HStack {
                        Spacer()
                        Text("Înregistrează-mă")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                }
                .disabled(loading)
                .padding()
                .background(Color.blue)
                .cornerRadius(5)
            }
            .padding()
            }
            
            Divider()
            
            Text("Un cont îți va facilita accesul spre un istoric medical și un diagnostic cât mai clar. Îți poți șterge contul oricând, împreună cu toate datele personale asociate acestuia.")
                .font(.footnote)
                .foregroundColor(.gray)
                .multilineTextAlignment(.leading)
                .lineLimit(nil)
                .padding()
            
            Spacer()
            
        }
    }
    
}

struct AuthScreen : View {
    var body : some View {
            SignInView()
        .navigationBarBackButtonHidden(true)
    }
}

#if DEBUG
struct AuthScreen_Previews: PreviewProvider {
    static var previews: some View {
         AuthScreen()
                   .environmentObject(SessionStore())
    }
}
#endif
