//
//  VisionHeightMeasurementController.swift
//  MeasureFirstApp
//
//  Created by Vivek Singh on 9/24/24.
//

import SwiftUI
import AVFoundation
import Vision

class VisionHeightMeasurementController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    var request = VNDetectHumanBodyPoseRequest()
    var faceRequest = VNDetectFaceRectanglesRequest()
    
    let captureSession = AVCaptureSession()
    var estimatedHeight: Binding<String>?
    var updatePoints: ((CGPoint, CGPoint) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }
    
    func setupCamera() {
        captureSession.sessionPreset = .medium
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return }
        
        let input = try? AVCaptureDeviceInput(device: camera)
        if let input = input {
            captureSession.addInput(input)
        }
        
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(output)
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.frame
        view.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .right, options: [:])
        
        do {
            try handler.perform([request, faceRequest])
            guard let bodyObservation = request.results?.first as? VNHumanBodyPoseObservation else { return }
            guard let faceObservation = faceRequest.results?.first as? VNFaceObservation else { return }
            
            let headPoint = try? bodyObservation.recognizedPoint(.nose)
            let leftAnklePoint = try? bodyObservation.recognizedPoint(.leftAnkle)
            let rightAnklePoint = try? bodyObservation.recognizedPoint(.rightAnkle)
            
            if let headPoint = headPoint, let leftAnklePoint = leftAnklePoint, let rightAnklePoint = rightAnklePoint {
                // Calculate height without adjustment
                let headY = headPoint.location.y
                let feetY = min(leftAnklePoint.location.y, rightAnklePoint.location.y)
                let normalizedHeight = headY - feetY
                
                // Calculate face size
                let faceHeightInImage = faceObservation.boundingBox.height * view.frame.height
                let estimatedDistance = estimateDistanceFromFaceSize(faceHeightInImage)
                
                // Adjust height using estimated distance
                let adjustedHeight = normalizedHeight * estimatedDistance * 100
                
                DispatchQueue.main.async {
                    self.estimatedHeight?.wrappedValue = "\(Int(adjustedHeight)) cm"
                    
                    let head = CGPoint(x: headPoint.location.x * self.view.frame.width, y: headPoint.location.y * self.view.frame.height)
                    let feet = CGPoint(x: leftAnklePoint.location.x * self.view.frame.width, y: feetY * self.view.frame.height)
                    self.updatePoints?(head, feet)
                }
            }
        } catch {
            print("Error detecting body pose: \(error)")
        }
    }
    
    func estimateDistanceFromFaceSize(_ faceHeightInImage: CGFloat) -> CGFloat {
        // Assumed average adult head height in meters (0.23m)
        let averageHeadHeight: CGFloat = 0.23
        
        // Focal length (use an average value for iPhone cameras, could be adjusted)
        let focalLength: CGFloat = 1000.0
        
        // Estimate distance using the focal length, reference head size, and observed head size
        let estimatedDistance = (averageHeadHeight * focalLength) / faceHeightInImage
        
        return estimatedDistance
    }
}
