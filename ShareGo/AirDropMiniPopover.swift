import SwiftUI
import AppKit
import UniformTypeIdentifiers

// NSViewRepresentable로 드래그 지원 커스텀 뷰
class DraggableHostingView<Content: View>: NSHostingView<Content> {
    override func mouseDown(with event: NSEvent) {
        self.window?.performDrag(with: event)
    }
}

struct DraggableRepresentable<Content: View>: NSViewRepresentable {
    let content: Content
    func makeNSView(context: Context) -> DraggableHostingView<Content> {
        DraggableHostingView(rootView: content)
    }
    func updateNSView(_ nsView: DraggableHostingView<Content>, context: Context) {
        nsView.rootView = content
    }
}

struct AirDropMiniPopover: View {
    @State private var isTargeted = false
    var body: some View {
        DraggableRepresentable(content:
            ZStack {
                Color.clear
                // Circle을 약간 작게
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 270, height: 270)
                    .shadow(color: .black.opacity(0.22), radius: 24, y: 8)
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
                .padding(.vertical, 32)
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
        )
    }
} 