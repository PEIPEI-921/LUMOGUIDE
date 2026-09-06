# Android 15/16 Edge-to-Edge（無邊框）真機走查清單

> 背景：targetSdk/compileSdk=36，Android 15+ 強制無邊框；本清單供發版前真機（Android 15 與 16、含折疊/平板）逐一走查。

## 重點區域
- [ ] 狀態列：各頁面頂部文字/元件不與狀態列重疊（深色背景頁、圖片 banner 頁尤其檢查）
- [ ] 導覽列：底部按鈕/輸入列不被手勢導覽條遮擋（聊天輸入列、評論輸入框、發佈表單提交鈕）
- [ ] 彈窗/底部選單：Sheet、Dialog、Keyboard 避讓
- [ ] 全螢幕圖片/掃碼/播放器：正確沉浸
- [ ] 鍵盤彈起時輸入框不遮擋
- [ ] 旋轉/折疊（Android 16 大屏若支援方向）：資訊詳情、裁剪頁等

## 已執行記錄
- 2026-09-07 Samsung Galaxy S21 Ultra（SM-G998N / Android 15, API 34/36 目標）：安裝 1.0.13+34 Release 後冒煙（首頁/資訊/消息/我的輪詢正常、裁剪流程、深鏈冷/熱啟動）無崩潰、無明顯遮擋 —— **基礎通過，完整視覺清單待逐頁執行**。

## 建議工具
- 真機逐頁截圖比對
- Flutter 整合冒煙（`flutter test integration_test/app_smoke_test.dart -d <device>`）斷言渲染無異常
