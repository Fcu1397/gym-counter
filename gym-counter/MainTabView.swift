//
//  MainTabView.swift
//  gym-counter
//
import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            ExerciseSelectionView()
                .tabItem {
                    Label("運動", systemImage: "figure.run")
                }
            
            StatsView()
                .tabItem {
                    Label("統計", systemImage: "chart.bar.fill")
                }
        }
    }
}

#Preview {
    MainTabView()
}
