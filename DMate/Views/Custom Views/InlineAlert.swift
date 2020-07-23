//
//  InlineAlert.swift
//  DMate
//
//  Created by Laurențiu Boran on 18/04/2020.
//  Copyright © 2020 Weberco. All rights reserved.
//

import SwiftUI

enum AlertIntent {
    case info, success, question, danger, warning
}

struct InlineAlert : View {
    
    var title: String
    var subtitle: String?
    var intent: AlertIntent = .info
    
    var body: some View {

        HStack(alignment: .top) {
               
                
            
                Image(systemName: "exclamationmark.triangle.fill")
                    .padding(.vertical)
                    .foregroundColor(Color.white)
            
                VStack(alignment: .leading) {
                    Text(self.title)
                        .font(.body)
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)

                    if (self.subtitle != nil) {
                        Text(self.subtitle!)
                            .font(.body)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                            .lineLimit(nil)

                    }

                }.padding(.leading)
            
            }
                .padding()
                .background(Color.red)
        
    }
}

#if DEBUG
struct InlineAlert_Previews : PreviewProvider {
    static var previews: some View {
        InlineAlert(
            title: "Titlu",
            subtitle: "Subtitlu",
            intent: .info
        ).frame(height: 300)
    }
}
#endif
