//
//  LineOverlay.swift
//  MeasureFirstApp
//
//  Created by Vivek Singh on 9/24/24.
//

import Foundation
import SwiftUI

struct LineOverlay: View {
    var headPoint: CGPoint
    var feetPoint: CGPoint
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                let head = CGPoint(x: headPoint.x * width, y: (1 - headPoint.y) * height)
                let feet = CGPoint(x: feetPoint.x * width, y: (1 - feetPoint.y) * height)
                
                path.move(to: feet)
                path.addLine(to: head)
            }
            .stroke(Color.red, lineWidth: 2)
        }
    }
}
