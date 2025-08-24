import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    
    var body: some View {
        if isActive {
            ContentView()
        } else {
            VStack {
                Image("logohabify")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                Text("Habify")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(AppColorTheme.textColor)
                Text("Build your habits, grow every day")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        isActive = true
                    }
                }
            }
        }
    }
}
