//
//  CounterView.swift
//  StatKeeper
//
//  Created by Kenny Gruchalla on 4/27/26.
//
import SwiftUI
import AudioToolbox
internal import Combine

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
                    playSystemClick()
                })
                
                Spacer()
                Text(value, format: .number).bold()
                Spacer()
                
                Button(action: {
                    value += 1
                    playSystemClick()
                }){
                    Text("+")
                        .frame(width: 35, height: 35)
                        .background(color)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
                
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
    }
}
