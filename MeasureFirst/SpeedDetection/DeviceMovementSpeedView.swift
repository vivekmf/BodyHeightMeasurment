//
//  DeviceMovementSpeedView.swift
//  MeasureFirst
//
//  Created by Vivek Singh on 9/30/24.
//

import Foundation
import SwiftUI
import ARKit
import RealityKit
import Combine

struct DeviceMovementSpeedView: UIViewRepresentable {
    func makeUIView(context: Context) -> ARSCNView {
        let arView = ARSCNView(frame: .zero)
        arView.delegate = context.coordinator
        arView.session.delegate = context.coordinator
        
        // Configure the AR session to use LiDAR
        let configuration = ARWorldTrackingConfiguration()
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            configuration.sceneReconstruction = .mesh
        }
        arView.session.run(configuration)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {}
    
    func makeCoordinator() -> LiDARCoordinator {
        return LiDARCoordinator(self)
    }
}

class LiDARCoordinator: NSObject, ARSCNViewDelegate, ARSessionDelegate {
    var parent: DeviceMovementSpeedView
    var previousPosition: SIMD3<Float>?
    var previousTime: TimeInterval?
    
    var speedSubject = PassthroughSubject<Double, Never>()
    
    init(_ parent: DeviceMovementSpeedView) {
        self.parent = parent
        super.init()
    }
    
    // Called when the session detects new AR anchors (including LiDAR data)
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        guard let frame = session.currentFrame else { return }
        
        let currentPosition = frame.camera.transform.translation
        let currentTime = frame.timestamp
        
        if let previousPosition = previousPosition, let previousTime = previousTime {
            let deltaX = currentPosition.x - previousPosition.x
            let deltaY = currentPosition.y - previousPosition.y
            let deltaZ = currentPosition.z - previousPosition.z
            
            let distance = sqrt(deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ)
            let timeElapsed = currentTime - previousTime
            
            let speedInMetersPerSecond = distance / Float(timeElapsed)
            let speedInKmh = speedInMetersPerSecond * 3.6
            
            if speedInKmh > 0.1 { // Speed threshold to avoid noise
                speedSubject.send(Double(speedInKmh))
            }
        }
        
        previousPosition = currentPosition
        previousTime = currentTime
    }
}

extension matrix_float4x4 {
    var translation: SIMD3<Float> {
        return SIMD3(columns.3.x, columns.3.y, columns.3.z)
    }
}
