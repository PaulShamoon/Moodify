//
//  ParticleSystem.swift
//  Moodify
//
//  Created by Nazanin Mahmoudi on 11/30/24.
//

import SwiftUI
import UIKit

struct ParticleEmitterView: UIViewRepresentable {
    let particleImage: UIImage
    let birthRate: Float
    let lifetime: Float
    let velocity: CGFloat
    let scale: CGFloat
    let color: UIColor
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        
        let emitter = CAEmitterLayer()
        emitter.emitterShape = .line
        emitter.emitterPosition = CGPoint(x: UIScreen.main.bounds.width / 2, y: 0)
        emitter.emitterSize = CGSize(width: UIScreen.main.bounds.width, height: 1)
        
        let cell = CAEmitterCell()
        cell.contents = particleImage.cgImage
        cell.birthRate = birthRate
        cell.lifetime = lifetime
        cell.velocity = velocity
        cell.scale = scale
        cell.color = color.cgColor
        cell.emissionRange = .pi
        
        emitter.emitterCells = [cell]
        view.layer.addSublayer(emitter)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}
