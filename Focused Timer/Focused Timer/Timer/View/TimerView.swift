//
//  TimerView.swift
//  Focused Timer
//
//  Created by Felipe Chiarini Pena Morandin on 28/09/20.
//

import SwiftUI

struct TimerView: View {
    @State var start = false
    @State var to : CGFloat = 0
    @State var count = 0
    @State var time = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var totalTime = 15

    var body: some View {
        ZStack {
            Color.black.opacity(0.06).edgesIgnoringSafeArea(.all)
            VStack(spacing: 60) {
                ZStack {
                    Circle()
                        .trim(from: 0, to: 1)
                        .stroke(Color.black.opacity(0.09), style: StrokeStyle(lineWidth: 35, lineCap: .round))
                        .frame(width: 300, height: 300)

                    Circle()
                        .trim(from: 0, to: to)
                        .stroke(Color.orange, style: StrokeStyle(lineWidth: 35, lineCap: .round))
                        .frame(width: 300, height: 300)
                        .rotationEffect(.init(degrees: -90))

                    VStack {
                        Text("\(count) de \(totalTime)")
                            .font(.system(size: 60))
                            .fontWeight(.bold)
                    }
                }

                HStack(spacing: 20) {
                    Button(action: {
                        start.toggle()
                    }) {
                        HStack(spacing: 15) {
                            Image(systemName: start ? "pause.fill" :  "play.fill")
                                .foregroundColor(.white)

                            Text(start ? "Pause" : "Play")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                        .padding(.vertical)
                        .frame(width: (UIScreen.main.bounds.width / 2) - 55, height: 60)
                        .background(Color.orange)
                        .clipShape(Capsule())
                        .shadow(radius: 6)
                    }
                }
            }
            .onReceive(time) { (_) in
                if start {
                    if count != totalTime {
                        count += 1
                        withAnimation(.default) {
                            to = CGFloat(count) / CGFloat(totalTime)
                        }
                    }
                    else {
                        start.toggle()
                        to = 0
                        count = 0
                    }
                }
            }
        }
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView()
    }
}
