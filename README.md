# 💪 Gym Counter

一個簡潔易用的 iOS 健身計數應用程式，幫助您追蹤和管理運動訓練。

## ✨ 主要功能

### 📱 核心功能
- **運動追蹤**：記錄各種運動的次數和組數
- **計時器**：支援倒數計時和正數計時
- **歷史記錄**：完整保存所有訓練歷史
- **統計分析**：視覺化您的訓練數據和進度
- **多種運動類型**：預設包含伏地挺身、仰臥起坐、深蹲等常見運動

### 🎯 Widget 支援

應用程式提供 **6 種不同的主畫面 Widget**，讓您快速訪問各項功能：

#### 1. 📊 運動統計 Widget
- **尺寸**：Small / Medium / Large
- **功能**：顯示圖表式統計數據
- **Deep Link**：`gymcounter://stats`

#### 2. 🏃 快速開始 Widget
- **尺寸**：Small
- **功能**：快速開始最近的運動
- **Deep Link**：`gymcounter://exercise`

#### 3. 🎯 今日目標 Widget
- **尺寸**：Small
- **功能**：顯示今日運動進度（圓形進度條）
- **Deep Link**：`gymcounter://stats`

#### 4. 📈 統計資料 Widget
- **尺寸**：Small / Medium
- **功能**：顯示詳細的文字統計數據
- **Deep Link**：`gymcounter://stats`

#### 5. ➕ 新增運動 Widget
- **尺寸**：Small
- **功能**：快速打開新增運動頁面
- **Deep Link**：`gymcounter://add-exercise`

#### 6. 📊 統計資料快捷 Widget
- **尺寸**：Small
- **功能**：快速打開統計資料頁面
- **Deep Link**：`gymcounter://statistics`

## 🔗 Deep Link 支援

應用程式支援以下 URL Scheme，可通過 Widget 或外部應用啟動：

| Deep Link | 功能 |
|-----------|------|
| `gymcounter://exercise` | 跳轉到運動選擇頁面 |
| `gymcounter://stats` | 跳轉到統計頁面 |
| `gymcounter://add-exercise` | 開啟新增運動彈窗 |
| `gymcounter://statistics` | 開啟統計資料彈窗 |

## 🛠️ 技術架構

- **語言**：Swift
- **框架**：SwiftUI
- **數據持久化**：SwiftData
- **最低支援版本**：iOS 17.0+
- **Widget Extension**：WidgetKit

### 主要模型

```swift
// 運動類型
ExerciseType {
    - name: String
    - icon: String
    - targetSets: Int
    - targetReps: Int
}

// 訓練記錄
WorkoutSession {
    - exerciseType: ExerciseType?
    - sets: [ExerciseSet]
    - timestamp: Date
    - totalReps: Int
}

// 單組訓練
ExerciseSet {
    - reps: Int
    - timestamp: Date
}
```

## 📁 專案結構

```
gym-counter/
├── gym-counter/              # 主應用程式
│   ├── App/
│   │   └── gym_counterApp.swift
│   ├── Models/
│   │   ├── ExerciseType.swift
│   │   ├── WorkoutSession.swift
│   │   └── ExerciseSet.swift
│   ├── Views/
│   │   ├── MainTabView.swift
│   │   ├── ExerciseSelectionView.swift
│   │   ├── CounterView.swift
│   │   ├── StatsView.swift
│   │   └── HistoryView.swift
│   └── Components/
│       └── TimerView.swift
│
├── gym-counterWidget/        # Widget Extension
│   ├── GymCounterWidgetBundle.swift
│   ├── GymCounterWidget.swift
│   ├── QuickStartWidget.swift
│   ├── TodayGoalWidget.swift
│   ├── StatsDataWidget.swift
│   ├── AddExerciseWidget.swift
│   ├── StatisticsWidget.swift
│   └── SharedModels.swift
│
└── gym-counter.xcodeproj/    # Xcode 專案配置
```

## 🚀 安裝與運行

### 系統需求
- macOS 14.0+
- Xcode 15.0+
- iOS 17.0+ 模擬器或實機

### 安裝步驟

1. **Clone 專案**
```bash
git clone [repository-url]
cd gym-counter
```

2. **打開專案**
```bash
open gym-counter.xcodeproj
```

3. **編譯並運行**
- 按 `⌘ + R` 或點擊 Run 按鈕
- 選擇目標設備（模擬器或實機）

### 添加 Widget

1. 長按 iPhone 主畫面
2. 點擊左上角 "+" 按鈕
3. 搜尋 "gym-counter" 或向下滾動找到應用
4. 選擇您想要的 Widget 類型和尺寸
5. 點擊 "加入 Widget"

## 📖 使用說明

### 基本使用流程

1. **選擇運動**
   - 在首頁選擇您要訓練的運動類型
   - 或點擊 "+" 新增自訂運動

2. **開始訓練**
   - 進入計數頁面
   - 點擊畫面增加次數
   - 完成一組後點擊 "完成本組"
   - 可使用計時器功能輔助訓練

3. **查看統計**
   - 切換到統計頁面
   - 查看訓練圖表和數據分析
   - 了解運動趨勢和進度

4. **歷史記錄**
   - 在歷史頁面查看所有訓練記錄
   - 可按日期篩選
   - 查看詳細的訓練數據

## 🎨 設計特色

- **簡潔介面**：直觀的操作流程
- **數據視覺化**：清晰的圖表展示
- **主題一致性**：統一的色彩和設計語言
- **響應式設計**：適配不同尺寸的 iOS 設備

## 🔄 更新日誌

### Version 1.0.0
- ✅ 基本運動追蹤功能
- ✅ 計時器功能
- ✅ 統計分析功能
- ✅ 6 種主畫面 Widget
- ✅ Deep Link 支援
- ✅ SwiftData 數據持久化

## 👨‍💻 開發

- **開發工具**：Xcode
- **版本控制**：Git
- **架構模式**：MVVM with SwiftUI
