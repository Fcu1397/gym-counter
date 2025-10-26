//
//  MainTabView.swift
//  gym-counter
//
import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Tab = .exercise
    @State private var showAddExercise = false
    @State private var showStatistics = false
    
    enum Tab {
        case exercise
        case stats
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ExerciseSelectionView(
                showingAddExercise: $showAddExercise,
                showingStatistics: $showStatistics
            )
                .tabItem {
                    Label("運動", systemImage: "figure.run")
                }
                .tag(Tab.exercise)
            
            StatsView()
                .tabItem {
                    Label("統計", systemImage: "chart.bar.fill")
                }
                .tag(Tab.stats)
        }
        .onOpenURL { url in
            handleDeepLink(url)
        }
    }
    
    private func handleDeepLink(_ url: URL) {
        guard url.scheme == "gymcounter" else { return }
        
        switch url.host {
        case "stats":
            selectedTab = .stats
        case "exercise":
            selectedTab = .exercise
        case "add-exercise":
            // 先切換到運動頁面
            selectedTab = .exercise
            // 延遲一下再顯示新增運動頁面，確保頁面已經切換
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showAddExercise = true
            }
        case "statistics":
            // 先切換到運動頁面
            selectedTab = .exercise
            // 延遲一下再顯示統計資料頁面
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showStatistics = true
            }
        default:
            break
        }
    }
}

#Preview {
    MainTabView()
}
