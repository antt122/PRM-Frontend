# Fix: API Gateway Routes cho Creator Dashboard

## 🐛 Vấn đề

Khi truy cập Creator Dashboard, Flutter gọi API nhưng nhận được **404 Not Found**:

```
GET http://localhost:5010/api/creator/podcasts/my-podcasts 404 (Not Found)
```

### Root Cause

Backend chạy qua **Docker với API Gateway** (Ocelot), không chạy trực tiếp.

Flutter API service có URL **sai prefix**, không khớp với routes trong Gateway:

**❌ URL cũ (SAI):**
```dart
_creatorPodcastsUrl => '$_creatorApiUrl/creator/podcasts'
// Kết quả: http://localhost:5010/api/creator/podcasts/my-podcasts
```

**✅ Gateway route yêu cầu:**
```json
"UpstreamPathTemplate": "/api/content/creator/podcasts/{everything}"
// Cần: http://localhost:5010/api/content/creator/podcasts/my-podcasts
```

Thiếu prefix `/content` → 404!

---

## ✅ Giải pháp

### 1. Sửa Creator Podcasts URL

**File:** `lib/services/api_service.dart`

```dart
// ❌ CŨ (SAI)
static String get _creatorPodcastsUrl => '$_creatorApiUrl/creator/podcasts';

// ✅ MỚI (ĐÚNG)
static String get _creatorPodcastsUrl => '$_baseUrl/content/creator/podcasts';
```

**Giải thích:**
- `_baseUrl` = `http://localhost:5010/api` (từ `.env`)
- `_creatorPodcastsUrl` = `http://localhost:5010/api/content/creator/podcasts` ✅
- URL cuối: `http://localhost:5010/api/content/creator/podcasts/my-podcasts` ✅

### 2. Sửa Creator Application URL

**File:** `lib/services/api_service.dart`

```dart
// ❌ CŨ (SAI)
static String get _creatorApplicationUrl => '$_creatorApiUrl/CreatorApplications';

// ✅ MỚI (ĐÚNG)
static String get _creatorApplicationUrl => '$_userUrl/CreatorApplications';
```

**Gateway route:**
```json
{
  "UpstreamPathTemplate": "/api/user/CreatorApplications/{everything}",
  "DownstreamPathTemplate": "/api/CreatorApplications/{everything}"
}
```

### 3. Xóa biến không dùng

```dart
// ❌ XÓA (không còn dùng)
static String get _creatorApiUrl => '$_baseUrl';
```

---

## 📋 API Routes Map (Gateway → Backend)

| Flutter Endpoint | Gateway Upstream | Backend Downstream |
|------------------|------------------|-------------------|
| `/api/content/creator/podcasts/my-podcasts` | `/api/content/creator/podcasts/{everything}` | `/api/creator/podcasts/{everything}` |
| `/api/content/creator/podcasts` | `/api/content/creator/podcasts` | `/api/creator/podcasts` |
| `/api/user/CreatorApplications` | `/api/user/CreatorApplications/{everything}` | `/api/CreatorApplications/{everything}` |
| `/api/cms/posts/my-posts` | *(not defined yet)* | `/api/cms/posts/my-posts` |

---

## 🧪 Testing

### 1. Kiểm tra URL mới

**Hot reload Flutter app:**
```bash
# Trong VS Code terminal với Flutter app đang chạy
r  # Hot reload
```

**Kiểm tra console log:**
```
[getMyPodcasts] URL: http://localhost:5010/api/content/creator/podcasts/my-podcasts?page=1&pageSize=20
[getMyPodcasts] Status: 200 ✅
```

### 2. Kiểm tra Gateway route

**Xem Gateway logs:**
```bash
docker logs -f healink-gateway
```

**Kiểm tra route được match:**
```
[2025-10-17 10:30:15] GET /api/content/creator/podcasts/my-podcasts
[2025-10-17 10:30:15] Matched route: /api/content/creator/podcasts/{everything}
[2025-10-17 10:30:15] Downstream: http://contentservice-api:80/api/creator/podcasts/my-podcasts
[2025-10-17 10:30:15] Response: 200 OK
```

### 3. Test các chức năng

- ✅ Login as ContentCreator
- ✅ Mở Creator Dashboard → Hiển thị danh sách podcasts
- ✅ Pagination hoạt động (nếu có > 20 podcasts)
- ✅ Click vào podcast card → Navigate to detail
- ✅ Không có lỗi 404 trong console

---

## 🔍 Debugging Tips

### Nếu vẫn 404

1. **Kiểm tra Gateway có chạy không:**
   ```bash
   docker ps | grep gateway
   curl http://localhost:5010/health
   ```

2. **Kiểm tra ContentService có chạy không:**
   ```bash
   docker ps | grep contentservice
   docker logs healink-contentservice
   ```

3. **Kiểm tra Redis có user state không:**
   ```bash
   docker exec -it healink-redis redis-cli
   GET "UserState:your-user-id"
   ```

4. **Kiểm tra JWT token hợp lệ:**
   - Decode token tại https://jwt.io
   - Kiểm tra field `nameid` (userId)
   - Kiểm tra `exp` chưa hết hạn

### Nếu vẫn 403 Forbidden

- User chưa có role "ContentCreator" trong Redis cache
- Token hết hạn, cần login lại
- Backend `DistributedAuthorizeRoles` filter reject

---

## 📝 Files Changed

### Flutter

- ✅ `lib/services/api_service.dart`
  - Sửa `_creatorPodcastsUrl` từ `$_creatorApiUrl/creator/podcasts` → `$_baseUrl/content/creator/podcasts`
  - Sửa `_creatorApplicationUrl` từ `$_creatorApiUrl/CreatorApplications` → `$_userUrl/CreatorApplications`
  - Xóa `_creatorApiUrl` (không dùng nữa)

### Backend

- ✅ Không thay đổi (backend controller đã đúng)
- ✅ Gateway `ocelot.json` đã có routes đúng

---

## 🎯 Kết quả

**Trước fix:**
```
GET http://localhost:5010/api/creator/podcasts/my-podcasts
→ 404 Not Found (Gateway không match route)
```

**Sau fix:**
```
GET http://localhost:5010/api/content/creator/podcasts/my-podcasts
→ Gateway match route: /api/content/creator/podcasts/{everything}
→ Forward to ContentService: http://contentservice-api:80/api/creator/podcasts/my-podcasts
→ Backend authorize qua Redis cache
→ 200 OK với podcast list JSON ✅
```

---

## 📚 Related Documentation

- `FIX_CREATOR_DASHBOARD_GET_MY_PODCASTS.md` - Giải thích chi tiết về `getMyPodcasts()` function
- `DISTRIBUTED_AUTHORIZE_ROLES_FIX.md` - Redis-based authorization
- `AUTHORIZATION_ATTRIBUTES_GUIDE.md` - Hướng dẫn sử dụng authorization attributes
- Gateway `ocelot.json` - Tất cả routes configuration

---

**Created:** 2025-10-17  
**Author:** GitHub Copilot  
**Status:** ✅ Resolved
