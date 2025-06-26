import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image("logo")
                .resizable()
                .frame(width: 100, height: 100)
                .cornerRadius(20)
                .shadow(radius: 8)
            Text("Airgo")
                .font(.system(size: 36, weight: .bold))
                .padding(.top, 8)
            Text("Version 1.0")
                .font(.title2)
                .foregroundColor(.gray)
            Text("All rights reserved, 2025 gojaehyun")
                .font(.body)
                .foregroundColor(.gray)
            Text("Made by Gojaehyun, who loves Jesus")
                .font(.callout)
                .foregroundColor(.gray)
                .padding(.top, 8)
        }
        .padding(40)
        .frame(width: 380, height: 420)
        .background(Color(NSColor.windowBackgroundColor))
    }
} 