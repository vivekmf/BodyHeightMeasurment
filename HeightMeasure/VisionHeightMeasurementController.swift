//
//  VisionHeightMeasurementController.swift
//  HeightMeasure
//
//  Created by Vivek Singh on 9/24/24.
//

import SwiftUI
import AVFoundation
import Vision

class VisionHeightMeasurementController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    var request = VNDetectHumanBodyPoseRequest()
    let captureSession = AVCaptureSession()
    var estimatedHeight: Binding<String>?
    
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
            try handler.perform([request])
            guard let observation = request.results?.first as? VNHumanBodyPoseObservation else { return }
            
            let headPoint = try? observation.recognizedPoint(.nose)
            let leftAnklePoint = try? observation.recognizedPoint(.leftAnkle)
            let rightAnklePoint = try? observation.recognizedPoint(.rightAnkle)
            
            if let headPoint = headPoint, let leftAnklePoint = leftAnklePoint, let rightAnklePoint = rightAnklePoint {
                let headY = headPoint.location.y
                let feetY = min(leftAnklePoint.location.y, rightAnklePoint.location.y)
                let normalizedHeight = headY - feetY
                
                let cameraDistance = estimateDistanceToPerson(using: headY, feetY: feetY)
                let heightInCm = normalizedHeight * cameraDistance * 100
                
                DispatchQueue.main.async {
                    self.estimatedHeight?.wrappedValue = "\(Int(heightInCm)) cm"
                }
            }
        } catch {
            print("Error detecting body pose: \(error)")
        }
    }
    
    func estimateDistanceToPerson(using headY: CGFloat, feetY: CGFloat) -> CGFloat {
        let focalLength: CGFloat = 50 // Example focal length for iPhone
        let headToFeetRatio = abs(headY - feetY)
        return focalLength / headToFeetRatio
    }
}
