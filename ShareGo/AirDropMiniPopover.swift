import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct AirDropMiniPopover: View {
    @State private var isTargeted = false
    var body: some View {
        ZStack {
            Color.clear // 전체 배경 투명
            // Glassy, circular background
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: 300, height: 300)
                .shadow(color: .black.opacity(0.22), radius: 24, y: 8)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .strokeBorder(Color.white.opacity(0.22), lineWidth: 2)
                        .blur(radius: 0.5)
                )
            VStack(spacing: 0) {
                Spacer()
                ZStack {
                    Image("logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 140, height: 140)
                        .shadow(radius: 8)
                }
                .frame(height: 140)
                Text("Drop to ShareGo")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.85))
                    .padding(.top, 8)
                Spacer()
            }
            .frame(width: 300, height: 300)
        }
        .frame(width: 300, height: 300)
        .onDrop(of: [UTType.fileURL], isTargeted: $isTargeted) { providers in
            for provider in providers {
                provider.loadDataRepresentation(forTypeIdentifier: UTType.fileURL.identifier) { data, error in
                    guard let data = data, let url = URL(dataRepresentation: data, relativeTo: nil) else { return }
                    DispatchQueue.main.async {
                        let sharing = NSSharingService(named: .sendViaAirDrop)
                        sharing?.perform(withItems: [url])
                    }
                }
            }
            return true
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isTargeted)
    }
} 