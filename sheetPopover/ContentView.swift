//
//  ContentView.swift
//  sheetPopover
//
//  Created by Jake Woodall on 3/18/26.
//

import SwiftUI

struct ContentView: View {
    @State private var isExpanded = false
    @Namespace private var animation
    
    var body: some View {
        ZStack {
            
            // Background content
            Color.black.ignoresSafeArea()
            
            // Mini Player
            VStack {
                Spacer()
                
                MiniPlayerView(
                    isExpanded: $isExpanded,
                    namespace: animation,
                    title: "Minecraft",
                    subtitle: "01:26",
                    image: Image("album")
                )
                .padding()
            }
            
            // Expanded View (overlay)
            if isExpanded {
                ExpandedPlayerView(
                    isExpanded: $isExpanded,
                    namespace: animation,
                    title: "Minecraft",
                    subtitle: "01:26",
                    image: Image("album")
                )
                .zIndex(1)
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.85), value: isExpanded)
    }
}

struct MiniPlayerView: View {
    @Binding var isExpanded: Bool
    var namespace: Namespace.ID
    var title: String
    var subtitle: String
    var image: Image
    var body: some View {
        HStack(spacing: 12) {
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .matchedGeometryEffect(id: "art", in: namespace)
                .onTapGesture {
                    withAnimation {
                        isExpanded = true
                    }
                }
            VStack(alignment: .leading) {
                Text(title)
                Text(subtitle)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.white)
                .matchedGeometryEffect(id: "background", in: namespace)
        )
    }
}

#Preview {
    ContentView()
}

struct ExpandedPlayerView: View {
    @State private var offset: CGFloat = 0
    @Binding var isExpanded: Bool
    var namespace: Namespace.ID
    var title: String
    var subtitle: String
    var image: Image
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 0)
                .fill(Color.green)
                .ignoresSafeArea()
                .matchedGeometryEffect(id: "background", in: namespace)
            VStack(spacing: 20) {
                Spacer()
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 300, height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .matchedGeometryEffect(id: "art", in: namespace)
                Text(title)
                    .font(.title)
                Text(subtitle)
                    .foregroundStyle(.secondary)
                
                Spacer()
            }
            .padding()
        }
        .offset(y: offset)
        .onTapGesture {
            withAnimation {
                isExpanded = false
            }
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    // Only allow downward drag
                    if value.translation.height > 0 {
                        offset = value.translation.height
                    }
                }
                .onEnded { value in
                    let velocity = value.velocity.height
                    
                    if value.translation.height > 150 || velocity > 800 {
                        // Dismiss → triggers morph back
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                            isExpanded = false
                        }
                    }
                    
                    // Snap back if not dismissed
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                        offset = 0
                    }
                }
        )
    }
}
