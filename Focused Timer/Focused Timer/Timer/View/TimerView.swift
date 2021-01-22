//
//  TimerView.swift
//  Focused Timer
//
//  Created by Felipe Chiarini Pena Morandin on 28/09/20.
//

import SwiftUI

struct TimerView: View {

    // MARK: - Environment
    @Environment(\.colorScheme) var colorScheme

    // MARK: - Oberved Objects
    @StateObject var timerViewModel: TimerViewModel

    // MARK: - States
    @State private var showingConfig = false

    // MARK: Initializer
    init(viewModel: TimerViewModel = .init(totalTime: nil)) {
        _timerViewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.06).edgesIgnoringSafeArea(.all)
            VStack {
                Spacer()

                /// Top section with the config button
                HStack {
                    Spacer()

                    Button(action: {
                        self.showingConfig = true
                    }) {
                        Image(systemName: "gear")
                            .font(.system(size: 25))
                            .padding(.trailing)
                            .foregroundColor((colorScheme == .light ? Color.black : Color.white)).opacity(0.5)
                    }
                    .sheet(isPresented: $showingConfig, onDismiss: timerViewModel.resetTimer, content: {
                        SettingsView(totalTime: "\(timerViewModel.totalTime)")
                    })
                }
                .padding(.trailing, 20)

                Spacer()
                Spacer()

                /// Main circles
                ZStack {
                    Circle()
                        .trim(from: 0, to: 1)
                        .stroke((colorScheme == .light ? Color.black : Color.white).opacity(0.09),
                                style: StrokeStyle(lineWidth: 15, lineCap: .round))
                        .frame(width: 300, height: 300)
                        .accessibility(identifier: "uiInternalCircle")

                    Circle()
                        .trim(from: 0, to: timerViewModel.to)
                        .stroke(Color.orange, style: StrokeStyle(lineWidth: 25, lineCap: .round))
                        .frame(width: 300, height: 300)
                        .rotationEffect(.init(degrees: -90))
                        .shadow(radius: 4)
                        .accessibility(identifier: "uiExternalCircle")

                    VStack {
                        Text("\(timerViewModel.count) of \(timerViewModel.totalTime)")
                            .font(.system(size: 60))
                            .fontWeight(.bold)
                            .accessibility(identifier: "lblCounter")
                    }
                }

                Spacer()
                Spacer()

                /// Buttons that controls the timer
                HStack(spacing: 40) {
                    Button(action: {
                        if timerViewModel.timerState == .initial || timerViewModel.timerState == .paused {
                            timerViewModel.startTimer()
                        } else {
                            timerViewModel.pauseTimer()
                        }
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: timerViewModel.timerState == .running ? "pause" :  "play")
                                .foregroundColor(.white)

                            Text(timerViewModel.timerState == .running ? "Pause" : "Play")
                                .foregroundColor(.white)
                        }
                        .padding(.vertical)
                        .frame(width: (UIScreen.main.bounds.width / 2) - 80, height: 60)
                        .background(Color.orange)
                        .clipShape(Capsule())
                        .shadow(radius: 6)
                    }
                    .accessibility(identifier: "btnStartPauseIdentifier")

                    Button(action: {
                        timerViewModel.resetTimer()
                    }, label: {
                        HStack(spacing: 10) {
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(.white)

                            Text("Reset")
                                .foregroundColor(.white)
                        }
                        .padding(.vertical)
                        .frame(width: (UIScreen.main.bounds.width / 2) - 80, height: 60)
                        .background(Color.orange)
                        .clipShape(Capsule())
                        .shadow(radius: 6)
                    })
                    .accessibility(identifier: "btnResetIdentifier")
                }

                Spacer()
                Spacer()
            }
            .padding(.top)
        }
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TimerView()

            TimerView()
                .preferredColorScheme(.dark)
        }
    }
}
