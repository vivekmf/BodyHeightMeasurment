//
//  SpeedModel.swift
//  MeasureFirstApp
//
//  Created by Vivek Singh on 9/25/24.
//

import Foundation
import CoreGraphics

class SpeedModel {
    var previousPosition: CGPoint?
    var previousTimestamp: CFTimeInterval?
    
    var objectDistance: Double = 5.0
    var fieldOfView: Double = 60.0
    
    let speedThreshold: Double = 0.1 // km/h
    
    func pixelToMeters(pixelDisplacement: CGFloat, frameWidth: CGFloat) -> Double {
        let fovInRadians = fieldOfView * .pi / 180.0
        let metersPerPixel = 2 * objectDistance * tan(fovInRadians / 2) / Double(frameWidth)
        return metersPerPixel * Double(pixelDisplacement)
    }
    
    func calculateSpeed(currentPosition: CGPoint, currentTime: CFTimeInterval, frameWidth: CGFloat) -> (kmh: Double, mph: Double)? {
        guard let previousPosition = previousPosition, let previousTimestamp = previousTimestamp else {
            return nil
        }
        
        let deltaX = currentPosition.x - previousPosition.x
        let deltaY = currentPosition.y - previousPosition.y
        let pixelDisplacement = sqrt(deltaX * deltaX + deltaY * deltaY)
        
        let displacementInMeters = pixelToMeters(pixelDisplacement: pixelDisplacement, frameWidth: frameWidth)
        
        let timeElapsed = currentTime - previousTimestamp
        
        let speedInMetersPerSecond = displacementInMeters / timeElapsed
        
        let speedInKmh = speedInMetersPerSecond * 3.6
        let speedInMph = speedInMetersPerSecond * 2.237
        
        if speedInKmh < speedThreshold {
            return (kmh: 0, mph: 0)
        }
        
        return (kmh: speedInKmh, mph: speedInMph)
    }
}
