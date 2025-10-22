# Feature: Create Podcast Implementation

## 📋 Overview

Đã triển khai hoàn chỉnh tính năng **"Tạo Podcast Mới"** cho Content Creators với:
- ✅ File upload (audio + thumbnail)
- ✅ Detailed form with all required fields
- ✅ Category selection (Emotions + Topics)
- ✅ API integration with backend
- ✅ Error handling and validation
- ✅ Success/Error notifications

---

## 🔧 Backend API

### Endpoint: POST `/api/creator/podcasts`

**Route through Gateway:**
```
http://localhost:5010/api/content/creator/podcasts
```

**Request:**
```http
POST /api/content/creator/podcasts HTTP/1.1
Authorization: Bearer {jwt_token}
Content-Type: multipart/form-data

Form Fields:
- Title (required, string, 3-200 chars)
- Description (required, string, 10-2000 chars)
- AudioFile (required, IFormFile, MP3/WAV/OGG/M4A/MP4, max 500MB)
- ThumbnailFile (optional, IFormFile, JPG/PNG/WEBP, max 10MB)
- Duration (required, int, 1-18000 seconds)
- HostName (optional, string, max 100 chars)
- GuestName (optional, string, max 100 chars)
- EpisodeNumber (optional, int, default 1)
- SeriesName (optional, string, max 200 chars)
- TranscriptUrl (optional, string, max 1000 chars)
- Tags (optional, JSON array of strings)
- EmotionCategories (optional, JSON array of strings)
- TopicCategories (optional, JSON array of strings)
```

**Response (201 Created):**
```json
{
  "isSuccess": true,
  "message": "Podcast created successfully",
  "data": {
    "id": "uuid-string",
    "title": "Podcast Title",
    "description": "Description",
    "audioUrl": "https://s3.amazonaws.com/...",
    "thumbnailUrl": "https://s3.amazonaws.com/...",
    "duration": 1800,
    "createdAt": "2025-10-17T10:30:00Z",
    ...
  }
}
```

**Error Responses:**
- `400 Bad Request` - Validation error (invalid format, missing required fields)
- `401 Unauthorized` - JWT token invalid or expired
- `413 Payload Too Large` - File size exceeds 500MB limit
- `500 Server Error` - Server error during upload/processing

---

## 📱 Flutter Implementation

### 1. API Service: `lib/services/api_service.dart`

**Function:**
```dart
static Future<ApiResult<Map<String, dynamic>>> createPodcast({
  required String title,
  required String description,
  required File audioFile,
  File? thumbnailFile,
  required int duration,
  String? hostName,
  String? guestName,
  int episodeNumber = 1,
  String? seriesName,
  List<String>? tags,
  List<EmotionCategory>? emotionCategories,
  List<TopicCategory>? topicCategories,
  String? transcriptUrl,
}) async
```

**Features:**
- ✅ Multipart form data for file uploads
- ✅ JWT token auto-included from SharedPreferences
- ✅ Proper field name mapping to backend
- ✅ Enum conversion (EmotionCategory → JSON string array)
- ✅ Comprehensive error handling (400, 401, 413, etc.)
- ✅ Returns ApiResult<Map> with parsed response

### 2. Screen: `lib/screens/create_podcast_screen.dart`

**Features:**
- ✅ Complete form with all podcast fields
- ✅ File pickers for audio and thumbnail
- ✅ Category chip selection (Emotions + Topics)
- ✅ Form validation
- ✅ Loading state while uploading
- ✅ Success/Error notifications
- ✅ Returns `true` on success (for dashboard refresh)

**Form Fields:**
1. Audio File (required) - File picker
2. Thumbnail Image (optional) - Image picker
3. Title (required) - Text field, 3-200 chars
4. Description (required) - Text area, 10-2000 chars
5. Host Name (optional) - Text field
6. Guest Name (optional) - Text field
7. Episode Number (optional) - Numeric, default 1
8. Series Name (optional) - Text field
9. Tags (optional) - Comma-separated text
10. Transcript URL (optional) - Text field
11. Emotion Categories (optional) - Chip selection
12. Topic Categories (optional) - Chip selection

### 3. Updated: `lib/screens/creator_dashboard_screen.dart`

**Changes:**
- ✅ FloatingActionButton now navigates to `CreatePodcastScreen`
- ✅ Waits for creation result (true = success)
- ✅ Auto-refreshes podcast list on success
- ✅ Removed "Feature in development" SnackBar

```dart
floatingActionButton: FloatingActionButton(
  onPressed: () async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreatePodcastScreen()),
    );
    
    // Refresh if creation was successful
    if (result == true) {
      _loadPodcasts();
    }
  },
  backgroundColor: kAccentColor,
  child: const Icon(Icons.add, color: kPrimaryTextColor),
),
```

---

## 🧪 Testing Checklist

### Prerequisites
- ✅ Backend running on Docker (ContentService)
- ✅ Gateway running on Docker (Ocelot)
- ✅ Redis running for user state cache
- ✅ S3/MinIO configured for file storage
- ✅ User logged in as ContentCreator

### Test Cases

**1. Create podcast with all fields:**
```
1. Login as ContentCreator
2. Open Creator Dashboard
3. Click "+" button
4. Fill all fields:
   - Title: "My Awesome Podcast"
   - Description: "This is a great podcast about..."
   - Host Name: "John Doe"
   - Guest Name: "Jane Smith"
   - Episode: 1
   - Series: "Season 1"
   - Tags: "lifestyle, health, wellness"
   - Emotion: Happy, Excited
   - Topic: Health, Wellness
5. Select audio file (MP3, WAV, etc.)
6. Select thumbnail image (JPG, PNG, etc.)
7. Click "Tạo Podcast"
8. ✅ Expected: Success notification, dashboard refreshes with new podcast
```

**2. Create podcast with minimal fields:**
```
1. Fill only required fields:
   - Title, Description, Audio file
2. Click "Tạo Podcast"
3. ✅ Expected: Success, podcast created with defaults
```

**3. Validation errors:**
```
1. Try to submit empty form
2. ✅ Expected: "Vui lòng nhập tiêu đề" error
3. Try to submit without audio file
4. ✅ Expected: "Vui lòng chọn file audio" error
```

**4. File upload errors:**
```
1. Try to upload file > 500MB
2. ✅ Expected: 413 error with message "File too large"
3. Try to upload invalid audio format
4. ✅ Expected: 400 error with validation message
```

**5. Authorization errors:**
```
1. Logout and try to access create screen
2. ✅ Expected: 401 error, redirected to login
3. Login as regular User (not ContentCreator)
4. ✅ Expected: 403 Forbidden or access denied
```

**6. Network errors:**
```
1. Stop backend
2. Try to create podcast
3. ✅ Expected: Connection error message
4. Start backend again
5. ✅ Create podcast should work
```

---

## 📝 Key Implementation Details

### 1. File Handling

**Audio File:**
- Uses `FilePicker` to select audio files
- Supported formats: MP3, WAV, OGG, M4A, MP4
- Max size: 500MB
- Field name: `AudioFile`

**Thumbnail:**
- Uses `ImagePicker` to select from gallery
- Image quality reduced to 80% for optimization
- Supported formats: JPG, PNG, WEBP
- Max size: 10MB
- Field name: `ThumbnailFile`

### 2. Category Handling

**EmotionCategory Enum:**
```dart
enum EmotionCategory {
  happy, sad, anxious, angry, calm, excited, stressed, grateful, confused, hopeful
}
```

Converted to JSON string array:
```dart
List<String> emotionStrings = emotionCategories.map((e) => e.name).toList();
request.fields['EmotionCategories'] = jsonEncode(emotionStrings);
```

### 3. Form Validation

**Client-side:**
- Title must be filled
- Description must be filled
- Audio file must be selected
- Episode number must be valid integer

**Server-side (Backend):**
- Title: 3-200 chars (non-empty)
- Description: 10-2000 chars
- Duration: 1-18000 seconds (0-5 hours)
- Audio file: MP3/WAV/OGG/M4A/MP4 format
- Thumbnail: JPG/PNG/WEBP format

### 4. Error Handling

```
┌─────────────────────────────────────┐
│        API Response Handling        │
├─────────────────────────────────────┤
│ 201/200: Success → Show notification│
│          Auto-refresh dashboard     │
├─────────────────────────────────────┤
│ 400: Validation error → Show message│
│                                     │
│ 401: Unauthorized → Show "Login again"
│                                     │
│ 413: File too large → Show file size err
│                                     │
│ Other: Generic error → Show status  │
└─────────────────────────────────────┘
```

### 5. User Experience Flow

```
Creator Dashboard
       ↓
  [+ Button]
       ↓
Create Podcast Screen
       ↓
   [Select Files]
   [Fill Form]
   [Choose Categories]
       ↓
  [Tạo Podcast Button]
       ↓
   [Loading...]
       ↓
   (Success)  OR  (Error)
       ↓              ↓
   Dashboard ← → Show Error
   Refreshes     & Stay on Screen
```

---

## 🔗 Related Files

**Backend:**
- `src/ContentService/ContentService.API/Controllers/Creator/CreatorPodcastsController.cs`
- `src/ContentService/ContentService.API/DTOs/PodcastRequests.cs` (CreatePodcastRequest)
- `src/ContentService/ContentService.Application/Features/Podcasts/Commands/CreatePodcastCommand.cs`

**Frontend:**
- `lib/services/api_service.dart` - API calls
- `lib/screens/create_podcast_screen.dart` - UI screen
- `lib/screens/creator_dashboard_screen.dart` - Dashboard with FAB button
- `lib/models/podcast_category.dart` - Category enums

**Gateway:**
- `ocelot.json` - Route mapping for `/api/content/creator/podcasts`

---

## 📚 Troubleshooting

### "Undefined class 'File'"
- Make sure `import 'dart:io';` is added

### "Category enum not recognized"
- Import `../models/podcast_category.dart`
- Use correct enum names (EmotionCategory, TopicCategory)

### 413 Payload Too Large
- File exceeds 500MB limit
- Check audio file size before upload

### 401 Unauthorized
- JWT token expired → User needs to login again
- Token not stored in SharedPreferences → Check auth flow

### 400 Bad Request
- Check all required fields are filled
- Audio file format is supported
- Check field names match exactly (case-sensitive)

### Form data not sent correctly
- Make sure form fields are strings (convert numbers to String with .toString())
- JSON arrays must be properly encoded with jsonEncode()
- File fields use MultipartFile.fromBytes() for reading bytes

---

## 🚀 Next Steps

1. ✅ API Service function created
2. ✅ UI Screen created
3. ✅ Dashboard button updated
4. ⏳ **Test with real app** - Run Flutter and test full flow
5. ⏳ **Backend verification** - Check S3 file storage
6. ⏳ **Production deployment** - Deploy to staging/production

---

**Created:** 2025-10-17  
**Status:** ✅ Ready for Testing  
**Author:** GitHub Copilot
