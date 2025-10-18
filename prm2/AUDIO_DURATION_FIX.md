# 🎵 Fix Duration Display During Podcast Loading

## ❌ Vấn đề

Khi user click vào podcast mới trong lúc đang phát podcast cũ:

```
1. Đang phát: Podcast A (2:30 / 10:00)
2. Click Podcast B
3. Position reset → 0:00 ✅
4. Duration vẫn là 10:00 ❌ (của Podcast A)
5. UI hiển thị: 0:00 / 10:00 (CONFUSING!)
6. Trong lúc download Podcast B...
7. Duration cuối cùng update → 0:00 / 8:45 (của Podcast B)
```

**Vấn đề**: Mini player hiển thị **duration cũ** (10:00) trong lúc đang download podcast mới!

---

## 🔍 Nguyên nhân

### Code cũ:
```dart
Duration get duration => _audioPlayer.duration ?? Duration.zero;
```

### Timeline:
1. `_audioPlayer.stop()` → Position reset về 0:00
2. `_audioPlayer.seek(Duration.zero)` → Position = 0:00
3. **Nhưng** `_audioPlayer.duration` vẫn là `10:00` (của audio cũ)
4. Download podcast mới... (takes 2-3 seconds)
5. `setAudioSource(newAudio)` → Duration mới update về `8:45`

**Problem**: Trong khoảng thời gian download (step 4), UI hiển thị **0:00 / 10:00** → **Sai lệch!**

---

## ✅ Giải pháp

### 1. Thêm flag `_isLoadingNewPodcast`

Track state khi đang download podcast mới:

```dart
bool _isLoadingNewPodcast = false;  // Track loading state
```

### 2. Override `duration` getter

Trả về `Duration.zero` khi đang loading:

```dart
Duration get duration {
  if (_isLoadingNewPodcast) {
    return Duration.zero;  // ✅ Show 0:00 while downloading
  }
  return _audioPlayer.duration ?? Duration.zero;
}
```

### 3. Set flag trong `playPodcast()`

**Workflow**:

```dart
// Step 1: Reset player
_currentPodcast = podcast;
await _audioPlayer.stop();
await _audioPlayer.seek(Duration.zero);

// Step 2: Set loading flag
_isLoadingNewPodcast = true;
notifyListeners();  // ✅ UI now shows: 0:00 / 0:00

// Step 3: Download audio
final response = await http.get(...);  // Takes 2-3 seconds
audioBytes = response.bodyBytes;

// Step 4: Load audio
await _audioPlayer.setAudioSource(audioSource);

// Step 5: Clear loading flag
_isLoadingNewPodcast = false;  // ✅ Duration now from real audio

// Step 6: Play
await _audioPlayer.play();
```

---

## 🎯 Timeline mới

```
User click Podcast B (while playing A at 2:30/10:00):

T+0ms:   playPodcast(B) called
T+10ms:  _currentPodcast = B
T+20ms:  _audioPlayer.stop() → Position = 0:00
T+30ms:  _audioPlayer.seek(0) → Position = 0:00
T+40ms:  _isLoadingNewPodcast = true
T+50ms:  notifyListeners() → UI updates
         ✅ Mini Player: "Podcast B - 0:00 / 0:00"
         
T+100ms: Start downloading...
T+2500ms: Download complete (2.4 seconds)
T+2600ms: setAudioSource() → Load audio
         → _audioPlayer.duration = 8:45 (real duration)
         
T+2700ms: _isLoadingNewPodcast = false
         → duration getter now returns 8:45
         
T+2800ms: play()
         ✅ Mini Player: "Podcast B - 0:00 / 8:45" ✅
```

---

## 🔄 User Flow Comparison

### ❌ Before:
```
Click Podcast B
  → 0:00 / 10:00  (WRONG! Shows old duration)
  → (download 2s...)
  → 0:00 / 8:45   (Suddenly changes)
```

### ✅ After:
```
Click Podcast B
  → 0:00 / 0:00   (Loading state)
  → (download 2s...)
  → 0:00 / 8:45   (Real duration appears)
```

---

## 📝 Code Changes

### File: `lib/services/audio_player_service.dart`

#### 1. Added loading flag:
```dart
bool _isLoadingNewPodcast = false;
```

#### 2. Updated duration getter:
```dart
Duration get duration {
  if (_isLoadingNewPodcast) {
    return Duration.zero;  // Show 0:00 while downloading
  }
  return _audioPlayer.duration ?? Duration.zero;
}
```

#### 3. Added getter for loading state:
```dart
bool get isLoadingNewPodcast => _isLoadingNewPodcast;
```

#### 4. Updated `playPodcast()`:
```dart
Future<void> playPodcast(Podcast podcast) async {
  try {
    // ... same podcast check ...
    
    // New podcast
    _currentPodcast = podcast;
    await _audioPlayer.stop();
    await _audioPlayer.seek(Duration.zero);
    
    // ✅ Set loading flag
    _isLoadingNewPodcast = true;
    notifyListeners();  // UI shows 0:00 / 0:00
    
    // Download...
    final audioBytes = await download();
    
    // Load audio
    await _audioPlayer.setAudioSource(audioSource);
    
    // ✅ Clear loading flag
    _isLoadingNewPodcast = false;
    
    await _audioPlayer.play();
    
  } catch (e) {
    // ✅ Reset flag on error
    _isLoadingNewPodcast = false;
    notifyListeners();
    rethrow;
  }
}
```

---

## 🧪 Test Cases

### ✅ Test 1: Click podcast khác
```
1. Play Podcast A → 2:30 / 10:00
2. Click Podcast B
3. ✅ Immediately shows: 0:00 / 0:00
4. Download... (2 seconds)
5. ✅ Updates to: 0:00 / 8:45
6. ✅ Starts playing
```

### ✅ Test 2: Click podcast đã cached
```
1. Play Podcast A → 2:30 / 10:00
2. Click Podcast B (already cached)
3. ✅ Shows: 0:00 / 0:00 (brief moment)
4. ✅ Instantly updates: 0:00 / 8:45 (no download delay)
5. ✅ Starts playing immediately
```

### ✅ Test 3: Error during download
```
1. Play Podcast A → 2:30 / 10:00
2. Click Podcast B
3. ✅ Shows: 0:00 / 0:00
4. ❌ Download fails (network error)
5. ✅ Flag reset → duration returns to normal
6. ✅ Error message shown to user
```

### ✅ Test 4: Click same podcast (mini player)
```
1. Play Podcast A → 2:30 / 10:00
2. Tap mini player
3. ✅ Navigate to detail screen
4. ✅ Audio continues: 2:31 / 10:00
5. ✅ No loading state (same podcast)
```

---

## 🎨 UI States

### State 1: Normal Playback
```dart
_isLoadingNewPodcast = false
_audioPlayer.duration = 10:00
→ duration getter returns: 10:00 ✅
→ UI: 2:30 / 10:00
```

### State 2: Loading New Podcast
```dart
_isLoadingNewPodcast = true
_audioPlayer.duration = 10:00 (old value)
→ duration getter returns: 0:00 ✅ (override!)
→ UI: 0:00 / 0:00
```

### State 3: Audio Loaded
```dart
_isLoadingNewPodcast = false
_audioPlayer.duration = 8:45 (new value)
→ duration getter returns: 8:45 ✅
→ UI: 0:00 / 8:45
```

---

## 🚀 Benefits

1. **Clean UI**: Không hiển thị duration cũ khi loading
2. **User Clarity**: `0:00 / 0:00` clearly indicates loading
3. **No Confusion**: Duration không jump từ 10:00 → 8:45
4. **Smooth Transition**: Loading → Real duration seamlessly
5. **Error Handling**: Flag reset nếu download fail

---

## 🔍 Debugging

### Check loading state:
```dart
final audioService = Provider.of<AudioPlayerService>(context);
print('Loading? ${audioService.isLoadingNewPodcast}');
print('Duration: ${audioService.duration}');
print('Real player duration: ${audioService.player.duration}');
```

### Expected console logs:
```
Click Podcast B:
  _isLoadingNewPodcast = true
  duration getter returns: 0:00:00.000000
  
Download complete:
  _isLoadingNewPodcast = false
  duration getter returns: 0:08:45.000000 (from player)
```

---

## 📊 Performance Impact

- **Minimal**: Just a boolean flag check in getter
- **No extra downloads**: Uses existing cache mechanism
- **UI updates**: 2 notifyListeners() calls (acceptable)
- **Memory**: +1 bool field (~1 byte)

---

## 🎯 Related Fixes

This fix complements:
- ✅ `AUDIO_NAVIGATION_FIX.md` - Prevents audio restart on navigation
- ✅ Auto-pause old podcast before playing new one
- ✅ Reset position to 0:00 immediately

**Together**: Complete seamless podcast switching experience! 🎵

---

**Status**: ✅ HOÀN THÀNH - Duration hiển thị chính xác trong mọi trường hợp!
