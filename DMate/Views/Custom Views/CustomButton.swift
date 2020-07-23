//
//  CustomButton.swift
//  DMate
//
//  Created by Laurențiu Boran on 18/04/2020.
//  Copyright © 2020 Weberco. All rights reserved.
//

import SwiftUI

struct CustomButton : View {
    var label: String
    var action: () -> Void
    var loading: Bool = false
    
    
    var body: some View {
        
        Button(action: action) {
            HStack {
                Spacer()
                Text(label)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                Spacer()
            }
            
            }
            .padding()
            .background(loading ? Color.blue.opacity(0.3) : Color.blue)
            .cornerRadius(5)
    }
}

#if DEBUG
struct CustomButton_Previews : PreviewProvider {
    static var previews: some View {
        CustomButton(label: "Autentificare", action: {
            print("salut")
        })
    }
}
#endif
