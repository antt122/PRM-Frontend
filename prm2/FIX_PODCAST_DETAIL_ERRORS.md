# 🚨 CẦN FIX NGAY - podcast_detail_screen.dart

## Còn 11 lỗi cần fix:

### 1-3. Progress Bar (Lines 510-512)
❌ **Lỗi:** `_duration`, `_position` không tồn tại

✅ **Fix:** Wrap progress bar với StreamBuilder
```dart
// ❌ TRƯỚC (xóa đi):
Container(
  width: _duration.inSeconds > 0
      ? (_position.inSeconds / _duration.inSeconds) * MediaQuery.of(context).size.width * 0.8
      : 0,
)

// ✅ SAU (thay bằng):
StreamBuilder<Duration>(
  stream: audioService.positionStream,
  builder: (context, snapshot) {
    final position = snapshot.data ?? Duration.zero;
    final duration = audioService.duration;
    
    return Container(
      width: duration.inSeconds > 0
          ? (position.inSeconds / duration.inSeconds) * MediaQuery.of(context).size.width * 0.8
          : 0,
    );
  },
)
```

### 4-5. Time Display (Lines 527, 534)
❌ **Lỗi:** `_formatDuration(_position)`, `_formatDuration(_duration)`

✅ **Fix:** Dùng `position` và `duration` từ StreamBuilder ở trên
```dart
// Trong cùng StreamBuilder ở trên, phần Time display:
Row(
  children: [
    Text(_formatDuration(position)),  // Dùng position từ StreamBuilder
    Text(_formatDuration(duration)),  // Dùng duration từ audioService
  ],
)
```

### 6-7. Skip Backward Button (Lines 551-552)
❌ **Lỗi:** `_seek()` không tồn tại, `_position` undefined

✅ **Fix:** Dùng `audioService.skipBackward()`
```dart
// ❌ XÓA:
GestureDetector(
  onTap: () => _seek(_position - const Duration(seconds: 10)),
)

// ✅ THAY BẰNG:
GestureDetector(
  onTap: isThisPodcastPlaying ? () => audioService.skipBackward() : null,
)
```

### 8-9. Play/Pause Button (Lines 571, 588)
❌ **Lỗi:** `_togglePlayPause` không tồn tại, `_isPlaying` undefined

✅ **Fix:** Dùng audioService + isPlaying từ Consumer
```dart
// ❌ XÓA:
GestureDetector(
  onTap: _togglePlayPause,
  child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
)

// ✅ THAY BẰNG:
GestureDetector(
  onTap: () async {
    if (isThisPodcastPlaying) {
      await audioService.togglePlayPause();
    } else {
      await audioService.playPodcast(_podcast!);
    }
  },
  child: Icon(isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
)
```

### 10-11. Skip Forward Button (Lines 599-600)
❌ **Lỗi:** `_seek()` không tồn tại, `_position` undefined

✅ **Fix:** Dùng `audioService.skipForward()`
```dart
// ❌ XÓA:
GestureDetector(
  onTap: () => _seek(_position + const Duration(seconds: 10)),
)

// ✅ THAY BẰNG:
GestureDetector(
  onTap: isThisPodcastPlaying ? () => audioService.skipForward() : null,
)
```

---

## 📝 CODE TEMPLATE ĐẦY ĐỦ

Thay thế đoạn code từ line **490 đến 620** bằng code sau:

```dart
                          // Progress Bar with StreamBuilder
                          if (isThisPodcastPlaying)
                            StreamBuilder<Duration>(
                              stream: audioService.positionStream,
                              builder: (context, snapshot) {
                                final position = snapshot.data ?? Duration.zero;
                                final duration = audioService.duration;

                                return Column(
                                  children: [
                                    // Progress bar
                                    Container(
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      child: Stack(
                                        children: [
                                          Container(
                                            height: 6,
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [Color(0xFFFBE7BA), Color(0xFFD0BF98)],
                                              ),
                                              borderRadius: BorderRadius.circular(3),
                                            ),
                                            width: duration.inSeconds > 0
                                                ? (position.inSeconds / duration.inSeconds) *
                                                    MediaQuery.of(context).size.width * 0.8
                                                : 0,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    // Time display
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _formatDuration(position),
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.7),
                                            fontSize: 12,
                                          ),
                                        ),
                                        Text(
                                          _formatDuration(duration),
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.7),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),
                          
                          const SizedBox(height: 40),
                          
                          // Player Controls
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Skip Backward 10s
                              GestureDetector(
                                onTap: isThisPodcastPlaying 
                                    ? () => audioService.skipBackward() 
                                    : null,
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                  child: const Icon(Icons.replay_10, color: Colors.white, size: 24),
                                ),
                              ),
                              
                              const SizedBox(width: 24),
                              
                              // Play/Pause
                              GestureDetector(
                                onTap: () async {
                                  try {
                                    if (isThisPodcastPlaying) {
                                      await audioService.togglePlayPause();
                                    } else {
                                      await audioService.playPodcast(_podcast!);
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Lỗi: $e')),
                                      );
                                    }
                                  }
                                },
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFFFBE7BA),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFFBE7BA).withOpacity(0.3),
                                        blurRadius: 20,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                    color: const Color(0xFF604B3B),
                                    size: 40,
                                  ),
                                ),
                              ),
                              
                              const SizedBox(width: 24),
                              
                              // Skip Forward 10s
                              GestureDetector(
                                onTap: isThisPodcastPlaying 
                                    ? () => audioService.skipForward() 
                                    : null,
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                  child: const Icon(Icons.forward_10, color: Colors.white, size: 24),
                                ),
                              ),
                            ],
                          ),
```

---

## ⚡ LÀM NHANH:

1. **Mở file:** `podcast_detail_screen.dart`
2. **Tìm dòng 490** (phần progress bar)
3. **Xóa từ dòng 490 đến 620** (toàn bộ progress bar + controls)
4. **Paste code template** ở trên vào vị trí đó
5. **Save file**
6. **Run:** `flutter run -d chrome --web-port 3001`

✅ Done! Tất cả 11 lỗi sẽ được fix!
