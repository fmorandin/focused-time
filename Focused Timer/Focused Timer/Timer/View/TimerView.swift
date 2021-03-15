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
    @State private var showingHelp = false

    // MARK: Initializer
    init(viewModel: TimerViewModel = .init(timerModel: TimerModel())) {
        _timerViewModel = StateObject(wrappedValue: viewModel)
    }

    // MARK: - View
    var body: some View {
        ZStack {
            Color.black.opacity(0.06).edgesIgnoringSafeArea(.all)
            VStack {
                // Top section with the config button
                HStack {

                    Button(action: {
                        self.showingHelp = true
                    }, label: {
                        Image(systemName: ImageNames.showHelp)
                            .font(.system(size: 25))
                            .padding(.trailing)
                            .foregroundColor((colorScheme == .light ? Color.black : Color.white)).opacity(0.5)

                    })
                    .sheet(isPresented: $showingHelp, content: {
                        HelpView()
                    })
                    .accessibility(identifier: Identifiers.btnShowHelp)

                    Spacer()

                    Button(action: {
                        self.showingConfig = true
                    }, label: {
                        Image(systemName: ImageNames.showSettings)
                            .font(.system(size: 25))
                            .padding(.trailing)
                            .foregroundColor((colorScheme == .light ? Color.black : Color.white)).opacity(0.5)
                    })
                    .sheet(isPresented: $showingConfig, onDismiss: timerViewModel.resetUpdateTimer, content: {
                        SettingsView()
                    })
                    .accessibility(identifier: Identifiers.btnShowSettings)
                }
                .padding(.leading, 40)
                .padding(.trailing, 20)

                Spacer().frame(height: 50)

                // Main circles
                ZStack {
                    Circle()
                        .trim(from: 0, to: 1)
                        .stroke((colorScheme == .light ? Color.black : Color.white).opacity(0.09),
                                style: StrokeStyle(lineWidth: 15, lineCap: .round))
                        .frame(width: 300, height: 300)

                    Circle()
                        .trim(from: 0, to: timerViewModel.timerTo)
                        .stroke(timerViewModel.timerType == .focused ? Color.orange : Color.blue,
                                style: StrokeStyle(lineWidth: 25, lineCap: .round))
                        .frame(width: 300, height: 300)
                        .rotationEffect(.init(degrees: -90))
                        .shadow(radius: 4)
                        .accessibility(identifier:
                                        timerViewModel.timerType == .focused ?
                                        Identifiers.circleFocused :
                                        Identifiers.circleRest)

                    VStack {
                        Text(timerViewModel.countTime)
                            .font(.system(size: 60))
                            .fontWeight(.bold)
                            .accessibility(identifier: Identifiers.lblCounter)
                            .multilineTextAlignment(.center)
                    }
                }

                Spacer().frame(height: 50)

                // Buttons that controls the timer
                HStack(spacing: 20) {
                    Button(action: {
                        if timerViewModel.timerState == .initial || timerViewModel.timerState == .paused {
                            timerViewModel.startTimer()
                        } else {
                            timerViewModel.pauseTimer()
                        }
                    }, label: {
                        HStack(spacing: 10) {
                            Image(systemName:
                                    timerViewModel.timerState == .running ?
                                    ImageNames.pause :
                                    ImageNames.play)
                                .foregroundColor(.white)

                            Text(timerViewModel.timerState == .running ?
                                    Translation.pauseTimer :
                                    Translation.playTimer)
                                .foregroundColor(.white)
                        }
                        .padding(.vertical)
                        .frame(width: (UIScreen.main.bounds.width / 2) - 45, height: 60)
                        .background(timerViewModel.timerType == .focused ? Color.orange : Color.blue)
                        .clipShape(Capsule())
                        .shadow(radius: 6)
                    })
                    .accessibility(identifier: Identifiers.btnStartPauseIdentifier)

                    Button(action: {
                        timerViewModel.resetUpdateTimer()
                    }, label: {
                        HStack(spacing: 10) {
                            Image(systemName: ImageNames.reset)
                                .foregroundColor(.white)

                            Text(Translation.resetTimer)
                                .foregroundColor(.white)
                        }
                        .padding(.vertical)
                        .frame(width: (UIScreen.main.bounds.width / 2) - 45, height: 60)
                        .background(timerViewModel.timerType == .focused ? Color.orange : Color.blue)
                        .clipShape(Capsule())
                        .shadow(radius: 6)
                    })
                    .accessibility(identifier: Identifiers.btnResetIdentifier)
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(
                    for: UIApplication.didEnterBackgroundNotification)) { _ in
            timerViewModel.moveAppToBackground()
        }
        .onReceive(NotificationCenter.default.publisher(
                    for: UIApplication.willEnterForegroundNotification)) { _ in
            timerViewModel.moveAppToForeground()
        }
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Group {
                ForEach(["en", "pt"], id: \.self) { id in
                    TimerView()
                        .environment(\.locale, .init(identifier: id))
                }
            }
        }
    }
}
