//
//  SpeedDetectionViewModel.swift
//  MeasureFirstApp
//
//  Created by Vivek Singh on 9/25/24.
//

import Foundation
import SwiftUI
import AVFoundation
import Combine
import Vision
import CoreGraphics
import ARKit

class SpeedDetectionViewModel: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    @Published var detectedSpeed: Double?
    @Published var usesLiDAR: Bool = false
    private var speedModel = SpeedModel()
    
    private let session = AVCaptureSession()
    private let output = AVCaptureVideoDataOutput()
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    override init() {
        super.init()
        checkDeviceCapabilities()
        setupCamera()
    }
    
    // Check if the device supports LiDAR
    func checkDeviceCapabilities() {
        if ARWorldTrackingConfiguration.supportsFrameSemantics(.sceneDepth) {
            // LiDAR is supported on the device
            usesLiDAR = true
        } else {
            // LiDAR is not supported
            usesLiDAR = false
        }
    }
    
    func setupCamera() {
        session.beginConfiguration()
        
        guard let camera = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: camera) else {
            return
        }
        
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        if session.canAddOutput(output) {
            session.addOutput(output)
        }
        
        output.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)
        ]
        
        if let connection = output.connection(with: .video) {
            connection.videoOrientation = .landscapeRight
        }
        
        session.commitConfiguration()
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer?.videoGravity = .resizeAspectFill
        
        session.startRunning()
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let frameWidth = CVPixelBufferGetWidth(pixelBuffer)
        
        extractObjectPosition(from: pixelBuffer) { [weak self] currentPosition in
            guard let self = self, let currentPosition = currentPosition else { return }
            
            let currentTime = CACurrentMediaTime()
            
            if let speed = self.speedModel.calculateSpeed(currentPosition: currentPosition, currentTime: currentTime, frameWidth: CGFloat(frameWidth)) {
                DispatchQueue.main.async {
                    self.detectedSpeed = speed.kmh
                }
            }
            
            self.speedModel.previousPosition = currentPosition
            self.speedModel.previousTimestamp = currentTime
        }
    }
    
    func extractObjectPosition(from pixelBuffer: CVPixelBuffer, completion: @escaping (CGPoint?) -> Void) {
        let request = VNDetectRectanglesRequest { request, error in
            guard let results = request.results as? [VNRectangleObservation], let rectangle = results.first else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            let boundingBox = rectangle.boundingBox
            let center = CGPoint(x: boundingBox.midX, y: boundingBox.midY)
            
            DispatchQueue.main.async {
                completion(center)
            }
        }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        try? handler.perform([request])
    }
}
