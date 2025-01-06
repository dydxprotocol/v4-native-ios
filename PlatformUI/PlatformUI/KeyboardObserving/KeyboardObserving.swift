//
//  KeyboardObserving.swift
//  PlatformUI
//
//  Created by Rui Huang on 06/01/2025.
//

import Foundation
import SwiftUI
import UIKit

public enum KeyboardObservingMode {
    case yPadding, yOffset
}

extension View {
    public func keyboardObserving(offset: CGFloat = 0.0, mode: KeyboardObservingMode = .yPadding) -> some View {
        self.modifier(KeyboardObserving(offset: offset, mode: mode))
    }
}

struct KeyboardObserving: ViewModifier {
    
    let offset: CGFloat
    let mode: KeyboardObservingMode
    
    @State var keyboardHeight: CGFloat = 0
    @State var keyboardAnimationDuration: Double = 0
    
    func body(content: Content) -> some View {
        content
            .if(mode == .yPadding, transform: { content in
                content.padding([.bottom], keyboardHeight)
            })
            .if(mode == .yOffset, transform: { content in
                content.offset(y: -keyboardHeight)
            })
            .edgesIgnoringSafeArea((keyboardHeight > 0) ? [.bottom] : [])
            .animation(.easeOut(duration: keyboardAnimationDuration), value: keyboardHeight)
            .onReceive(
                NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)
                    .receive(on: RunLoop.main),
                perform: updateKeyboardHeight
            )
    }
    
    func updateKeyboardHeight(_ notification: Notification) {
        guard let info = notification.userInfo else { return }
        // Get the duration of the keyboard animation
        keyboardAnimationDuration = (info[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double)
        ?? 0.25
        
        guard let keyboardFrame = info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        else { return }
        // If the top of the frame is at the bottom of the screen, set the height to 0.
        if keyboardFrame.origin.y == UIScreen.main.bounds.height {
            keyboardHeight = 0
        } else {
            // IMPORTANT: This height will _include_ the SafeAreaInset height.
            keyboardHeight = keyboardFrame.height + offset
        }
    }
}
