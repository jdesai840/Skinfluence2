//
//  Toast.swift
//  Skinfluence
//
//  Created by Jay Desai on 8/24/25.
//

import SwiftUI

// MARK: - Toast Style
enum ToastStyle {
    case success
    case error
    case info
    case warning
    
    var backgroundColor: Color {
        switch self {
        case .success:
            return Color.green
        case .error:
            return Color.red
        case .info:
            return Theme.primary
        case .warning:
            return Color.orange
        }
    }
    
    var iconName: String {
        switch self {
        case .success:
            return "checkmark.circle.fill"
        case .error:
            return "xmark.circle.fill"
        case .info:
            return "info.circle.fill"
        case .warning:
            return "exclamationmark.triangle.fill"
        }
    }
}

// MARK: - Toast Message
struct ToastMessage: Equatable {
    let id = UUID()
    let text: String
    let style: ToastStyle
    let duration: TimeInterval
    
    init(text: String, style: ToastStyle = .info, duration: TimeInterval = 3.0) {
        self.text = text
        self.style = style
        self.duration = duration
    }
}

// MARK: - Toast View
struct ToastView: View {
    let message: ToastMessage
    let onDismiss: () -> Void
    @State private var offset: CGFloat = -100
    
    var body: some View {
        HStack(spacing: Theme.spacing12) {
            Image(systemName: message.style.iconName)
                .foregroundColor(.white)
            
            Text(message.text)
                .font(Theme.bodyFont)
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
            
            Spacer()
            
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(Theme.spacing16)
        .background(message.style.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium))
        .shadow(color: Theme.shadowColor, radius: Theme.shadowRadius, y: Theme.shadowY)
        .padding(.horizontal, Theme.spacing20)
        .offset(y: offset)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                offset = 0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + message.duration) {
                dismissToast()
            }
        }
        .onTapGesture {
            dismissToast()
        }
    }
    
    private func dismissToast() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            offset = -100
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onDismiss()
        }
    }
}

// MARK: - Toast Manager
class ToastManager: ObservableObject {
    @Published var messages: [ToastMessage] = []
    
    func show(_ message: ToastMessage) {
        messages.append(message)
    }
    
    func show(text: String, style: ToastStyle = .info, duration: TimeInterval = 3.0) {
        let message = ToastMessage(text: text, style: style, duration: duration)
        show(message)
    }
    
    func dismiss(_ message: ToastMessage) {
        messages.removeAll { $0.id == message.id }
    }
}

// MARK: - Toast Container
struct ToastContainer<Content: View>: View {
    @StateObject private var toastManager = ToastManager()
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            content
                .environmentObject(toastManager)
            
            VStack(spacing: Theme.spacing8) {
                ForEach(toastManager.messages, id: \.id) { message in
                    ToastView(message: message) {
                        toastManager.dismiss(message)
                    }
                }
            }
            .zIndex(1)
        }
    }
}