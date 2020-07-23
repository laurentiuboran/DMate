//
//  SignUp1.swift
//  DMate
//
//  Created by Laurențiu Boran on 20/04/2020.
//  Copyright © 2020 Weberco. All rights reserved.
//

import SwiftUI

struct SignUpWelcome: View {
    var body: some View {
        VStack {
            Text("Bun venit!")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Îți vom cere câteva detalii să te asigurăm de o experiență sigură și personalizată")
                .multilineTextAlignment(.center)
                .padding()
                .lineLimit(nil)
            
            Spacer().frame(height: 15)
            
            NavigationLink(destination: SignUpAccountData()) {
                    HStack {
                        Spacer()
                        Text("Continuă")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                }
                .padding()
                .background(Color.blue)
                .cornerRadius(5)
            }
        .navigationBarBackButtonHidden(true)
        .padding(.horizontal)
            }
        }

#if DEBUG
struct SignUpWelcome_Previews: PreviewProvider {
    static var previews: some View {
        SignUpWelcome()
    }
}
#endif
