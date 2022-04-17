//
//  ToastViewModifier.swift
//  TimeForABreakSwiftUI
//
//  Created by Chris Duehrsen on 2022-04-16.
//

import Foundation
import SwiftUI

struct Toast: ViewModifier {
    
    static let shortDuration: TimeInterval = 2
    static let longDuration: TimeInterval = 3.5
    
    let message: String
    let config: Config
    @Binding var isShowing: Bool
    
    func body(content: Content) -> some View {
        ZStack {
            content
            toastView
                .offset(y: config.yOffset)
        }
    }
    
    private var toastView: some View {
        VStack {
            Spacer()
            if isShowing {
                Group {
                    Label(message, systemImage: config.sysImg)
                        .multilineTextAlignment(.center)
                        .foregroundColor(config.textColor)
                        .font(config.font)
                        .padding(8)
                }
                .background(config.backgroundColor)
                .cornerRadius(8)
                .onTapGesture {
                    isShowing = false
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + config.duration) {
                        isShowing = false
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 18)
        .animation(config.animation, value: isShowing)
        .transition(config.transition)
    }
    
    struct Config {
        let textColor: Color
        let font: Font
        let backgroundColor: Color
        let duration: TimeInterval
        let transition: AnyTransition
        let animation: Animation
        let yOffset: CGFloat // vertical space from natural position (about 80 from bottom)
        let sysImg : String
        
        init(textColor: Color = .white,
             font: Font = .system(size: 24),
             backgroundColor: Color = .black.opacity(0.588),
             duration: TimeInterval = Toast.shortDuration,
             transition: AnyTransition = .opacity,
             animation: Animation = .linear(duration: 0.3),
             yOffset: CGFloat = -60,
             sysImg: String = "hare.fill"
        ) {
            self.textColor = textColor
            self.font = font
            self.backgroundColor = backgroundColor
            self.duration = duration
            self.transition = transition
            self.animation = animation
            self.yOffset = yOffset
            self.sysImg = sysImg
        }
    }
}

extension View {
    func toast(message: String,
               isShowing: Binding<Bool>,
               config: Toast.Config) -> some View {
        self.modifier(Toast(message: message, config: config, isShowing: isShowing))
    }
    
    func toast(message: String,
               sysImg: String,
               isShowing: Binding<Bool>,
               duration: TimeInterval) -> some View {
        self.modifier(Toast(message: message, config: .init(duration: duration, sysImg: sysImg), isShowing: isShowing))
    }
}
