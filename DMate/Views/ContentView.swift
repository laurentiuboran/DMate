//
//  ContentView.swift
//  DMate
//
//  Created by Laurențiu Boran on 17/04/2020.
//  Copyright © 2020 Weberco. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var session: SessionStore
    @State private var status = false
    
    func getUser() {
        
        status = session.listen()
        print(status)
     }
    
    var body: some View {
        Group {
             if (status == false) {
                NavigationView {
                    AuthScreen()
                    .navigationBarTitle("")
                    .navigationBarHidden(true)
                }
             } else {
                NavigationView {
                    ProfileView() }
             }
           }.onAppear(perform: getUser)
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(SessionStore())
    }
}
#endif


