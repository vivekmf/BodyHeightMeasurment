//
//  Coordinator.swift
//  MeasureFirstApp
//
//  Created by Vivek Singh on 9/24/24.
//

import ARKit
import SwiftUI
import RealityKit
import ARKit

class Coordinator: NSObject, ARSessionDelegate {
    @Binding var estimatedHeight: String
    var arView: ARView!
    
    init(estimatedHeight: Binding<String>) {
        self._estimatedHeight = estimatedHeight
    }
    
    func setupARSession(for arView: ARView) {
        self.arView = arView
        arView.session.delegate = self
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        for anchor in anchors {
            if let bodyAnchor = anchor as? ARBodyAnchor {
                let height = estimateHeightFromBodyAnchor(bodyAnchor)
                DispatchQueue.main.async {
                    self.estimatedHeight = "\(Int(height)) cm"
                }
                
                // Draw the indicator line
                drawHeightIndicatorLine(bodyAnchor: bodyAnchor)
            }
        }
    }
    
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
    
    func drawHeightIndicatorLine(bodyAnchor: ARBodyAnchor) {
        let skeleton = bodyAnchor.skeleton
        
        guard let headTransform = skeleton.modelTransform(for: .head),
              let feetTransform = skeleton.modelTransform(for: .rightFoot) else {
            return
        }
        
        let headPosition = simd_make_float3(headTransform.columns.3)
        let feetPosition = simd_make_float3(feetTransform.columns.3)
        
        // Create or update the line between head and feet
        let lineEntity = createLineEntity(from: feetPosition, to: headPosition)
        if let existingLine = arView.scene.findEntity(named: "HeightLine") {
            existingLine.removeFromParent()
        }
        arView.scene.addAnchor(lineEntity)
    }
    
    func createLineEntity(from start: simd_float3, to end: simd_float3) -> AnchorEntity {
        let startEntity = Entity()
        startEntity.position = start
        let endEntity = Entity()
        endEntity.position = end
        
        let lineMesh = MeshResource.generateBox(size: [0.01, lengthBetween(start: start, end: end), 0.01])
        let lineMaterial = SimpleMaterial(color: .green, isMetallic: false)
        
        let lineEntity = ModelEntity(mesh: lineMesh, materials: [lineMaterial])
        lineEntity.position = [(start.x + end.x) / 2, (start.y + end.y) / 2, (start.z + end.z) / 2]
        lineEntity.name = "HeightLine"
        
        let anchorEntity = AnchorEntity()
        anchorEntity.addChild(lineEntity)
        return anchorEntity
    }
    
    func lengthBetween(start: simd_float3, end: simd_float3) -> Float {
        return simd_distance(start, end)
    }
}
