//
//  VisionHeightMeasurementView.swift
//  MeasureFirstApp
//
//  Created by Vivek Singh on 9/24/24.
//


import SwiftUI
import AVFoundation
import Vision

struct VisionHeightMeasurementView: UIViewControllerRepresentable {
    @Binding var estimatedHeight: String
    
    func makeUIViewController(context: Context) -> VisionHeightMeasurementController {
        let controller = VisionHeightMeasurementController()
        controller.estimatedHeight = $estimatedHeight
        return controller
    }
    
    func updateUIViewController(_ uiViewController: VisionHeightMeasurementController, context: Context) {}
}
