import SwiftUI

struct FabView: View {
    var title: String?
        var action: () -> Void
        @Environment(\.colorScheme) private var colorScheme
        
        var body: some View {
            Button(action: action) {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .bold))
                    
                    if let title = title {
                        Text(title)
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
                .foregroundColor(.white)
                .padding(.horizontal, title == nil ? 18 : 20)
                .padding(.vertical, 18)
                .background(
                    RoundedRectangle(cornerRadius: title == nil ? 30 : 25)
                        .fill(
                            LinearGradient(
                                colors: colorScheme == .dark
                                    ? [Color.cyan.opacity(0.8), Color.blue.opacity(0.7)]
                                    : [Color.blue, Color.blue.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(
                            color: (colorScheme == .dark ? Color.cyan : Color.blue).opacity(0.3),
                            radius: 12,
                            x: 0,
                            y: 6
                        )
                )
            }
        }
}
