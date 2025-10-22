# 🎧 Hướng dẫn sử dụng tính năng Podcast

## Tổng quan

Tính năng Podcast cho phép người dùng khám phá, nghe và tương tác với các podcast về sức khỏe tinh thần trên Healink.

## Các tính năng chính

### 1. **Danh sách Podcast** 📱

#### Truy cập
- Mở menu drawer (icon ≡ ở góc trên)
- Chọn "🎧 Khám phá Podcast"

#### Các tab
- **Thịnh hành**: Podcast có lượt xem cao nhất
- **Mới nhất**: Podcast được đăng gần đây
- **Tìm kiếm**: Tìm kiếm podcast theo từ khóa

#### Tìm kiếm
1. Nhập từ khóa vào thanh search
2. Nhấn Enter hoặc icon search
3. Kết quả hiển thị trong tab "Tìm kiếm"
4. Xóa tìm kiếm bằng icon X

#### Bộ lọc nâng cao 🎯
1. Nhấn icon **filter_list** (phễu) ở góc phải AppBar
2. Chọn bộ lọc **Cảm xúc**:
   - 😊 Hạnh phúc
   - 😢 Buồn
   - 😰 Lo lắng
   - 😌 Bình tĩnh
   - 😫 Căng thẳng
3. Chọn bộ lọc **Chủ đề**:
   - 🧠 Sức khỏe tinh thần
   - 🧘 Chánh niệm
   - 🕉️ Thiền định
   - 😴 Giấc ngủ
   - 💚 Wellness
4. Nhấn "Xóa bộ lọc" để reset
5. Icon filter chuyển màu vàng khi có filter đang active

#### Chế độ hiển thị
- **Grid view** (mặc định): 2 cột, hiển thị thumbnail lớn
- **List view**: Danh sách ngang, hiển thị chi tiết hơn
- Toggle bằng icon grid_view / list ở góc phải

#### Infinite Scroll
- Cuộn xuống cuối danh sách tự động tải thêm
- Loading indicator hiển thị khi đang tải

### 2. **Chi tiết Podcast** 🎵

#### Giao diện
- **SliverAppBar**: Thumbnail phóng to khi scroll
- **Thông tin**: Tiêu đề, host, mô tả, tags
- **Thống kê**: Lượt xem, lượt thích, thời lượng

#### Tính năng Like ❤️
1. Nhấn icon **favorite** ở góc phải AppBar
2. Trái tim đỏ = Đã thích
3. Trái tim trắng = Chưa thích
4. Số lượt thích cập nhật realtime
5. Toast notification xác nhận thao tác

#### Audio Player 🎼

**Controls**:
- ▶️ **Play**: Phát podcast
- ⏸️ **Pause**: Tạm dừng
- ⏪ **-10s**: Tua lùi 10 giây
- ⏩ **+10s**: Tua tới 10 giây
- **Seek bar**: Kéo để nhảy đến vị trí bất kỳ
- **Time display**: Hiển thị thời gian hiện tại / tổng thời gian

**Vị trí**: Bottom sheet cố định ở cuối màn hình

**Màu sắc**: Nền nâu (#8B7355) - matching theme Healink

### 3. **Tracking tự động** 📊

#### View Count
- Tự động tăng khi vào màn hình chi tiết
- Chỉ track 1 lần mỗi phiên xem
- Silent fail (không hiển thị lỗi nếu thất bại)

#### Like Status
- Load trạng thái like khi vào màn hình
- Đồng bộ với backend realtime
- Hiển thị số lượt thích cập nhật

## Kiến trúc kỹ thuật

### Models
- **Podcast**: 23 fields, 3 helper methods (formattedDuration, formattedDate, formattedViews)
- **PaginationResult<T>**: Generic wrapper cho pagination
- **PodcastCategoryFilter**: Emotion + Topic categories

### API Endpoints
```dart
// List & Search
GET /api/content/user/podcasts?page=1&pageSize=10
GET /api/content/user/podcasts/trending
GET /api/content/user/podcasts/latest
GET /api/content/user/podcasts/search?keyword=...

// Detail
GET /api/content/user/podcasts/{id}

// Interactions
POST /api/content/user/podcasts/{id}/view
POST /api/content/user/podcasts/{id}/like
GET /api/content/user/podcasts/{id}/liked
```

### Components
- **PodcastCard**: Grid card view (16:9 thumbnail)
- **PodcastListItem**: Horizontal list item (100x100 thumbnail)
- **PodcastListScreen**: Main screen with tabs, search, filters
- **PodcastDetailScreen**: Detail with audio player

### Package dependencies
```yaml
audioplayers: ^6.1.0  # Audio playback
```

## Xử lý lỗi

### Network errors
- Hiển thị SnackBar với message lỗi
- Fallback empty state cho danh sách
- Retry bằng pull-to-refresh (có thể thêm)

### Loading states
- CircularProgressIndicator khi tải dữ liệu
- Shimmer loading (có thể thêm)
- Loading indicator ở cuối list khi paginate

### Audio errors
- Placeholder icon nếu không có audio file
- Error message nếu không thể phát
- Fallback silent cho view tracking

## Best Practices

### Performance
- ✅ Pagination: Load 10 items/page
- ✅ Image caching: NetworkImage tự động cache
- ✅ Lazy loading: GridView.builder / ListView.builder
- ✅ Dispose: AudioPlayer dispose trong dispose()

### UX
- ✅ Smooth animations: SliverAppBar, FilterChip
- ✅ Visual feedback: Loading states, toast messages
- ✅ Responsive: Grid 2 columns, list full width
- ✅ Accessibility: Icon với semantic labels

### Security
- ✅ Auth headers: JWT token trong mọi request
- ✅ Silent fail: View tracking không hiển thị lỗi
- ✅ Validation: Check null values

## Roadmap (Tính năng tương lai)

### Phase 2
- [ ] Mini player at bottom navigation (persistent)
- [ ] Playlist functionality
- [ ] Download for offline listening
- [ ] Playback speed control (0.5x, 1x, 1.5x, 2x)
- [ ] Sleep timer

### Phase 3
- [ ] Comments & ratings
- [ ] Share podcast
- [ ] Podcast recommendations (AI)
- [ ] Transcript display
- [ ] Dark mode support

### Phase 4
- [ ] Creator analytics dashboard
- [ ] Monetization (premium podcasts)
- [ ] Live streaming
- [ ] Multi-language support

## Troubleshooting

### Không thể phát audio
1. Kiểm tra audioFileUrl có hợp lệ không
2. Kiểm tra network connection
3. Kiểm tra permission (Android/iOS)
4. Restart app

### Lỗi 401 Unauthorized
1. Token hết hạn → Đăng nhập lại
2. Token không hợp lệ → Clear cache, đăng nhập lại

### Lỗi pagination không load thêm
1. Kiểm tra hasNext = true
2. Kiểm tra ScrollController attached
3. Kiểm tra _isLoadingMore flag

## Support

Liên hệ team dev:
- Email: support@healink.com
- Discord: Healink Dev Channel
- GitHub Issues: [Repository Link]

---

**Version**: 1.0.0  
**Last Updated**: 2025-10-16  
**Author**: Healink Dev Team
