//
//  CustomInput.swift
//  DMate
//
//  Created by Laurențiu Boran on 18/04/2020.
//  Copyright © 2020 Weberco. All rights reserved.
//

import SwiftUI

struct InputModifier : ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .padding()
            .border(Color(UIColor.systemGray), width: 1)
            .keyboardType(UIKeyboardType.emailAddress)
            .autocapitalization(.none)
    }
}


struct CustomInput : View {
    @Binding var text: String
    var name: String
    
    var body: some View {
        TextField(name, text: $text)
            .modifier(InputModifier())
        
    }
}

#if DEBUG
struct CustomInput_Previews : PreviewProvider {
    
    static var previews: some View {
        CustomInput(text: .constant(""), name: "Nume")
            .padding()
    }
}
#endif
