//
//  LiDARSpeedDetectionView.swift
//  MeasureFirst
//
//  Created by Vivek Singh on 10/7/24.
//

import Foundation
import SwiftUI
import ARKit
import RealityKit

struct LiDARSpeedDetectionView: UIViewRepresentable {
    
    class Coordinator: NSObject, ARSessionDelegate {
        var lastPosition: SIMD3<Float>? = nil
        var lastUpdateTime: TimeInterval = 0.0
        
        // Session delegate callback
        func session(_ session: ARSession, didUpdate frame: ARFrame) {
            guard let sceneDepth = frame.sceneDepth else { return }
            let currentTime = frame.timestamp
            
            let depthMap = sceneDepth.depthMap
            let width = CVPixelBufferGetWidth(depthMap)
            let height = CVPixelBufferGetHeight(depthMap)
            
            let centerPixel = CGPoint(x: width / 2, y: height / 2)
            
            // Lock the base address of the depth map
            CVPixelBufferLockBaseAddress(depthMap, .readOnly)
            
            defer {
                // Unlock the base address of the depth map after accessing
                CVPixelBufferUnlockBaseAddress(depthMap, .readOnly)
            }
            
            // Access the depth data
            let baseAddress = CVPixelBufferGetBaseAddress(depthMap)
            let bytesPerRow = CVPixelBufferGetBytesPerRow(depthMap)
            let offset = Int(centerPixel.y) * bytesPerRow + Int(centerPixel.x) * MemoryLayout<Float32>.size
            
            // Get the depth value at the center of the frame
            let depthValue = baseAddress?.assumingMemoryBound(to: Float32.self).advanced(by: offset).pointee
            print("Depth at center pixel: \(depthValue ?? 0) meters")
            
            // Get the 3D feature points (for more accurate positioning)
            let pointCloud = frame.rawFeaturePoints?.points ?? []
            
            if let closestPoint = pointCloud.min(by: { $0.z < $1.z }) {
                let currentPosition = closestPoint
                
                if let lastPosition = lastPosition {
                    let distance = simd_distance(lastPosition, currentPosition)
                    let timeDelta = currentTime - lastUpdateTime
                    let speed = distance / Float(timeDelta)
                    
                    print("Speed: \(speed) meters/second")
                }
                
                lastPosition = currentPosition
                lastUpdateTime = currentTime
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        arView.setupForLiDARSpeedDetection(context: context)
        
        // Adding rounded corners and a shadow for aesthetics
        arView.layer.cornerRadius = 20
        arView.layer.shadowColor = UIColor.black.cgColor
        arView.layer.shadowOpacity = 0.7
        arView.layer.shadowOffset = CGSize(width: 4, height: 4)
        arView.layer.shadowRadius = 10
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        // Check if ARSession is running and update configuration if needed
        if let currentConfiguration = uiView.session.configuration as? ARWorldTrackingConfiguration {
            if currentConfiguration.sceneReconstruction != .mesh {
                currentConfiguration.sceneReconstruction = .mesh
                uiView.session.run(currentConfiguration, options: [.resetTracking, .removeExistingAnchors])
            }
        }
    }
}

extension ARView {
    // Setup method for AR session
    func setupForLiDARSpeedDetection(context: LiDARSpeedDetectionView.Context) {
        let configuration = ARWorldTrackingConfiguration()
        configuration.sceneReconstruction = .mesh
        configuration.frameSemantics = [.sceneDepth]
        self.session.run(configuration)
        self.session.delegate = context.coordinator
        
        // Add a semi-transparent overlay to make the view more interactive
        let overlay = UIView(frame: self.bounds)
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        overlay.layer.cornerRadius = 20
        overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(overlay)
        
        // Adding an informational label for the speed
        let speedLabel = UILabel()
        speedLabel.text = "Speed Detection Active"
        speedLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        speedLabel.textColor = .white
        speedLabel.translatesAutoresizingMaskIntoConstraints = false
        overlay.addSubview(speedLabel)
        
        NSLayoutConstraint.activate([
            speedLabel.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            speedLabel.topAnchor.constraint(equalTo: overlay.safeAreaLayoutGuide.topAnchor, constant: 20)
        ])
    }
}

struct SpeedDetectionLiDARView: View {
    var body: some View {
        ZStack {
            LiDARSpeedDetectionView()
                .edgesIgnoringSafeArea(.all)
                .background(LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.black]),
                    startPoint: .top,
                    endPoint: .bottom))
            
            VStack {
                Spacer()
                Text("Speed Detection")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.bottom, 50)
            }
        }
    }
}
