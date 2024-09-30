//
//  ARViewContainer.swift
//  MeasureFirstApp
//
//  Created by Vivek Singh on 9/24/24.
//


import SwiftUI
import RealityKit
import ARKit

struct ARViewContainer: UIViewRepresentable {
    @Binding var estimatedHeight: String
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        // Check if body tracking is supported (LiDAR devices)
        if ARBodyTrackingConfiguration.isSupported {
            let configuration = ARBodyTrackingConfiguration()
            configuration.planeDetection = [.horizontal, .vertical]
            arView.session.run(configuration)
            arView.addCoachingOverlay(goal: .horizontalPlane)
        }
        
        context.coordinator.setupARSession(for: arView)
        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(estimatedHeight: $estimatedHeight)
    }
}

extension ARView {
    func addCoachingOverlay(goal: ARCoachingOverlayView.Goal) {
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        coachingOverlay.goal = goal
        coachingOverlay.session = self.session
        self.addSubview(coachingOverlay)
    }
}
