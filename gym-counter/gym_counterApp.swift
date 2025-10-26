//
//  gym_counterApp.swift
//  gym-counter
//

import SwiftUI
import SwiftData

@main
struct GymCounterApp: App {
    // MARK: - App Group Configuration
    
    /// App Group Identifier - 用於 App 和 Widget 之間共享資料
    /// 記得在 Xcode 中啟用 App Groups 並使用相同的 identifier
    static let appGroupIdentifier = "group.com.buildwithashton.gym-counter"
    
    // MARK: - Shared Model Container
    
    /// 共享的 SwiftData 容器 (App 和 Widget 都使用此容器)
    let sharedModelContainer: ModelContainer = {
        let schema = Schema([
            ExerciseType.self,
            WorkoutSession.self
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            groupContainer: .identifier(GymCounterApp.appGroupIdentifier),
            cloudKitDatabase: .none
        )
        
        do {
            let container = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
            
            // 首次啟動時插入預設資料
            GymCounterApp.insertDefaultDataIfNeeded(container: container)
            
            return container
        } catch {
            fatalError("無法創建 ModelContainer: \(error)")
        }
    }()
    
    // MARK: - Body
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(sharedModelContainer)
    }
    
    // MARK: - Helper Methods
    
    /// 首次啟動時插入預設運動類型
    static func insertDefaultDataIfNeeded(container: ModelContainer) {
        let context = ModelContext(container)
        
        // 檢查是否已有資料
        let fetchDescriptor = FetchDescriptor<ExerciseType>()
        
        do {
            let existingExercises = try context.fetch(fetchDescriptor)
            
            // 如果沒有資料，插入預設運動類型
            if existingExercises.isEmpty {
                print("📝 首次啟動，插入預設運動類型...")
                
                for (index, exercise) in ExerciseType.sampleExercises.enumerated() {
                    exercise.sortOrder = index + 1
                    context.insert(exercise)
                }
                
                try context.save()
                print("✅ 預設運動類型已插入")
            }
        } catch {
            print("❌ 檢查或插入預設資料失敗: \(error)")
        }
    }
}

// MARK: - Shared Container Helper (供 Widget 使用)

extension GymCounterApp {
    /// 取得共享的 ModelContainer (供 Widget 使用)
    static func createSharedContainer() throws -> ModelContainer {
        let schema = Schema([
            ExerciseType.self,
            WorkoutSession.self
        ])
        
        // 暫時使用本地存儲
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            
             groupContainer: .identifier(GymCounterApp.appGroupIdentifier),
             cloudKitDatabase: .none
        )
        
        return try ModelContainer(
            for: schema,
            configurations: [modelConfiguration]
        )
    }
}
