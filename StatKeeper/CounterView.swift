//
//  CounterView.swift
//  StatKeeper
//
//  Created by Kenny Gruchalla on 4/27/26.
//
import SwiftUI
import AudioToolbox
internal import Combine

/// A labeled counter with decrement and increment controls.
///
/// Displays a title, current value, a MinusButton for decrementing, and a colored
/// circular “+” button for incrementing. Haptic/sound feedback is provided on change.
///
/// - Parameters:
///   - label: Display name shown above the counter.
///   - color: Accent color used for the “+” button and background tint.
///   - value: A binding to the integer being modified.
struct CounterView: View {
    let label: String
    let color: Color
    @Binding var value: Int
    
    var body: some View {
        VStack {
            HStack{
                Text(label).font(.footnote)
                Spacer()
            }
            .padding(.bottom, 1)
            
            HStack {
                MinusButton(action: {
                    value -= value == 0 ? 0 : 1
                    Feedback.deleteWithSound()
                })
                
                Spacer()
                Text(value, format: .number).bold()
                Spacer()
                
                Button(action: {
                    value += 1
                    Feedback.tapWithSound()
                }){
                    Text("+")
                        .frame(width: 35, height: 35)
                        .background(color)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
                .accessibilityLabel(Text("Increment \(label)"))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black, lineWidth: 1)
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text(label))
        .accessibilityValue(Text("\(value)"))
    }
}
