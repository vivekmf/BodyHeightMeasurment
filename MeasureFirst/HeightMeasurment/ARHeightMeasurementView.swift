//
//  ARHeightMeasurementView.swift
//  MeasureFirstApp
//
//  Created by Vivek Singh on 9/24/24.
//


import SwiftUI
import RealityKit
import ARKit

struct ARHeightMeasurementView: View {
    @Binding var estimatedHeight: String
    
    var body: some View {
        ZStack {
            ARViewContainer(estimatedHeight: $estimatedHeight).edgesIgnoringSafeArea(.all)
            
            // Overlay Text for displaying height
            VStack {
                Spacer()
                Text("Estimated Height: \(estimatedHeight)")
                    .font(.title3)
                    .bold()
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.green.opacity(0.7))
                    .cornerRadius(10)
                    .padding(.top)
            }
        }
    }
}
