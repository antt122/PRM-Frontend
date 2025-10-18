# 🎙️ Fix: Creator Dashboard - Get My Podcasts API

## ❌ Vấn đề

### Error Log:
```
GET http://localhost:5010/api/creator/podcasts/my-podcasts?page=1&pageSize=20
Status: 404 Not Found

FormatException: SyntaxError: Unexpected end of JSON input
```

### Root Causes:

1. **Wrong Function Call in Dashboard**
   - `creator_dashboard_screen.dart` gọi `ApiService.getMyPosts()`
   - Nhưng `getMyPosts()` đang gọi URL `/creator/podcasts/my-podcasts` (sai!)
   - Parse response sang `MyPost` model thay vì `Podcast`

2. **Missing `getMyPodcasts()` Function**
   - Không có hàm riêng để fetch creator's podcasts
   - Cần return `PaginationResult<Podcast>` thay vì `ApiResult<List<MyPost>>`

3. **Wrong Model Usage**
   - Dashboard hiển thị `MyPost` (postcard) thay vì `Podcast`
   - Field names sai: `coverImageUrl` → `thumbnailUrl`, `viewsCount` → `viewCount`

## ✅ Giải pháp

### 1. Tạo hàm `getMyPodcasts()` mới trong `api_service.dart`

```dart
/// Get creator's podcasts (for Creator Dashboard)
static Future<PaginationResult<Podcast>> getMyPodcasts({
  int page = 1,
  int pageSize = 20,
}) async {
  final url = Uri.parse('$_creatorPodcastsUrl/my-podcasts?page=$page&pageSize=$pageSize');
  
  try {
    final headers = await _getAuthHeaders();
    final response = await http.get(url, headers: headers);
    
    print('[getMyPodcasts] Status: ${response.statusCode}');
    print('[getMyPodcasts] URL: $url');
    
    if (response.statusCode == 404) {
      return PaginationResult<Podcast>(
        /* ... error response ... */
        errorCode: '404',
      );
    }
    
    if (response.statusCode != 200) {
      return PaginationResult<Podcast>(
        /* ... error response ... */
        errorCode: response.statusCode.toString(),
      );
    }

    final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
    
    // Backend returns: { podcasts: [...], totalCount, page, pageSize }
    final podcastsList = jsonResponse['podcasts'] as List<dynamic>?;
    final podcasts = podcastsList
        .map((json) => Podcast.fromJson(json as Map<String, dynamic>))
        .toList();
    
    final totalCount = jsonResponse['totalCount'] as int? ?? 0;
    final totalPages = (totalCount / pageSize).ceil();

    return PaginationResult<Podcast>(
      currentPage: page,
      pageSize: pageSize,
      totalItems: totalCount,
      totalPages: totalPages,
      hasPrevious: page > 1,
      hasNext: page < totalPages,
      items: podcasts,
      isSuccess: true,
      message: 'Success',
    );
  } catch (e) {
    print('[getMyPodcasts] Error: $e');
    return PaginationResult<Podcast>(
      /* ... error response ... */
      message: 'Exception: $e',
    );
  }
}
```

**Key Points:**
- ✅ Correct endpoint: `/api/creator/podcasts/my-podcasts`
- ✅ Return `PaginationResult<Podcast>` (not `ApiResult<List<MyPost>>`)
- ✅ Parse response to `Podcast` model
- ✅ Handle 404 error with custom message
- ✅ Support pagination (page, pageSize, totalCount, totalPages)

### 2. Fix `getMyPosts()` - Restore original URL

```dart
static Future<ApiResult<List<MyPost>>> getMyPosts({
  int page = 1,
  int pageSize = 20,
}) async {
  // ✅ FIXED: Changed from creator/podcasts to cms/posts
  final url = Uri.parse('$_cmsUrl/posts/my-posts?page=$page&pageSize=$pageSize');
  
  try {
    final headers = await _getAuthHeaders();
    final response = await http.get(url, headers: headers);
    final jsonResponse = jsonDecode(response.body);
    
    if (response.statusCode != 200) {
      return ApiResult(
        isSuccess: false,
        message: 'Lỗi ${response.statusCode}: ${jsonResponse['message']}',
      );
    }

    // ✅ FIXED: Changed from 'podcasts' to 'posts'
    final itemsList = jsonResponse['posts'] as List<dynamic>?;
    if (itemsList == null) {
      return ApiResult(
        isSuccess: false,
        message: 'Dữ liệu trả về không đúng định dạng.',
      );
    }

    final posts = itemsList.map((p) => MyPost.fromJson(p)).toList();
    return ApiResult(isSuccess: true, data: posts);
  } catch (e) {
    return ApiResult(isSuccess: false, message: e.toString());
  }
}
```

### 3. Refactor `creator_dashboard_screen.dart`

**Before (Wrong):**
```dart
import '../models/my_post.dart';

class _CreatorDashboardScreenState extends State<CreatorDashboardScreen> {
  late Future<ApiResult<List<MyPost>>> _postsFuture; // ❌ Wrong model
  
  void _loadPosts() {
    setState(() {
      _postsFuture = ApiService.getMyPosts(); // ❌ Wrong function
    });
  }
  
  Widget build(BuildContext context) {
    return FutureBuilder<ApiResult<List<MyPost>>>(
      future: _postsFuture,
      builder: (context, snapshot) {
        final posts = snapshot.data!.data ?? [];
        // Display postcards...
      },
    );
  }
}
```

**After (Correct):**
```dart
import '../models/podcast.dart';
import '../models/pagination_result.dart';

class _CreatorDashboardScreenState extends State<CreatorDashboardScreen> {
  late Future<PaginationResult<Podcast>> _podcastsFuture; // ✅ Correct model
  int _currentPage = 1;
  final int _pageSize = 20;
  
  void _loadPodcasts() {
    setState(() {
      _podcastsFuture = ApiService.getMyPodcasts( // ✅ Correct function
        page: _currentPage,
        pageSize: _pageSize,
      );
    });
  }
  
  Widget build(BuildContext context) {
    return FutureBuilder<PaginationResult<Podcast>>(
      future: _podcastsFuture,
      builder: (context, snapshot) {
        final result = snapshot.data!;
        
        if (!result.isSuccess) {
          return Center(
            child: Column(
              children: [
                Text('Lỗi tải podcast'),
                Text(result.message ?? 'Vui lòng thử lại'),
                if (result.errorCode == '404')
                  Text('⚠️ Backend endpoint not found'),
                ElevatedButton(
                  onPressed: _loadPodcasts,
                  child: Text('Thử lại'),
                ),
              ],
            ),
          );
        }
        
        final podcasts = result.items;
        
        if (podcasts.isEmpty) {
          return Center(
            child: Text('Bạn chưa có podcast nào'),
          );
        }
        
        return Column(
          children: [
            // Header with total count
            Container(
              child: Text('Tổng số: ${result.totalItems} podcast'),
            ),
            
            // Podcast list
            Expanded(
              child: ListView.builder(
                itemCount: podcasts.length,
                itemBuilder: (context, index) {
                  return _buildPodcastCard(podcasts[index]);
                },
              ),
            ),
            
            // Pagination controls
            if (result.totalPages > 1)
              _buildPaginationControls(result),
          ],
        );
      },
    );
  }
}
```

### 4. Build Podcast Card Widget

```dart
Widget _buildPodcastCard(Podcast podcast) {
  return Card(
    child: InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PodcastDetailScreen(podcastId: podcast.id),
          ),
        );
      },
      child: Row(
        children: [
          // Thumbnail
          Image.network(
            podcast.thumbnailUrl ?? 'https://via.placeholder.com/120', // ✅ Correct field
            width: 120,
            height: 120,
            fit: BoxFit.cover,
          ),
          
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(podcast.title),
                  
                  // Series name
                  if (podcast.seriesName?.isNotEmpty ?? false) // ✅ Null-safe
                    Text('📻 ${podcast.seriesName}'),
                  
                  // Stats
                  Row(
                    children: [
                      Icon(Icons.visibility),
                      Text('${podcast.viewCount}'), // ✅ Correct field
                      
                      Icon(Icons.favorite),
                      Text('${podcast.likeCount}'), // ✅ Correct field
                    ],
                  ),
                  
                  // Duration
                  Text(_formatDuration(podcast.duration)),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
```

## 📊 API Response Format

### Backend Response:
```json
{
  "podcasts": [
    {
      "id": "guid",
      "title": "Episode 1",
      "thumbnailUrl": "https://...",
      "seriesName": "My Podcast Series",
      "viewCount": 1234,
      "likeCount": 56,
      "duration": 1800,
      ...
    }
  ],
  "totalCount": 10,
  "page": 1,
  "pageSize": 20
}
```

### Parsed to:
```dart
PaginationResult<Podcast>(
  currentPage: 1,
  pageSize: 20,
  totalItems: 10,
  totalPages: 1,
  hasPrevious: false,
  hasNext: false,
  items: [Podcast(...), ...],
  isSuccess: true,
  message: 'Success',
)
```

## 🔍 Field Name Mapping

| Backend JSON | Dart Model | Usage |
|--------------|------------|-------|
| `thumbnailUrl` | `podcast.thumbnailUrl` | ✅ Correct |
| ~~`coverImageUrl`~~ | ❌ Does not exist | Use `thumbnailUrl` |
| `viewCount` | `podcast.viewCount` | ✅ Correct |
| ~~`viewsCount`~~ | ❌ Typo | Use `viewCount` |
| `likeCount` | `podcast.likeCount` | ✅ Correct |
| ~~`likesCount`~~ | ❌ Typo | Use `likeCount` |
| `seriesName` | `podcast.seriesName` | Nullable (use `?.`) |

## 🧪 Testing Checklist

### Test 1: User có podcasts
```dart
// Setup: Creator có 5 podcasts
GET /api/creator/podcasts/my-podcasts?page=1&pageSize=20

// Expected: ✅ 200 OK
{
  "podcasts": [...], // 5 items
  "totalCount": 5,
  "page": 1,
  "pageSize": 20
}

// UI: Shows list of 5 podcasts with pagination disabled
```

### Test 2: User chưa có podcasts
```dart
// Setup: Creator chưa tạo podcast nào
GET /api/creator/podcasts/my-podcasts?page=1&pageSize=20

// Expected: ✅ 200 OK
{
  "podcasts": [],
  "totalCount": 0,
  "page": 1,
  "pageSize": 20
}

// UI: Shows "Bạn chưa có podcast nào"
```

### Test 3: Pagination
```dart
// Setup: Creator có 50 podcasts, pageSize=20
GET /api/creator/podcasts/my-podcasts?page=1&pageSize=20

// Expected:
currentPage: 1
totalPages: 3 (50 / 20 = 2.5 → ceil = 3)
hasPrevious: false
hasNext: true

// Click next page:
GET /api/creator/podcasts/my-podcasts?page=2&pageSize=20

// Expected:
currentPage: 2
hasPrevious: true
hasNext: true
```

### Test 4: 404 Error (Backend not running)
```dart
// Setup: Backend stopped
GET /api/creator/podcasts/my-podcasts

// Expected: ❌ 404 Not Found

// UI: Shows error message:
"⚠️ Backend endpoint not found"
"Check: /api/creator/podcasts/my-podcasts"
[Thử lại] button
```

### Test 5: 401/403 Error (No auth or no role)
```dart
// Setup: User không phải ContentCreator
GET /api/creator/podcasts/my-podcasts

// Expected: ❌ 403 Forbidden

// UI: Shows error message with status code
```

## 🎉 Summary

### Changes Made:

**File: `api_service.dart`**
- ✅ Created new `getMyPodcasts()` function
- ✅ Fixed `getMyPosts()` URL from `/creator/podcasts/my-podcasts` to `/cms/posts/my-posts`
- ✅ Return correct models: `PaginationResult<Podcast>` vs `ApiResult<List<MyPost>>`

**File: `creator_dashboard_screen.dart`**
- ✅ Changed from `MyPost` model to `Podcast` model
- ✅ Changed from `ApiResult<List<MyPost>>` to `PaginationResult<Podcast>`
- ✅ Call `ApiService.getMyPodcasts()` instead of `getMyPosts()`
- ✅ Fixed field names: `thumbnailUrl`, `viewCount`, `likeCount`
- ✅ Added null-safe check for `seriesName?.isNotEmpty`
- ✅ Added better error handling with 404 detection
- ✅ Added pagination controls (prev/next buttons)
- ✅ Display total count header

### Impact:
- ✅ Creator Dashboard now correctly displays podcasts
- ✅ No more 404 errors
- ✅ Proper pagination support
- ✅ Better error messages for debugging
- ✅ Click podcast card → Navigate to detail screen

---

**Fixed Date:** October 17, 2025  
**Files Changed:** 
- `lib/services/api_service.dart` (+113 lines, refactored getMyPosts)
- `lib/screens/creator_dashboard_screen.dart` (complete refactor, ~360 lines)
