# LUMOGUIDE 统一仓库

本仓库合并管理 LUMOGUIDE 项目的后端与移动端代码（完整保留两边提交历史）：

| 目录 | 内容 | 原仓库 |
|------|------|--------|
| `backend/` | Laravel 9 后端 + Web 前端（API/管理后台/SPA） | LUMOGUIDE (master) |
| `mobile/` | Flutter 移动端 App（iOS/Android） | LUMOGUIDE-frontend (main) |

## 与原子仓库同步

```bash
git subtree pull --prefix=backend backend master   # 拉取后端更新
git subtree pull --prefix=mobile mobile main       # 拉取移动端更新
```
