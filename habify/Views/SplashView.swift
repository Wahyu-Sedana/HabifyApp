import SwiftUI

struct SplashView: View {
    @StateObject private var databaseManager = DatabaseManager.shared
    @State private var isActive = false
    @State private var logoScale: CGFloat = 0.8
    @State private var logoOpacity = 0.5
    @State private var textOffset: CGFloat = 20
    @State private var textOpacity = 0.0
    @State private var backgroundOpacity = 0.0
    @State private var circleScale: CGFloat = 0.5
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        if isActive {
            ContentView()
                .transition(.opacity)
                .environmentObject(databaseManager)
        } else {
            ZStack {
                // Adaptive gradient background
                LinearGradient(
                    colors: colorScheme == .dark ? [
                        Color(red: 0.05, green: 0.05, blue: 0.1),
                        Color(red: 0.1, green: 0.1, blue: 0.15),
                        Color(red: 0.08, green: 0.08, blue: 0.12)
                    ] : [
                        Color.white,
                        Color(red: 0.98, green: 0.98, blue: 1.0),
                        Color(red: 0.95, green: 0.97, blue: 1.0)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                .opacity(backgroundOpacity)
                
                // Adaptive ambient glow circles
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: colorScheme == .dark ? [
                                    Color.blue.opacity(0.25),
                                    Color.purple.opacity(0.15)
                                ] : [
                                    Color.blue.opacity(0.1),
                                    Color.purple.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 300, height: 300)
                        .scaleEffect(circleScale)
                        .blur(radius: colorScheme == .dark ? 25 : 20)
                        .offset(x: -100, y: -150)
                    
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: colorScheme == .dark ? [
                                    Color.cyan.opacity(0.2),
                                    Color.blue.opacity(0.12)
                                ] : [
                                    Color.green.opacity(0.08),
                                    Color.blue.opacity(0.04)
                                ],
                                startPoint: .bottomLeading,
                                endPoint: .topTrailing
                            )
                        )
                        .frame(width: 250, height: 250)
                        .scaleEffect(circleScale * 0.8)
                        .blur(radius: colorScheme == .dark ? 20 : 15)
                        .offset(x: 120, y: 200)
                    
                    // Additional glow for dark mode
                    if colorScheme == .dark {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.indigo.opacity(0.15),
                                        Color.purple.opacity(0.08)
                                    ],
                                    startPoint: .center,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 180, height: 180)
                            .scaleEffect(circleScale * 0.6)
                            .blur(radius: 30)
                            .offset(x: 0, y: 100)
                    }
                }
                .opacity(backgroundOpacity)
                
                VStack(spacing: 24) {
                    ZStack {
                        // Adaptive logo container
                        Circle()
                            .fill(
                                colorScheme == .dark ?
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.15, green: 0.15, blue: 0.2),
                                        Color(red: 0.12, green: 0.12, blue: 0.18)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ) :
                                LinearGradient(
                                    colors: [Color.white, Color.white],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 180, height: 180)
                            .shadow(
                                color: colorScheme == .dark ?
                                    Color.blue.opacity(0.3) :
                                    Color.black.opacity(0.08),
                                radius: colorScheme == .dark ? 25 : 20,
                                x: 0,
                                y: 8
                            )
                            .if(colorScheme == .dark) { view in
                                view.shadow(
                                    color: Color.black.opacity(0.4),
                                    radius: 15,
                                    x: 0,
                                    y: 8
                                )
                            }
                            .scaleEffect(logoScale * 1.1)
                        
                        Image("logohabify")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .scaleEffect(logoScale)
                            .opacity(logoOpacity)
                    }
                    
                    VStack(spacing: 12) {
                        Text("Habify")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: colorScheme == .dark ? [
                                        Color.white,
                                        Color(red: 0.9, green: 0.95, blue: 1.0)
                                    ] : [
                                        Color(red: 0.2, green: 0.2, blue: 0.3),
                                        Color(red: 0.4, green: 0.4, blue: 0.5)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .opacity(textOpacity)
                            .offset(y: textOffset)
                        
                        Text("Build your habits, grow every day")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(
                                colorScheme == .dark ?
                                    Color(red: 0.7, green: 0.75, blue: 0.8) :
                                    Color.secondary
                            )
                            .multilineTextAlignment(.center)
                            .opacity(textOpacity * 0.8)
                            .offset(y: textOffset)
                    }
                    
                    // Adaptive loading indicator
                    HStack(spacing: 8) {
                        ForEach(0..<3) { index in
                            Circle()
                                .fill(
                                    colorScheme == .dark ?
                                    LinearGradient(
                                        colors: [
                                            Color.cyan.opacity(0.8),
                                            Color.blue.opacity(0.6)
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    ) :
                                    LinearGradient(
                                        colors: [
                                            Color.blue.opacity(0.6),
                                            Color.blue.opacity(0.6)
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: 8, height: 8)
                                .scaleEffect(logoScale)
                                .if(colorScheme == .dark) { view in
                                    view.shadow(
                                        color: Color.cyan.opacity(0.4),
                                        radius: 3,
                                        x: 0,
                                        y: 0
                                    )
                                }
                                .animation(
                                    .easeInOut(duration: 0.6)
                                    .repeatForever()
                                    .delay(Double(index) * 0.2),
                                    value: logoScale
                                )
                        }
                    }
                    .opacity(textOpacity)
                    .offset(y: textOffset)
                    .padding(.top, 20)
                }
            }
            .onAppear {
                startAnimations()
            }
        }
    }
    
    private func startAnimations() {
        withAnimation(.easeOut(duration: 0.3)) {
            backgroundOpacity = 1.0
        }
        
        withAnimation(.easeOut(duration: 1.2).delay(0.2)) {
            circleScale = 1.0
        }
        
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.3)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }
        
        withAnimation(.easeOut(duration: 0.6).delay(0.6)) {
            textOffset = 0
            textOpacity = 1.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeInOut(duration: 0.5)) {
                isActive = true
            }
        }
    }
}

extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
