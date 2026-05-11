//
//  MinusButton.swift
//  StatKeeper
//
//  Created by Kenny Gruchalla on 4/27/26.
//
import SwiftUI

/// A minimalist circular “−” button used for decrement actions.
struct MinusButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("-")
                .frame(width: 30, height: 30)
                .foregroundColor(Color(.label))
                .background(.ultraThinMaterial, in: Circle())
                .background {
                        Circle().fill(Color(.label).opacity(0.1))
                }
                .overlay {
                    // Adds the 3D "rim" highlight
                    Circle()
                        .stroke(.white.opacity(0.2), lineWidth: 0.5)
                    Circle()
                        .stroke(Color(.label).opacity(0.2), lineWidth: 4)
                        .blur(radius: 4)
                        .offset(x: 2, y: 2)
                        .mask(Circle())
                }
                .shadow(color: Color(.label).opacity(0.1), radius: 2, x: 0, y: 2)

                //.clipShape(Circle())
                // Soft stroke with blur to give a slightly embossed ring.
                //.overlay(
                //    Circle()
                //        .stroke(Color(.label).opacity(0.2), lineWidth: 4)
                //        .blur(radius: 4)
                //        .offset(x: 2, y: 2)
                //        .mask(Circle())
                //)
        }
        .accessibilityLabel(Text("Decrement"))
    }
}
