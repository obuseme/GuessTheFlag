//
//  ContentView.swift
//  GuessTheFlag
//
//  Created by Andrew Obusek on 7/8/20.
//

import SwiftUI

struct FlagView: View {

    var country: String

    var body: some View {
        Image(country)
            .renderingMode(.original)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.black, lineWidth: 1))
            .shadow(color: .black, radius: 2)
    }

}

struct Shake: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX:
            amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
            y: 0))
    }
}

struct ContentView: View {
    @State private var countries = ["Estonia", "France", "Germany", "Ireland", "Italy", "Nigeria", "Poland", "Russia", "Spain", "UK", "US"].shuffled()
    @State private var correctAnswer = Int.random(in: 0...2)

    @State private var showingScore = false
    @State private var scoreTitle = ""
    @State private var userScore = 0
    @State private var animationAmount = 0.0
    @State private var opacityAmount = 100.0
    @State private var wrongAttempt = false
    @State private var questionAnswered = false
    @State private var selectedFlag = -1
    @State var attempts: Int = 0

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.blue, .black]), startPoint: .top, endPoint: .bottom).edgesIgnoringSafeArea(.all)
            VStack(spacing: 30) {
                VStack {
                    Text("Tap the flag of")
                        .foregroundColor(.white)

                    Text(countries[correctAnswer])
                        .foregroundColor(.white)
                        .font(.largeTitle)
                        .fontWeight(.black)
                }
                ForEach(0 ..< 3) { number in
                    Button(action: {
                        // flag was tapped
                        self.flagTapped(number)
                    }) {
                        if questionAnswered {
                            if number == correctAnswer {
                                FlagView(country: self.countries[number])
                                    .rotation3DEffect(.degrees(animationAmount), axis: (x: 0, y: 1, z: 0))
                            } else {
                                if number == selectedFlag {
                                    FlagView(country: self.countries[number]).opacity(opacityAmount)
                                        .modifier(Shake(animatableData: CGFloat(attempts)))
                                } else {
                                    FlagView(country: self.countries[number]).opacity(opacityAmount)
                                }
                            }
                        } else {
                            FlagView(country: self.countries[number])
                        }
                    }
                }
                Spacer()
                Text("Current Score: \(userScore)").foregroundColor(.white)
            }
        }

        .alert(isPresented: $showingScore) {
            Alert(title: Text(scoreTitle), message: Text("Your score is \(userScore)"), dismissButton: .default(Text("Continue")) {
                self.askQuestion()
                withAnimation {
                    self.opacityAmount = 1.0
                }
            })
        }
    }

    func flagTapped(_ number: Int) {
        selectedFlag = number
        questionAnswered = true
        if number == correctAnswer {
            scoreTitle = "Correct"
            userScore += 1
            withAnimation {
                self.animationAmount += 360
                self.opacityAmount = 0.25
            }
        } else {
            scoreTitle = "Wrong, that's the flag of \(countries[number])"
            withAnimation {
                wrongAttempt = true
                self.attempts += 1
            }
        }
        showingScore = true
    }

    func askQuestion() {
        attempts = 0
        wrongAttempt = false
        questionAnswered = false
        countries = countries.shuffled()
        correctAnswer = Int.random(in: 0...2)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
