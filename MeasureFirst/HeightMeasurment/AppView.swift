//
//  AppView.swift
//  MeasureFirstApp
//
//  Created by Vivek Singh on 9/24/24.
//

import SwiftUI
import ARKit
import AVFoundation
import Vision

struct AppView: View {
    @State private var estimatedHeight: String = "0.00"
    
    var body: some View {
        if ARBodyTrackingConfiguration.isSupported {
            // Use ARKit for LiDAR devices
            ARHeightMeasurementView(estimatedHeight: $estimatedHeight)
        } else {
            // Use Vision-based approach for non-LiDAR devices
            VisionHeightMeasurementView(estimatedHeight: $estimatedHeight)
        }
    }
}
