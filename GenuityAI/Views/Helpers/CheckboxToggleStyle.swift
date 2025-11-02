//
//  CheckboxToggleStyle.swift
//  Genuity AI
//
//  Custom checkbox toggle style
//

import SwiftUI

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                .font(.title2)
                .foregroundColor(configuration.isOn ? .purple : .gray)
                .onTapGesture {
                    configuration.isOn.toggle()
                }
            
            configuration.label
                .onTapGesture {
                    configuration.isOn.toggle()
                }
        }
        .contentShape(Rectangle())
    }
}

