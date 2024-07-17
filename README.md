# ETToday - Small Project

## Architecture Overview

此專案是參考 Clean Architecture ，將各個 layer 切分開來，利用抽象介面來進行 layer 間的溝通，達成低耦合性且易測試。Presentation layer 是使用 MVVM + RxSwift 的方式處理畫面以及資料 binding 的邏輯。

## Architecture UML Diagram:
![Architecture UML diagram](https://github.com/user-attachments/assets/f5db119e-8597-4328-a476-178da2bdbba8)

## 操作影片
https://github.com/user-attachments/assets/32791938-0d94-461c-9a83-6ac26d395037

## Note
- 在連續輸入搜尋文字時，使用 0.3 秒的延遲，可以減少打 API 的 Overhead。
- MusicDTO 的參數都是 optional，因為不清楚 API 那邊回傳的 Json 格式是不是每一個參數都會有值。

## Future Improvement
### 模組化架構
- 可以把 Presentation, Domain, Data 資料夾變成一個 Swift package manager，往模組化架構方向前進 (Vertical slice)。
- 可以把 Network 資料夾變成有個 Swift package manager，往模組化架構方向前進。
---
- 整理顯示的 Hardcoded String 在統一的地方，Constraints 的 CGFloat 同理
- Domain layer 可以選擇不用 RxSwift，減少與 RxSwift 的依賴關係
- 音檔播放完畢後，UI 顯示多一個 Replay 的狀態，使用者可以重新播放

## AI 的幫助
- 對於 RxTest 的使用方法
- 毫秒轉分鍾的 function
- AVPlayer 的使用方法

## Third-party Dependencies
- [RxSwift](https://github.com/ReactiveX/RxSwift)
- [RxDatasource](https://github.com/RxSwiftCommunity/RxDataSources)
- [Kingfisher](https://github.com/onevcat/Kingfisher)

## System Requirements
- Xcode 15.4
- Minimum deployment target 17.5
- Swift 5.6
