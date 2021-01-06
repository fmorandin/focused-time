//
//  TimerView.swift
//  Focused Timer
//
//  Created by Felipe Chiarini Pena Morandin on 28/09/20.
//

import SwiftUI

struct TimerView: View {

    @Environment(\.colorScheme) var colorScheme

    @ObservedObject var controller = TimerController()

    var body: some View {
        ZStack {
            Color.black.opacity(0.06).edgesIgnoringSafeArea(.all)
            VStack(spacing: 60) {
                ZStack {
                    Circle()
                        .trim(from: 0, to: 1)
                        .stroke((colorScheme == .light ? Color.black : Color.white).opacity(0.09),
                                style: StrokeStyle(lineWidth: 15, lineCap: .round))
                        .frame(width: 300, height: 300)

                    Circle()
                        .trim(from: 0, to: controller.to)
                        .stroke(Color.orange, style: StrokeStyle(lineWidth: 25, lineCap: .round))
                        .frame(width: 300, height: 300)
                        .rotationEffect(.init(degrees: -90))
                        .shadow(radius: 4)

                    VStack {
                        Text("\(controller.count) of \(controller.totalTime)")
                            .font(.system(size: 60))
                            .fontWeight(.bold)
                    }
                }

                HStack(spacing: 20) {
                    Button(action: {
                        if controller.timerState == .initial || controller.timerState == .paused {
                            controller.startTimer()
                        } else {
                            controller.pauseTimer()
                        }
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: controller.timerState == .running ? "pause" :  "play")
                                .foregroundColor(.white)

                            Text(controller.timerState == .running ? "Pause" : "Play")
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
                        controller.resetTimer()
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
            }
        }
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TimerView()

            TimerView()
                .preferredColorScheme(.dark)
                .environment(\.locale, Locale(identifier: "br"))
        }
    }
}
