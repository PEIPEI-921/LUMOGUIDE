# share.html 更新說明（2026-08-02 v3）

## 問題

線上 `https://lumoguide.com/share` 頁面的「打開 LUMOGUIDE App」按鈕在 iOS Safari 中點擊無反應。

## 修改內容

1. **`<a>` 改為 `<button>`** — `<a href="#">` 在 iOS Safari 會干擾點擊事件
2. **按鈕點擊改用直接跳轉** — 有用戶手勢時 `window.location.href` 最可靠
3. **新增 spinner 載入動畫** — 頁面打開時先顯示「正在打開 LUMOGUIDE…」，2.5 秒後未成功才顯示按鈕
4. **Android 增加 `intent://` 雙通道** — 提高打開 App 成功率
5. **按鈕文字更新** — 「打開 LUMOGUIDE App」→「在 LUMOGUIDE App 中打開」
6. **保留微信內引導** — 微信內無法打開 App，提示用瀏覽器開啟
7. **保留 localStorage 參數保存** — App 安裝後可恢復 deep link

## 部署方式

將附件 `share.html` 替換服務器上對應文件即可，無需重啟服務。

文件路徑應為 `https://lumoguide.com/share` 路由對應的模板文件。
