import SwiftUI

struct AppWallpaperView: View {
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.06, green: 0.12, blue: 0.24),
                        Color(red: 0.06, green: 0.28, blue: 0.33),
                        Color(red: 0.16, green: 0.19, blue: 0.44)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                LinearGradient(
                    colors: [
                        Color(red: 0.99, green: 0.78, blue: 0.58).opacity(0.18),
                        Color.clear,
                        Color(red: 0.42, green: 0.84, blue: 0.92).opacity(0.14)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 0.49, green: 0.95, blue: 0.87).opacity(0.92),
                                Color(red: 0.49, green: 0.95, blue: 0.87).opacity(0.0)
                            ],
                            center: .center,
                            startRadius: 40,
                            endRadius: 380
                        )
                    )
                    .frame(width: proxy.size.width * 1.02, height: proxy.size.width * 1.02)
                    .offset(x: -proxy.size.width * 0.28, y: -proxy.size.height * 0.28)
                    .blur(radius: 28)

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 1.00, green: 0.73, blue: 0.56).opacity(0.72),
                                Color(red: 1.00, green: 0.73, blue: 0.56).opacity(0.0)
                            ],
                            center: .center,
                            startRadius: 30,
                            endRadius: 340
                        )
                    )
                    .frame(width: proxy.size.width * 0.88, height: proxy.size.width * 0.88)
                    .offset(x: proxy.size.width * 0.34, y: -proxy.size.height * 0.18)
                    .blur(radius: 24)

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 0.56, green: 0.72, blue: 1.00).opacity(0.62),
                                Color(red: 0.56, green: 0.72, blue: 1.00).opacity(0.0)
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 300
                        )
                    )
                    .frame(width: proxy.size.width * 0.74, height: proxy.size.width * 0.74)
                    .offset(x: proxy.size.width * 0.22, y: proxy.size.height * 0.22)
                    .blur(radius: 26)

                RoundedRectangle(cornerRadius: proxy.size.width * 0.28, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.18),
                                Color(red: 0.49, green: 0.95, blue: 0.87).opacity(0.06),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: proxy.size.width * 0.95, height: proxy.size.height * 0.44)
                    .rotationEffect(.degrees(-16))
                    .offset(x: -proxy.size.width * 0.18, y: proxy.size.height * 0.24)
                    .blur(radius: 14)

                RoundedRectangle(cornerRadius: proxy.size.width * 0.22, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 1.00, green: 0.85, blue: 0.70).opacity(0.20),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: proxy.size.width * 0.86, height: proxy.size.height * 0.30)
                    .rotationEffect(.degrees(19))
                    .offset(x: proxy.size.width * 0.22, y: proxy.size.height * 0.30)
                    .blur(radius: 8)

                AppWaveShape(amplitude: 26, frequency: 1.2, phase: 0.15)
                    .stroke(Color.white.opacity(0.16), lineWidth: 1.4)
                    .frame(height: proxy.size.height * 0.28)
                    .offset(y: proxy.size.height * 0.18)

                AppWaveShape(amplitude: 18, frequency: 1.55, phase: 0.65)
                    .stroke(Color(red: 0.78, green: 0.95, blue: 1.00).opacity(0.12), lineWidth: 1.0)
                    .frame(height: proxy.size.height * 0.2)
                    .offset(y: proxy.size.height * 0.28)

                LinearGradient(
                    colors: [Color.clear, Color.black.opacity(0.18)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        }
        .ignoresSafeArea()
    }
}

struct AppWaveShape: Shape {
    var amplitude: CGFloat
    var frequency: CGFloat
    var phase: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let midY = rect.midY
        path.move(to: CGPoint(x: 0, y: midY))

        for x in stride(from: 0, through: rect.width, by: 1) {
            let relativeX = x / rect.width
            let angle = (relativeX * .pi * 2 * frequency) + (phase * .pi * 2)
            let y = midY + sin(angle) * amplitude
            path.addLine(to: CGPoint(x: x, y: y))
        }

        return path
    }
}

extension View {
    func appCardStyle() -> some View {
        self
            .background(Color.white.opacity(0.10))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.07), lineWidth: 1)
            )
            .cornerRadius(12)
    }
}

func formatMinutes(_ minutes: Int) -> String {
    if minutes < 60 {
        return "\(minutes)m"
    } else if minutes < 1440 {
        let h = minutes / 60; let m = minutes % 60
        return m > 0 ? "\(h)h \(m)m" : "\(h)h"
    } else if minutes < 10080 {
        let d = minutes / 1440; let h = (minutes % 1440) / 60
        return h > 0 ? "\(d)d \(h)h" : "\(d)d"
    } else if minutes < 43800 {
        let w = minutes / 10080; let d = (minutes % 10080) / 1440
        return d > 0 ? "\(w)w \(d)d" : "\(w)w"
    } else if minutes < 525600 {
        let mo = minutes / 43800; let w = (minutes % 43800) / 10080
        return w > 0 ? "\(mo)mo \(w)w" : "\(mo)mo"
    } else {
        let y = minutes / 525600; let mo = (minutes % 525600) / 43800
        return mo > 0 ? "\(y)y \(mo)mo" : "\(y)y"
    }
}

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isDisabled: Bool = false
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding()
                .background(isDisabled ? Color.gray.opacity(0.3) : Color.white)
                .cornerRadius(16)
        }
        .disabled(isDisabled)
        .padding(.horizontal)
    }
}

struct OptionCard: View {
    let title: String
    let icon: String?
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(isSelected ? .black : .white)
                        .frame(width: 32)
                }
                
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .black : .white)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.black)
                }
            }
            .padding()
            .background(isSelected ? Color.white : Color.white.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.white : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
