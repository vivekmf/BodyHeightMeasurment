//
//  HomeView.swift
//  MeasureFirst
//
//  Created by Vivek Singh on 10/7/24.
//

import Foundation
import SwiftUI

struct HomeView: View {
    @State private var showOptions = false
    @Namespace private var animation
    
    var body: some View {
        NavigationView {
            ZStack {
                // Enhanced gradient background
                LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple, Color.pink]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    
                    Spacer()
                    
                    // Gradient text for "Welcome" message
                    Text("Welcome to MeasureFirst App")
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(gradient: Gradient(colors: [Color.white, Color.yellow.opacity(0.9)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .padding(.top, 100)
                    
                    // Subheading with subtle opacity
                    Text("Select to Measure")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.top, 8)
                    
                    Spacer()
                    
                    if showOptions {
                        // Option buttons with enhanced styling
                        ScrollView {
                            NavigationLink(destination: AppView()) {
                                OptionCardView(title: "Height Measurement", description: "Measure your height using ARKit or Vision", animation: animation)
                            }
                            
                            NavigationLink(destination: SpeedDetectionView()) {
                                OptionCardView(title: "Speed Detection", description: "Detect human speed using LiDAR", animation: animation)
                            }
                        }
                    } else {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.8)) {
                                showOptions.toggle()
                            }
                        }) {
                            Text("Get Started")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .background(
                                    Capsule()
                                        .fill(Color.white.opacity(0.3))
                                        .overlay(
                                            Capsule().stroke(Color.white.opacity(0.5), lineWidth: 1)
                                        )
                                )
                                .shadow(color: Color.white.opacity(0.2), radius: 10, x: 0, y: 10)
                        }
                        .padding(.bottom, 50)
                    }
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct OptionCardView: View {
    let title: String
    let description: String
    var animation: Namespace.ID
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white.opacity(0.2))
                .frame(width: 320, height: 160)
                .overlay(
                    VStack(alignment: .leading) {
                        Text(title)
                            .font(.title)
                            .bold()
                            .foregroundColor(.white)
                            .padding(.bottom, 5)
                        Text(description)
                            .foregroundColor(.white.opacity(0.8))
                    }
                        .padding()
                )
                .shadow(color: Color.black.opacity(0.4), radius: 10, x: 0, y: 10)
                .scaleEffect(0.95)
                .matchedGeometryEffect(id: title, in: animation)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
}
