//
//  ButtonsView.swift
//  Focused Timer
//
//  Created by Felipe Morandin on 23/03/21.
//

import SwiftUI

struct ButtonsView: View {

    // MARK: - Environment
    @Environment(\.colorScheme) var colorScheme

    // MARK: - Observed Objects
    @StateObject var timerViewModel: TimerViewModel

    // MARK: - Initializer
    init(viewModel: TimerViewModel = .init(timerModel: TimerModel())) {
        _timerViewModel = StateObject(wrappedValue: viewModel)
    }

    // MARK: - View
    var body: some View {
        HStack(spacing: 20) {
            Button(action: {
                if timerViewModel.timerState == .initial || timerViewModel.timerState == .paused {
                    timerViewModel.startTimer()
                } else {
                    timerViewModel.pauseTimer()
                }
                SharedConstants().impactHeavy.impactOccurred()
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
                .background(timerViewModel.accentCircleColor)
                .clipShape(Capsule())
                .shadow(radius: 6)
            })
            .accessibility(identifier: Identifiers.btnStartPauseIdentifier)

            Button(action: {
                timerViewModel.resetUpdateTimer()
                SharedConstants().impactHeavy.impactOccurred()
            }, label: {
                HStack(spacing: 10) {
                    Image(systemName: ImageNames.reset)
                        .foregroundColor(.white)

                    Text(Translation.resetTimer)
                        .foregroundColor(.white)
                }
                .padding(.vertical)
                .frame(width: (UIScreen.main.bounds.width / 2) - 45, height: 60)
                .background(timerViewModel.accentCircleColor)
                .clipShape(Capsule())
                .shadow(radius: 6)
            })
            .accessibility(identifier: Identifiers.btnResetIdentifier)
        }
        .padding(.bottom, 20)
    }
}

struct ButtonsView_Previews: PreviewProvider {
    static var previews: some View {
        ButtonsView()
    }
}
