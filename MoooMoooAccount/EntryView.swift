//
//  EntryView.swift
//  MoooMoooAccount
//
//  Created by Hualiteq International on 2026/3/3.
//

import SwiftUI

struct EntryView: View {
    @State private var isTapped: Bool = false
    
    var body: some View {
        if isTapped {
            EntryCalendar()
        } else {
            Text("Fortune")
                .foregroundStyle(.black)
                .fontDesign(.monospaced)
                .padding(.bottom, 10)
            
            Button {
                self.isTapped = true
            } label: {
                Image("coin")
                    .resizable()
                    .frame(width: 150, height: 150)
            }
        }
    }
}
