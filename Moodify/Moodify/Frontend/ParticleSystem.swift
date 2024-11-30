////
////  ParticleSystem.swift
////  Moodify
////
////  Created by Nazanin Mahmoudi on 11/30/24.
////
//
//import SwiftUI
//
//struct Particle: Identifiable {
//    let id = UUID()
//    var position: CGPoint
//    var speed: CGFloat
//    var scale: CGFloat
//    var opacity: Double
//}
//
//struct ParticleSystem: View {
//    let mood: String
//    @State private var particles: [Particle] = []
//    @State private var timer: Timer?
//    let screenSize: CGSize
//    
//    init(mood: String, screenSize: CGSize) {
//        self.mood = mood
//        self.screenSize = screenSize
//    }
//    
//    var body: some View {
//        Canvas { context, size in
//            for particle in particles {
//                let image = context.resolve(Image(systemName: getParticleShape()))
//                context.opacity = particle.opacity
//                context.scaleBy(x: particle.scale, y: particle.scale)
//                context.draw(image, at: particle.position)
//            }
//        }
//        .onAppear {
//            startParticleSystem()
//        }
//        .onDisappear {
//            timer?.invalidate()
//        }
//    }
//    
//    private func getParticleShape() -> String {
//        switch mood.lowercased() {
//        case "happy":
//            return "sparkle"
//        case "sad":
//            return "drop.fill"
//        case "chill":
//            return "circle.fill"
//        case "angry":
//            return "flame.fill"
//        default:
//            return "circle.fill"
//        }
//    }
//    
//    private func startParticleSystem() {
//        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
//            updateParticles()
//        }
//    }
//    
//    private func updateParticles() {
//        // Remove old particles
//        particles = particles.filter { $0.opacity > 0 }
//        
//        // Update existing particles
//        particles = particles.map { particle in
//            var newParticle = particle
//            
//            switch mood.lowercased() {
//            case "happy":
//                // Sparkles float up and fade
//                newParticle.position.y -= particle.speed
//                newParticle.position.x += sin(particle.position.y * 0.1) * 0.5
//                newParticle.opacity -= 0.01
//                
//            case "sad":
//                // Raindrops fall straight down
//                newParticle.position.y += particle.speed
//                newParticle.opacity -= 0.02
//                
//            case "chill":
//                // Swirling mist effect
//                let angle = particle.position.y * 0.02
//                newParticle.position.x += cos(angle) * particle.speed
//                newParticle.position.y += sin(angle) * particle.speed * 0.5
//                newParticle.opacity -= 0.01
//                
//            case "angry":
//                // Rising embers effect
//                newParticle.position.y -= particle.speed
//                newParticle.position.x += sin(particle.position.y * 0.05) * 1.5
//                newParticle.opacity -= 0.02
//                
//            default:
//                // Default gentle floating effect
//                newParticle.position.y -= particle.speed * 0.5
//                newParticle.opacity -= 0.01
//            }
//            
//            return newParticle
//        }
//        
//        // Add new particles
//        if particles.count < getMaxParticles() {
//            particles.append(createParticle())
//        }
//    }
//    
//    private func createParticle() -> Particle {
//        let startPosition: CGPoint
//        let speed: CGFloat
//        let scale: CGFloat
//        
//        switch mood.lowercased() {
//        case "happy":
//            startPosition = CGPoint(
//                x: CGFloat.random(in: 0...screenSize.width),
//                y: screenSize.height + 10
//            )
//            speed = CGFloat.random(in: 1...3)
//            scale = CGFloat.random(in: 0.1...0.3)
//            
//        case "sad":
//            startPosition = CGPoint(
//                x: CGFloat.random(in: 0...screenSize.width),
//                y: -10
//            )
//            speed = CGFloat.random(in: 2...4)
//            scale = CGFloat.random(in: 0.2...0.4)
//            
//        case "chill":
//            startPosition = CGPoint(
//                x: CGFloat.random(in: 0...screenSize.width),
//                y: CGFloat.random(in: 0...screenSize.height)
//            )
//            speed = CGFloat.random(in: 0.5...1.5)
//            scale = CGFloat.random(in: 0.1...0.3)
//            
//        case "angry":
//            startPosition = CGPoint(
//                x: CGFloat.random(in: 0...screenSize.width),
//                y: screenSize.height + 10
//            )
//            speed = CGFloat.random(in: 1.5...3)
//            scale = CGFloat.random(in: 0.2...0.4)
//            
//        default:
//            startPosition = CGPoint(
//                x: CGFloat.random(in: 0...screenSize.width),
//                y: screenSize.height
//            )
//            speed = CGFloat.random(in: 1...2)
//            scale = CGFloat.random(in: 0.1...0.3)
//        }
//        
//        return Particle(
//            position: startPosition,
//            speed: speed,
//            scale: scale,
//            opacity: 1.0
//        )
//    }
//    
//    private func getMaxParticles() -> Int {
//        switch mood.lowercased() {
//        case "happy": return 30
//        case "sad": return 40
//        case "chill": return 25
//        case "angry": return 35
//        default: return 20
//        }
//    }
//}


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
