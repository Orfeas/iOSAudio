//
//  ActionButtonModifier.swift
//  iOS Audio
//
//  Created by Orfeas Iliopoulos on 27/2/21.
//

import SwiftUI

struct ActionButtonModifier: ViewModifier {
    var disable = false
    func body(content: Content) -> some View {
        content
            .frame(minWidth: 0, idealWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, minHeight: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, idealHeight: 50.0, maxHeight: 50.0, alignment: .center)
            .background(Color.blue)
            .cornerRadius(43)
            .disabled(disable)
            .opacity(disable ? 0.4 : 1.0)

    }
}
