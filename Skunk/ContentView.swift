//
//  ContentView.swift
//  Skunk
//
//  Created by Dittrich, Jan - Student on 11/4/25.
//

import SwiftUI

struct ContentView: View {
    @State private var diceValues = [(1, 1), (1, 1), (1, 1), (1, 1)]
    @State private var totalScores = [0, 0, 0, 0]
    @State private var roundScores = [0, 0, 0, 0]
    @State private var currentPlayer = 0
    @State private var showWinner = false
    @State private var winnerName = ""
    @State private var showSkunk = false
    @State private var showInstructions = false
    
    private let skunkNumber = 1
    private let winScore = 100
    
    var body: some View {
        ZStack {
            Color(red: 0.92, green: 0.98, blue: 0.94)
                .ignoresSafeArea()
            
            GeometryReader { geo in
                ZStack {
                    
                    playerCorner(index: 0, color: .green)
                        .rotationEffect(.degrees(-35))
                        .position(x: geo.size.width * 0.25, y: geo.size.height * 0.25)
                    
                    playerCorner(index: 1, color: .red)
                        .rotationEffect(.degrees(35))
                        .position(x: geo.size.width * 0.75, y: geo.size.height * 0.25)
                    
                    playerCorner(index: 2, color: .yellow)
                        .rotationEffect(.degrees(35))
                        .position(x: geo.size.width * 0.25, y: geo.size.height * 0.75)
                    
                    playerCorner(index: 3, color: .blue)
                        .rotationEffect(.degrees(-35))
                        .position(x: geo.size.width * 0.75, y: geo.size.height * 0.75)
                    
                    
                    VStack(spacing: 35) {
                        HStack(spacing: 10) {
                            Image(systemName: "die.face.5.fill")
                                .font(.system(size: 60))
                            Text("Skunk!")
                                .font(.system(size: 70, weight: .black, design: .rounded))
                        }
                        
                        Text("Current Player: \(currentPlayer + 1)")
                            .font(.title.bold())
                            .foregroundStyle(playerColor(for: currentPlayer))
                        
                        Button("Roll Dice") { rollDice() }
                            .font(.system(size: 40, weight: .bold))
                            .padding(.horizontal, 60)
                            .padding(.vertical, 20)
                            .background(Color.black)
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                        
                        Button("Pass Dice") { passDice() }
                            .font(.title2.bold())
                            .padding(.horizontal, 40)
                            .padding(.vertical, 15)
                            .background(Color.gray.opacity(0.15))
                            .clipShape(Capsule())
                    }
                    .position(x: geo.size.width / 2, y: geo.size.height / 2)
                }
            }
            
            
            if showSkunk {
                SkunkAnimationView()
            }
            
            
            if showWinner {
                VStack(spacing: 20) {
                    Text("🏆 \(winnerName) Wins! 🏆")
                        .font(.largeTitle.bold())
                    Button("Play Again") { resetGame() }
                        .buttonStyle(.borderedProminent)
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(radius: 10)
            }
            
            
            VStack {
                HStack {
                    Spacer()
                    Button {
                        showInstructions.toggle()
                    } label: {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 36))
                            .foregroundColor(.black)
                            .padding()
                    }
                }
                Spacer()
            }
        }
        .sheet(isPresented: $showInstructions) {
            InstructionsView(totalScores: totalScores)
        }
    }
    
    // MARK: - Player Corner
    private func playerCorner(index: Int, color: Color) -> some View {
        VStack(spacing: 6) {
            HStack(spacing: -10) {
                DiceView(value: diceValues[index].0, color: color)
                DiceView(value: diceValues[index].1, color: color)
            }
            Text("P\(index + 1): \(totalScores[index])")
                .font(.headline)
                .foregroundColor(.black)
        }
        .padding(6)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(currentPlayer == index ? color : .clear, lineWidth: 4)
                .shadow(color: currentPlayer == index ? color.opacity(0.7) : .clear, radius: 8)
        )
    }
    
    // MARK: - Logic
    private func rollDice() {
        let d1 = Int.random(in: 1...6)
        let d2 = Int.random(in: 1...6)
        diceValues[currentPlayer] = (d1, d2)
        
        if d1 == skunkNumber && d2 == skunkNumber {
            // Double skunk: lose everything
            totalScores[currentPlayer] = 0
            roundScores[currentPlayer] = 0
            showSkunkAnimation()
            nextPlayer()
        } else if d1 == skunkNumber || d2 == skunkNumber {
            // Single skunk: lose round points
            roundScores[currentPlayer] = 0
            showSkunkAnimation()
            nextPlayer()
        } else {
            // Normal roll
            roundScores[currentPlayer] += d1 + d2
        }
    }
    
    private func passDice() {
        totalScores[currentPlayer] += roundScores[currentPlayer]
        roundScores[currentPlayer] = 0
        
        if totalScores[currentPlayer] >= winScore {
            winnerName = "Player \(currentPlayer + 1)"
            showWinner = true
        } else {
            nextPlayer()
        }
    }
    
    private func nextPlayer() {
        currentPlayer = (currentPlayer + 1) % 4
    }
    
    private func showSkunkAnimation() {
        withAnimation(.easeInOut(duration: 0.6)) { showSkunk = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            withAnimation { showSkunk = false }
        }
    }
    
    private func resetGame() {
        totalScores = [0, 0, 0, 0]
        roundScores = [0, 0, 0, 0]
        currentPlayer = 0
        showWinner = false
    }
    
    private func playerColor(for index: Int) -> Color {
        switch index {
        case 0: return .green
        case 1: return .red
        case 2: return .yellow
        case 3: return .blue
        default: return .black
        }
    }
}

struct DiceView: View {
    let value: Int
    let color: Color
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(color.gradient)
                .frame(width: 90, height: 90)
                .shadow(radius: 4)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(.black, lineWidth: 2))
            DicePips(value: value)
        }
    }
}

struct DicePips: View {
    let value: Int
    
    var body: some View {
        GeometryReader { geo in
            let s = geo.size
            Group {
                switch value {
                case 1: pip(center(s))
                case 2: pip(topLeft(s)); pip(bottomRight(s))
                case 3: pip(topLeft(s)); pip(center(s)); pip(bottomRight(s))
                case 4: pip(topLeft(s)); pip(topRight(s)); pip(bottomLeft(s)); pip(bottomRight(s))
                case 5: pip(topLeft(s)); pip(topRight(s)); pip(center(s)); pip(bottomLeft(s)); pip(bottomRight(s))
                case 6: pip(topLeft(s)); pip(topRight(s)); pip(centerLeft(s)); pip(centerRight(s)); pip(bottomLeft(s)); pip(bottomRight(s))
                default: EmptyView()
                }
            }
        }
        .frame(width: 90, height: 90)
    }
    
    private func pip(_ point: CGPoint) -> some View {
        Circle().fill(.black).frame(width: 12, height: 12).position(point)
    }
    
    private func topLeft(_ s: CGSize) -> CGPoint { CGPoint(x: s.width * 0.25, y: s.height * 0.25) }
    private func topRight(_ s: CGSize) -> CGPoint { CGPoint(x: s.width * 0.75, y: s.height * 0.25) }
    private func bottomLeft(_ s: CGSize) -> CGPoint { CGPoint(x: s.width * 0.25, y: s.height * 0.75) }
    private func bottomRight(_ s: CGSize) -> CGPoint { CGPoint(x: s.width * 0.75, y: s.height * 0.75) }
    private func centerLeft(_ s: CGSize) -> CGPoint { CGPoint(x: s.width * 0.25, y: s.height * 0.5) }
    private func centerRight(_ s: CGSize) -> CGPoint { CGPoint(x: s.width * 0.75, y: s.height * 0.5) }
    private func center(_ s: CGSize) -> CGPoint { CGPoint(x: s.width * 0.5, y: s.height * 0.5) }
}

struct SkunkAnimationView: View {
    @State private var offsetX: CGFloat = -500
    var body: some View {
        Image(systemName: "pawprint.fill")
            .resizable()
            .scaledToFit()
            .frame(width: 180, height: 180)
            .foregroundStyle(.black)
            .offset(x: offsetX)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.5)) {
                    offsetX = 700
                }
            }
    }
}

// MARK: - Instructions Screen
struct InstructionsView: View {
    let totalScores: [Int]
    
    var body: some View {
        VStack(spacing: 30) {
            Text("🦨 Skunk! Rules")
                .font(.largeTitle.bold())
            VStack(alignment: .leading, spacing: 16) {
                Text("🎲 Roll two dice to add to your round score.")
                Text("💨 Roll one skunk (a single 1): lose round points and pass.")
                Text("💀 Roll two skunks (double 1s): lose all total points and pass.")
                Text("🖐️ Pass to save your round score to your total.")
                Text("🏆 First to 100 total points wins!")
            }
            .font(.title3)
            .padding()
            
            Divider()
            
            VStack(spacing: 12) {
                Text("📊 Current Totals")
                    .font(.title2.bold())
                ForEach(0..<totalScores.count, id: \.self) { i in
                    Text("Player \(i + 1): \(totalScores[i]) pts")
                        .font(.title3)
                }
            }
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
