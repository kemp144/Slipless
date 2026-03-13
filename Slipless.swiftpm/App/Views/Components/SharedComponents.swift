import SwiftUI

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
