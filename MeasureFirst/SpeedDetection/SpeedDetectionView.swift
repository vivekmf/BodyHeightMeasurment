//
//  SpeedDetectionView.swift
//  MeasureFirstApp
//
//  Created by Vivek Singh on 9/25/24.
//

import Foundation
import SwiftUI
import AVFoundation

struct SpeedDetectionView: View {
    @StateObject var viewModel = SpeedDetectionViewModel()
    
    var body: some View {
        VStack {
            CameraView(previewLayer: viewModel.previewLayer)
                .edgesIgnoringSafeArea(.all) // Ensures the camera view covers the entire screen
                .overlay(
                    VStack {
                        if let speed = viewModel.detectedSpeed {
                            VStack {
                                Text("Speed: \(String(format: "%.2f", speed)) km/h")
                                    .font(.largeTitle)
                                    .padding()
                                    .background(Color.black.opacity(0.5))
                                    .cornerRadius(10)
                                    .foregroundColor(.white)
                                
                                Text("Speed: \(String(format: "%.2f", speed / 1.60934)) mph")
                                    .font(.largeTitle)
                                    .padding()
                                    .background(Color.black.opacity(0.5))
                                    .cornerRadius(10)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(),
                    alignment: .top
                )
        }
    }
}

struct CameraView: UIViewControllerRepresentable {
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    class Coordinator: NSObject {
        var parent: CameraView
        
        init(parent: CameraView) {
            self.parent = parent
            super.init()
            NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)
        }
        
        @objc func orientationChanged() {
            guard let previewLayer = parent.previewLayer,
                  let connection = previewLayer.connection,
                  connection.isVideoOrientationSupported else { return }
            
            // Apply correct orientation based on device orientation
            connection.videoOrientation = AVCaptureVideoOrientation(deviceOrientation: UIDevice.current.orientation) ?? .portrait
            
            // Ensure the preview layer frame fills the screen
            DispatchQueue.main.async {
                if let superlayer = previewLayer.superlayer {
                    previewLayer.frame = superlayer.bounds
                }
            }
        }
        
        deinit {
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        viewController.view.backgroundColor = .black // Set background to black to avoid any blank space
        
        if let previewLayer = previewLayer {
            previewLayer.frame = UIScreen.main.bounds // Initially set the preview layer to the full screen
            viewController.view.layer.addSublayer(previewLayer)
        }
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if let previewLayer = previewLayer {
            // Ensure the preview layer takes up the entire bounds of the view controller
            DispatchQueue.main.async {
                previewLayer.frame = uiViewController.view.bounds
            }
        }
    }
}

extension AVCaptureVideoOrientation {
    // Helper method to convert UIDeviceOrientation to AVCaptureVideoOrientation
    init?(deviceOrientation: UIDeviceOrientation) {
        switch deviceOrientation {
        case .portrait:
            self = .portrait
        case .portraitUpsideDown:
            self = .portraitUpsideDown
        case .landscapeLeft:
            self = .landscapeRight
        case .landscapeRight:
            self = .landscapeLeft
        default:
            return nil
        }
    }
}
