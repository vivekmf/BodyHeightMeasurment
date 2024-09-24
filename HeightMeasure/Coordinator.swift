//
//  Coordinator.swift
//  HeightMeasure
//
//  Created by Vivek Singh on 9/24/24.
//


import ARKit
import SwiftUI
import ARKit
import RealityKit

class Coordinator: NSObject, ARSessionDelegate {
    @Binding var estimatedHeight: String
    
    init(estimatedHeight: Binding<String>) {
        self._estimatedHeight = estimatedHeight
    }
    
    func setupARSession(for arView: ARView) {
        arView.session.delegate = self
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        for anchor in anchors {
            if let bodyAnchor = anchor as? ARBodyAnchor {
                let height = estimateHeightFromBodyAnchor(bodyAnchor)
                DispatchQueue.main.async {
                    self.estimatedHeight = "\(Int(height)) cm"
                }
            }
        }
    }
    
    // Helper to estimate height from ARBodyAnchor
    func estimateHeightFromBodyAnchor(_ bodyAnchor: ARBodyAnchor) -> CGFloat {
        let skeleton = bodyAnchor.skeleton
        
        guard let headTransform = skeleton.modelTransform(for: .head),
              let feetTransform = skeleton.modelTransform(for: .rightFoot) else {
            return 0.0
        }
        
        let headPosition = headTransform.columns.3
        let feetPosition = feetTransform.columns.3
        
        let heightInMeters = abs(headPosition.y - feetPosition.y)
        return CGFloat(heightInMeters * 100)
    }
}
