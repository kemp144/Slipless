import SwiftUI

struct WallpaperTestView: View {
    var body: some View {
        ZStack {
            AppWallpaperView()

            VStack(spacing: 10) {
                Text("Slipless Wallpaper Preview")
                    .font(.headline)
                    .foregroundColor(.white)
                Text("If this screen is black, the issue is not image loading.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.78))
            }
            .padding(20)
            .background(Color.black.opacity(0.22))
            .cornerRadius(16)
            .padding()
        }
    }
}

#Preview("Wallpaper Test") {
    WallpaperTestView()
}
