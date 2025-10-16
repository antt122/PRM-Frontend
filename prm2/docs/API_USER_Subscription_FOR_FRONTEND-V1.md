# API Documentation: User Subscription Management (v1.0)

> **Mục đích**: Tài liệu API cho Frontend Developer để implement tính năng đăng ký gói subscription của User
> 
> **Base URL**: `https://your-domain.com/api/user`
> 
> **Authentication**: Yêu cầu Bearer Token với role `User`

---

## ⚠️ CRITICAL NOTES FOR FLUTTER DEVELOPERS

### Payment Response - Only `paymentUrl` is available

Khi gọi API `POST /api/user/subscriptions/register`, response hiện tại **CHỈ TRẢ RA** field sau:

```json
{
  "paymentUrl": "https://test-payment.momo.vn/..."  // ✅ NOT NULL - USE THIS
}
```

**CÁC FIELD SAU ĐỀU NULL** (chưa implement):
```json
{
  "deepLink": null,        // ❌ NULL - Don't use
  "qrCodeBase64": null,    // ❌ NULL - Don't use
  "qrCodeDataUrl": null    // ❌ NULL - Don't use
}
```

### What Flutter App MUST Do

1. **SỬ DỤNG `paymentUrl`** để redirect user đến trang thanh toán MoMo
2. **MỞ `paymentUrl` trong WebView** (recommended) hoặc external browser
3. **KHÔNG CỐ GẮNG** sử dụng QR code hay deepLink (chúng đều null)
4. **POLL API** `GET /subscriptions/me` sau khi payment complete để check status

### Example Flutter Code

```dart
// ✅ CORRECT
final paymentUrl = response['data']['paymentUrl'];
launchUrl(Uri.parse(paymentUrl), mode: LaunchMode.externalApplication);

// ❌ WRONG - These are NULL!
final qrCode = response['data']['qrCodeBase64'];  // NULL
final deepLink = response['data']['deepLink'];     // NULL
```

---

## 📋 Table of Contents
1. [API Endpoints Overview](#api-endpoints-overview)
2. [Payment Methods APIs](#payment-methods-apis)
   - [GET /payment-methods](#1-get-payment-methods-public)
   - [GET /payment-methods/{id}](#2-get-payment-method-by-id-public)
3. [Subscription Plans APIs](#subscription-plans-apis)
   - [GET /subscription-plans](#3-get-subscription-plans-public)
   - [GET /subscription-plans/{id}](#4-get-subscription-plan-by-id-public)
4. [User Subscription APIs](#user-subscription-apis)
   - [POST /subscriptions/register](#5-register-subscription-user-only)
   - [GET /subscriptions/me](#6-get-my-subscription-user-only)
5. [Data Models](#data-models)
6. [Error Handling](#error-handling)

---

## 🎯 API Endpoints Overview

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/api/user/payment-methods` | ❌ Public | Xem danh sách payment methods |
| GET | `/api/user/payment-methods/{id}` | ❌ Public | Xem chi tiết 1 payment method |
| GET | `/api/user/subscription-plans` | ❌ Public | Xem danh sách gói subscription |
| GET | `/api/user/subscription-plans/{id}` | ❌ Public | Xem chi tiết 1 gói subscription |
| POST | `/api/user/subscriptions/register` | ✅ User | Đăng ký gói subscription (tạo payment) |
| GET | `/api/user/subscriptions/me` | ✅ User | Xem subscription hiện tại của mình |

---

## 💳 Payment Methods APIs

### 1. GET Payment Methods (Public)

**Công dụng**: Lấy danh sách các payment methods để user chọn khi đăng ký subscription

#### Request
```http
GET /api/user/payment-methods?pageNumber=1&pageSize=10
Content-Type: application/json
```

#### Query Parameters (Optional)
```json
{
  "pageNumber": 1,              // Trang hiện tại (default: 1)
  "pageSize": 10,               // Số items/trang (default: 10)
  "sortBy": "Name",             // Sắp xếp theo: Name, Type, CreatedAt
  "sortDescending": false,      // true = giảm dần, false = tăng dần
  "name": "MoMo",               // Filter theo tên payment method
  "type": 3,                    // Filter theo type: 1=CreditCard, 2=Cash, 3=EWallet, 4=BankTransfer
  "providerName": "MoMo"        // Filter theo provider
}
```

#### Response Success (200 OK)
```json
{
  "isSuccess": true,
  "message": "Payment methods retrieved successfully",
  "data": [
    {
      "id": "8ca96f85-7829-6684-d5he-4e185h88chc8",
      "name": "MoMo",
      "description": "MoMo E-Wallet Payment",
      "typeName": "EWallet",
      "type": 3,
      "providerName": "MoMo",
      "configuration": "{\"apiKey\": \"***\", \"environment\": \"sandbox\"}",
      "status": "Active",
      "createdAt": "2025-01-01T10:00:00Z",
      "createdBy": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
      "updatedAt": "2025-01-10T14:30:00Z",
      "updatedBy": "3fa85f64-5717-4562-b3fc-2c963f66afa6"
    },
    {
      "id": "9db17f96-8930-7795-e6if-5f296i99dic9",
      "name": "VNPay",
      "description": "VNPay Payment Gateway",
      "typeName": "BankTransfer",
      "type": 4,
      "providerName": "VNPay",
      "configuration": "{\"merchantId\": \"***\"}",
      "status": "Active",
      "createdAt": "2025-01-01T10:00:00Z",
      "createdBy": null,
      "updatedAt": null,
      "updatedBy": null
    }
  ],
  "pagination": {
    "totalRecords": 2,
    "currentPage": 1,
    "pageSize": 10,
    "totalPages": 1
  }
}
```

#### Frontend Usage
```javascript
// Fetch payment methods for subscription registration
async function getPaymentMethods() {
  const response = await fetch('/api/user/payment-methods?pageSize=20');
  const result = await response.json();
  
  if (result.isSuccess) {
    // Display payment methods in dropdown or radio buttons
    displayPaymentMethodOptions(result.data);
  }
}

// Display in UI
function displayPaymentMethodOptions(methods) {
  const container = document.getElementById('payment-methods');
  methods.forEach(method => {
    const option = `
      <label>
        <input type="radio" name="payment-method" value="${method.id}">
        <img src="/icons/${method.providerName.toLowerCase()}.png" alt="${method.name}">
        ${method.name} - ${method.typeName}
      </label>
    `;
    container.innerHTML += option;
  });
}
```

---

### 2. GET Payment Method by ID (Public)

**Công dụng**: Xem chi tiết 1 payment method cụ thể

#### Request
```http
GET /api/user/payment-methods/8ca96f85-7829-6684-d5he-4e185h88chc8
Content-Type: application/json
```

#### Response Success (200 OK)
```json
{
  "isSuccess": true,
  "message": "Payment method retrieved successfully",
  "data": {
    "id": "8ca96f85-7829-6684-d5he-4e185h88chc8",
    "name": "MoMo",
    "description": "MoMo E-Wallet Payment - Fast and secure payment via MoMo app",
    "typeName": "EWallet",
    "type": 3,
    "providerName": "MoMo",
    "configuration": "{\"apiKey\": \"***\", \"environment\": \"sandbox\"}",
    "status": "Active",
    "createdAt": "2025-01-01T10:00:00Z",
    "createdBy": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
    "updatedAt": "2025-01-10T14:30:00Z",
    "updatedBy": "3fa85f64-5717-4562-b3fc-2c963f66afa6"
  }
}
```

#### Response Error (404 Not Found)
```json
{
  "isSuccess": false,
  "message": "Payment method not found",
  "errorCode": 404
}
```

---

## 📦 Subscription Plans APIs

### 3. GET Subscription Plans (Public)

**Công dụng**: Lấy danh sách các gói subscription đang active để user chọn

#### Request
```http
GET /api/user/subscription-plans?pageNumber=1&pageSize=10
Content-Type: application/json
```

#### Query Parameters (Optional)
```json
{
  "pageNumber": 1,              // Trang hiện tại (default: 1)
  "pageSize": 10,               // Số items/trang (default: 10)
  "sortBy": "Amount",           // Sắp xếp theo: Amount, TrialDays, CreatedAt
  "sortDescending": false,      // true = giảm dần, false = tăng dần
  "billingPeriodUnit": 1,       // 1=Month, 2=Year (filter theo chu kỳ)
  "minAmount": 50000,           // Giá tối thiểu (VND)
  "maxAmount": 500000,          // Giá tối đa (VND)
  "hasTrialPeriod": true,       // true = chỉ lấy gói có trial
  "minTrialDays": 7,            // Số ngày trial tối thiểu
  "currency": "VND"             // Tiền tệ (VND, USD, etc.)
}
```

#### Response Success (200 OK)
```json
{
  "isSuccess": true,
  "message": "Subscription plans retrieved successfully",
  "data": [
    {
      "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
      "name": "basic_monthly",
      "displayName": "Basic Monthly",
      "description": "Access to all premium podcasts",
      "status": "Active",
      "featureConfig": "{\"maxDownloads\": 10, \"offlineMode\": true}",
      "currency": "VND",
      "billingPeriodCount": 1,
      "billingPeriodUnit": 1,
      "billingPeriodUnitName": "Month",
      "amount": 99000,
      "trialDays": 7,
      "createdAt": "2025-01-15T10:00:00Z",
      "updatedAt": "2025-01-20T14:30:00Z"
    },
    {
      "id": "4fb96f75-6828-5673-c4gd-3d074g77bgb7",
      "name": "premium_yearly",
      "displayName": "Premium Yearly",
      "description": "All features + exclusive content",
      "status": "Active",
      "featureConfig": "{\"maxDownloads\": -1, \"offlineMode\": true, \"exclusiveContent\": true}",
      "currency": "VND",
      "billingPeriodCount": 1,
      "billingPeriodUnit": 2,
      "billingPeriodUnitName": "Year",
      "amount": 999000,
      "trialDays": 30,
      "createdAt": "2025-01-15T10:00:00Z",
      "updatedAt": null
    }
  ],
  "pagination": {
    "totalRecords": 5,
    "currentPage": 1,
    "pageSize": 10,
    "totalPages": 1
  }
}
```

#### Frontend Usage
```javascript
// Fetch subscription plans
async function getSubscriptionPlans(filters = {}) {
  const queryParams = new URLSearchParams({
    pageNumber: filters.pageNumber || 1,
    pageSize: filters.pageSize || 10,
    sortBy: filters.sortBy || 'Amount',
    sortDescending: filters.sortDescending || false,
    ...filters
  });

  const response = await fetch(`/api/user/subscription-plans?${queryParams}`);
  const result = await response.json();
  
  if (result.isSuccess) {
    // Display plans in UI
    displayPlans(result.data);
  }
}
```

---

### 4. GET Subscription Plan by ID (Public)

**Công dụng**: Xem chi tiết 1 gói subscription cụ thể

#### Request
```http
GET /api/user/subscription-plans/3fa85f64-5717-4562-b3fc-2c963f66afa6
Content-Type: application/json
```

#### Response Success (200 OK)
```json
{
  "isSuccess": true,
  "message": "Subscription plan retrieved successfully",
  "data": {
    "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
    "name": "basic_monthly",
    "displayName": "Basic Monthly",
    "description": "Access to all premium podcasts with 7-day trial",
    "status": "Active",
    "featureConfig": "{\"maxDownloads\": 10, \"offlineMode\": true, \"hdAudio\": false}",
    "currency": "VND",
    "billingPeriodCount": 1,
    "billingPeriodUnit": 1,
    "billingPeriodUnitName": "Month",
    "amount": 99000,
    "trialDays": 7,
    "createdAt": "2025-01-15T10:00:00Z",
    "updatedAt": "2025-01-20T14:30:00Z"
  }
}
```

#### Response Error (404 Not Found)
```json
{
  "isSuccess": false,
  "message": "Subscription plan not found",
  "errorCode": 404
}
```

#### Frontend Usage
```javascript
// Fetch plan details for "View Details" modal
async function getPlanDetails(planId) {
  const response = await fetch(`/api/user/subscription-plans/${planId}`);
  const result = await response.json();
  
  if (result.isSuccess) {
    showPlanDetailsModal(result.data);
  }
}
```

---

## 💳 User Subscription APIs

### 5. Register Subscription (User Only)

**Công dụng**: User đăng ký gói subscription → tạo payment → nhận URL/QR code để thanh toán

**⚠️ LƯU Ý QUAN TRỌNG CHO FLUTTER APP**:
- API này tạo subscription ở trạng thái **Pending**
- Response hiện tại **CHỈ CÓ `paymentUrl` ĐƯỢC TRẢ RA** (không null)
- Các trường khác (`deepLink`, `qrCodeBase64`, `qrCodeDataUrl`) hiện tại **ĐỀU NULL**
- **Flutter app PHẢI SỬ DỤNG `paymentUrl`** để redirect user đến trang thanh toán MoMo
- Subscription chỉ active sau khi thanh toán thành công (webhook từ MoMo)

#### Request
```http
POST /api/user/subscriptions/register
Authorization: Bearer {user_jwt_token}
Content-Type: application/json
```

#### Request Body
```json
{
  "subscriptionPlanId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "paymentMethodId": "8ca96f85-7829-6684-d5he-4e185h88chc8"
}
```

#### Response Success (200 OK)

**⚠️ IMPORTANT**: Hiện tại backend chỉ trả về `paymentUrl` với giá trị không null. Các trường khác sẽ là null.

```json
{
  "isSuccess": true,
  "message": "Subscription registered successfully. Please complete payment.",
  "data": {
    "subscriptionId": "9db07f96-8930-7795-e6if-5f296i99dic9",
    "subscriptionPlanName": "Basic Monthly",
    "amount": 99000,
    "currency": "VND",
    
    // ✅ CHỈ FIELD NÀY CÓ GIÁ TRỊ - Flutter app PHẢI dùng field này
    "paymentUrl": "https://test-payment.momo.vn/v2/gateway/pay?t=TU9NT1VOVjIwMjUwMTE1...",
    
    // ❌ CÁC FIELD SAU ĐỀU NULL - Chưa implement
    "deepLink": null,
    "paymentTransactionId": "7ea18g07-9041-8906-f7jg-6g407j00ejd0",
    "qrCodeBase64": null,
    "qrCodeDataUrl": null
  }
}
```

#### Response Error Cases

**❌ 401 Unauthorized - User chưa login**
```json
{
  "isSuccess": false,
  "message": "User not authenticated",
  "errorCode": 401
}
```

**❌ 404 Not Found - Plan không tồn tại**
```json
{
  "isSuccess": false,
  "message": "Subscription plan not found or inactive",
  "errorCode": 404
}
```

**❌ 409 Conflict - User đã có subscription active**
```json
{
  "isSuccess": false,
  "message": "You are already subscribed to the 'Basic Monthly' plan",
  "errorCode": 409
}
```

**❌ 409 Conflict - User đang subscribe gói khác (upgrade chưa support)**
```json
{
  "isSuccess": false,
  "message": "You already have an active subscription to 'Basic Monthly'. Please cancel your current subscription before subscribing to a new plan. Upgrade/downgrade feature is coming soon.",
  "errorCode": 409
}
```

**❌ 500 Internal Error - Payment service timeout**
```json
{
  "isSuccess": false,
  "message": "Payment service timeout. Please try again.",
  "errorCode": 500
}
```

#### Frontend Implementation

```javascript
// Step 1: User clicks "Subscribe" button
async function registerSubscription(planId, paymentMethodId) {
  try {
    const response = await fetch('/api/user/subscriptions/register', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${userToken}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        subscriptionPlanId: planId,
        paymentMethodId: paymentMethodId
      })
    });

    const result = await response.json();

    if (!result.isSuccess) {
      // Handle errors
      if (response.status === 409) {
        alert('You already have an active subscription!');
      } else {
        alert(result.message);
      }
      return;
    }

    // ✅ Success - ONLY paymentUrl is available
    const paymentData = result.data;
    
    // ⚠️ Flutter app: Redirect to paymentUrl ONLY
    // deepLink, qrCodeBase64, qrCodeDataUrl are all NULL
    window.location.href = paymentData.paymentUrl;

  } catch (error) {
    console.error('Registration failed:', error);
    alert('Network error. Please try again.');
  }
}

// ❌ DON'T use QR code - it's NULL in current implementation
// ❌ DON'T use deepLink - it's NULL in current implementation
```

#### Flutter Implementation Example

```dart
// Step 1: Register subscription
Future<void> registerSubscription(String planId, String paymentMethodId) async {
  try {
    final response = await http.post(
      Uri.parse('${API_BASE_URL}/api/user/subscriptions/register'),
      headers: {
        'Authorization': 'Bearer $userToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'subscriptionPlanId': planId,
        'paymentMethodId': paymentMethodId,
      }),
    );

    final result = jsonDecode(response.body);

    if (!result['isSuccess']) {
      // Show error
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text(result['message']),
        ),
      );
      return;
    }

    // ✅ Get paymentUrl from response
    final paymentUrl = result['data']['paymentUrl'];
    
    // ⚠️ IMPORTANT: Only paymentUrl has value, other fields are NULL
    // Don't try to use qrCodeBase64 or deepLink - they will be null
    
    if (paymentUrl != null && paymentUrl.isNotEmpty) {
      // Step 2: Launch payment URL in browser or WebView
      await launchPaymentUrl(paymentUrl);
    } else {
      throw Exception('Payment URL is null');
    }

  } catch (e) {
    print('Registration error: $e');
    // Show error dialog
  }
}

// Step 2: Open payment URL
Future<void> launchPaymentUrl(String paymentUrl) async {
  // Option 1: Open in external browser
  if (await canLaunchUrl(Uri.parse(paymentUrl))) {
    await launchUrl(
      Uri.parse(paymentUrl),
      mode: LaunchMode.externalApplication,
    );
  }
  
  // Option 2: Open in WebView (recommended for better UX)
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PaymentWebView(url: paymentUrl),
    ),
  );
}

// Step 3: WebView widget for payment
class PaymentWebView extends StatefulWidget {
  final String url;
  
  const PaymentWebView({required this.url});
  
  @override
  State<PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  late WebViewController controller;
  
  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            // Check if payment completed (callback URL)
            if (request.url.contains('payment-success')) {
              Navigator.pop(context);
              checkSubscriptionStatus();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Complete Payment')),
      body: WebViewWidget(controller: controller),
    );
  }
}

// Step 4: Check subscription status after payment
Future<void> checkSubscriptionStatus() async {
  final response = await http.get(
    Uri.parse('${API_BASE_URL}/api/user/subscriptions/me'),
    headers: {'Authorization': 'Bearer $userToken'},
  );
  
  final result = jsonDecode(response.body);
  
  if (result['isSuccess'] && result['data']['subscriptionStatus'] == 1) {
    // Status 1 = Active
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Success'),
        content: Text('Your subscription is now active!'),
      ),
    );
  }
}
```

#### Payment Flow Diagram

```
User clicks "Subscribe"
        ↓
[POST /subscriptions/register]
        ↓
Backend creates Subscription (Pending)
Backend requests Payment Intent (RPC)
        ↓
Response: {paymentUrl: "https://..."} ✅
          {deepLink: null} ❌
          {qrCodeBase64: null} ❌
        ↓
Flutter app: MUST use paymentUrl
        ↓
Launch paymentUrl in browser/WebView
        ↓
User completes payment (MoMo app/web)
        ↓
MoMo sends webhook → PaymentService
        ↓
PaymentService updates Subscription → Active
        ↓
Flutter polls [GET /subscriptions/me]
        ↓
Show success message + enable features
```

**⚠️ Key Points for Flutter Developers**:
1. **ONLY `paymentUrl` has value** - use it to redirect/open WebView
2. **DON'T expect QR code or deepLink** - they are null in current version
3. **Use WebView** for better UX instead of external browser
4. **Poll subscription status** after payment to confirm activation

---

### 6. GET My Subscription (User Only)

**Công dụng**: User xem subscription hiện tại của mình (check active subscription)

#### Request
```http
GET /api/user/subscriptions/me
Authorization: Bearer {user_jwt_token}
Content-Type: application/json
```

#### Response Success (200 OK)
```json
{
  "isSuccess": true,
  "message": "Subscription retrieved successfully",
  "data": {
    "id": "9db07f96-8930-7795-e6if-5f296i99dic9",
    "userProfileId": "5fa96f85-7829-6684-d5he-4e185h88chc8",
    "subscriptionPlanId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
    "planName": "basic_monthly",
    "planDisplayName": "Basic Monthly",
    "subscriptionStatus": 1,
    "subscriptionStatusName": "Active",
    "currentPeriodStart": "2025-01-15T10:00:00Z",
    "currentPeriodEnd": "2025-02-15T10:00:00Z",
    "cancelAt": null,
    "canceledAt": null,
    "cancelAtPeriodEnd": false,
    "renewalBehavior": 1,
    "renewalBehaviorName": "Manual",
    "createdAt": "2025-01-15T10:00:00Z",
    "updatedAt": "2025-01-15T10:05:00Z"
  }
}
```

#### Response Error (404 Not Found - No Active Subscription)
```json
{
  "isSuccess": false,
  "message": "No active subscription found",
  "errorCode": 404
}
```

#### Response Error (401 Unauthorized)
```json
{
  "isSuccess": false,
  "message": "User not authenticated",
  "errorCode": 401
}
```

#### Frontend Usage

```javascript
// Check if user has active subscription
async function getMySubscription() {
  try {
    const response = await fetch('/api/user/subscriptions/me', {
      headers: {
        'Authorization': `Bearer ${userToken}`,
        'Content-Type': 'application/json'
      }
    });

    const result = await response.json();

    if (result.isSuccess) {
      // User has active subscription
      const sub = result.data;
      
      // Show subscription info in UI
      document.getElementById('plan-name').textContent = sub.planDisplayName;
      document.getElementById('status').textContent = sub.subscriptionStatusName;
      document.getElementById('expire-date').textContent = 
        new Date(sub.currentPeriodEnd).toLocaleDateString();

      // Enable premium features
      enablePremiumFeatures();
      
    } else if (response.status === 404) {
      // No active subscription
      showSubscriptionPrompt();
    }

  } catch (error) {
    console.error('Failed to fetch subscription:', error);
  }
}

// Check subscription on page load
window.addEventListener('DOMContentLoaded', () => {
  getMySubscription();
});
```

---

## 📊 Data Models

### PaymentMethodResponse
```typescript
interface PaymentMethodResponse {
  id: string;                      // UUID
  name: string;                    // Tên payment method (e.g., "MoMo", "VNPay")
  description: string | null;      // Mô tả chi tiết
  typeName: string;                // "CreditCard" | "Cash" | "EWallet" | "BankTransfer"
  type: number;                    // 1=CreditCard, 2=Cash, 3=EWallet, 4=BankTransfer
  providerName: string;            // Tên provider (e.g., "MoMo", "VNPay")
  configuration: string | null;    // JSON config (api keys, etc.)
  status: string;                  // "Active" | "Inactive"
  createdAt: string;               // ISO 8601
  createdBy: string | null;        // UUID
  updatedAt: string | null;        // ISO 8601
  updatedBy: string | null;        // UUID
}
```

### SubscriptionPlanResponse
```typescript
interface SubscriptionPlanResponse {
  id: string;                      // UUID
  name: string;                    // Tên kỹ thuật (e.g., "basic_monthly")
  displayName: string;             // Tên hiển thị (e.g., "Basic Monthly")
  description: string;             // Mô tả gói
  status: string;                  // "Active" | "Inactive"
  featureConfig: string;           // JSON string của features
  currency: string;                // "VND" | "USD"
  billingPeriodCount: number;      // Số chu kỳ (1, 3, 6, 12)
  billingPeriodUnit: number;       // 1=Month, 2=Year
  billingPeriodUnitName: string;   // "Month" | "Year"
  amount: number;                  // Giá (VND)
  trialDays: number;               // Số ngày trial (0 = không có trial)
  createdAt: string;               // ISO 8601
  updatedAt: string | null;        // ISO 8601
}
```

### SubscriptionResponse
```typescript
interface SubscriptionResponse {
  id: string;                         // UUID
  userProfileId: string;              // UUID
  subscriptionPlanId: string;         // UUID
  planName: string;                   // "basic_monthly"
  planDisplayName: string;            // "Basic Monthly"
  subscriptionStatus: number;         // 0=Pending, 1=Active, 2=Cancelled, 3=Expired
  subscriptionStatusName: string;     // "Pending" | "Active" | "Cancelled" | "Expired"
  currentPeriodStart: string | null;  // ISO 8601
  currentPeriodEnd: string | null;    // ISO 8601
  cancelAt: string | null;            // ISO 8601
  canceledAt: string | null;          // ISO 8601
  cancelAtPeriodEnd: boolean;         // true = cancel vào cuối chu kỳ
  renewalBehavior: number;            // 0=Auto, 1=Manual
  renewalBehaviorName: string;        // "Auto" | "Manual"
  createdAt: string;                  // ISO 8601
  updatedAt: string | null;           // ISO 8601
}
```

### RegisterSubscriptionRequest
```typescript
interface RegisterSubscriptionRequest {
  subscriptionPlanId: string;  // UUID - Required
  paymentMethodId: string;     // UUID - Required
}
```

### RegisterSubscriptionResponse
```typescript
interface RegisterSubscriptionResponse {
  subscriptionId: string;          // UUID
  subscriptionPlanName: string;    // "Basic Monthly"
  amount: number;                  // 99000
  currency: string;                // "VND"
  
  // ✅ ONLY THIS FIELD HAS VALUE
  paymentUrl: string;              // MoMo web payment URL (MUST USE THIS)
  
  // ❌ THESE FIELDS ARE NULL - NOT IMPLEMENTED YET
  deepLink: string | null;         // NULL - don't use
  paymentTransactionId: string;    // Transaction ID (can be null)
  qrCodeBase64: string | null;     // NULL - don't use
  qrCodeDataUrl: string | null;    // NULL - don't use
}
```

**⚠️ Flutter Developers Note**: 
- **Use ONLY `paymentUrl`** field for payment redirect
- All QR code related fields (`qrCodeBase64`, `qrCodeDataUrl`) are **NULL**
- `deepLink` field is also **NULL**
- Launch `paymentUrl` in WebView or external browser

---

## 🎨 Frontend UI Flow

### 1. Subscription Plans Page (Public)
```
┌─────────────────────────────────────┐
│  Available Subscription Plans       │
├─────────────────────────────────────┤
│                                     │
│  ┌─────────┐  ┌─────────┐         │
│  │ Basic   │  │ Premium │         │
│  │ Monthly │  │ Yearly  │         │
│  │ 99K/mo  │  │ 999K/yr │         │
│  │ 7d trial│  │ 30d trial│        │
│  └─────────┘  └─────────┘         │
│  [Subscribe]   [Subscribe]         │
│                                     │
└─────────────────────────────────────┘
```

### 2. Payment Flow (Flutter App)
```
┌─────────────────────────────────────┐
│  Complete Payment                   │
├─────────────────────────────────────┤
│  Plan: Basic Monthly                │
│  Amount: 99,000 VND                 │
│                                     │
│  ⚠️ ONLY paymentUrl available       │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ [Go to Payment Page] 🔗     │   │
│  │  Opens paymentUrl in        │   │
│  │  WebView or Browser         │   │
│  └─────────────────────────────┘   │
│                                     │
│  ❌ QR Code NOT available yet      │
│  ❌ DeepLink NOT available yet     │
│                                     │
│  Transaction ID: 7ea18g07...        │
└─────────────────────────────────────┘
```

### 3. My Subscription Page (User Only)
```
┌─────────────────────────────────────┐
│  My Subscription                    │
├─────────────────────────────────────┤
│  ✅ Active                          │
│  Plan: Basic Monthly                │
│  Status: Active                     │
│  Valid until: Feb 15, 2025          │
│                                     │
│  [Manage Subscription]              │
└─────────────────────────────────────┘
```

---

## ⚠️ Error Handling

### Common Error Codes

| Code | Meaning | Handling |
|------|---------|----------|
| 401 | Unauthorized | Redirect to login |
| 403 | Forbidden | Show "Access denied" |
| 404 | Not Found | Show "Resource not found" |
| 409 | Conflict | Show specific conflict message |
| 500 | Internal Error | Show "Try again later" |

### Error Response Format
```typescript
interface ErrorResponse {
  isSuccess: false;
  message: string;      // Human-readable error message
  errorCode: number;    // HTTP status code
}
```

### Frontend Error Handling
```javascript
async function handleApiCall(apiFunction) {
  try {
    const result = await apiFunction();
    
    if (!result.isSuccess) {
      switch (result.errorCode) {
        case 401:
          redirectToLogin();
          break;
        case 404:
          showNotFoundMessage(result.message);
          break;
        case 409:
          showConflictMessage(result.message);
          break;
        case 500:
          showRetryMessage(result.message);
          break;
        default:
          showGenericError(result.message);
      }
    }
    
    return result;
    
  } catch (error) {
    console.error('Network error:', error);
    showNetworkError();
  }
}
```

---

## 🧪 Testing Checklist

### Payment Methods
- [ ] Load payment methods list without authentication
- [ ] Display payment method icons/logos
- [ ] Filter by payment type (EWallet, BankTransfer, etc.)
- [ ] Select payment method for subscription

### Subscription Plans
- [ ] Load plans list without authentication
- [ ] Filter plans by price range
- [ ] Sort plans by amount
- [ ] View plan details modal
- [ ] Handle empty plans list

### Register Subscription
- [ ] Register with valid plan ID and payment method ID
- [ ] Handle duplicate subscription error
- [ ] ✅ Receive paymentUrl (NOT NULL)
- [ ] ❌ Expect deepLink to be NULL
- [ ] ❌ Expect qrCodeBase64 to be NULL
- [ ] ❌ Expect qrCodeDataUrl to be NULL
- [ ] Launch paymentUrl in WebView
- [ ] Launch paymentUrl in external browser
- [ ] Handle payment timeout error

### My Subscription
- [ ] View active subscription
- [ ] Handle no subscription (404)
- [ ] Display subscription expiry date
- [ ] Calculate remaining days
- [ ] Show subscription status badge

### Error Scenarios
- [ ] 401 - Unauthorized (no token)
- [ ] 404 - Plan not found
- [ ] 409 - Already subscribed
- [ ] 500 - Payment service timeout

---

## 📝 Important Notes

### 1. Authentication
- **Payment Methods APIs**: ❌ No authentication required (public)
- **Subscription Plans APIs**: ❌ No authentication required (public)
- **User Subscription APIs**: ✅ Requires JWT token with role `User`

### 2. Payment Flow - ⚠️ CRITICAL FOR FLUTTER DEVELOPERS
- **Register API** chỉ tạo subscription ở trạng thái **Pending**
- Response hiện tại **CHỈ TRẢ RA `paymentUrl`** với giá trị không null
- **CÁC FIELD SAU ĐỀU NULL**:
  - `deepLink`: NULL (chưa implement)
  - `qrCodeBase64`: NULL (chưa implement)
  - `qrCodeDataUrl`: NULL (chưa implement)
- **Flutter app BẮT BUỘC phải sử dụng `paymentUrl`** để redirect
- Mở `paymentUrl` trong **WebView** (recommended) hoặc external browser
- Subscription chỉ **Active** sau khi user thanh toán thành công
- Sau thanh toán, poll API `GET /subscriptions/me` để check status

### 3. Subscription Status
```typescript
enum SubscriptionStatus {
  Pending = 0,    // Chờ thanh toán
  Active = 1,     // Đang hoạt động
  Cancelled = 2,  // Đã hủy
  Expired = 3     // Hết hạn
}
```

### 4. Billing Period Unit
```typescript
enum BillingPeriodUnit {
  Month = 1,  // Tháng
  Year = 2    // Năm
}
```

### 5. Payment Type
```typescript
enum PaymentType {
  CreditCard = 1,     // Thẻ tín dụng
  Cash = 2,           // Tiền mặt
  EWallet = 3,        // Ví điện tử (MoMo, ZaloPay, etc.)
  BankTransfer = 4    // Chuyển khoản ngân hàng
}
```

### 6. ⚠️ Payment URL Usage (IMPORTANT)
```dart
// ✅ CORRECT - Use paymentUrl only
final paymentUrl = response['data']['paymentUrl'];
if (paymentUrl != null) {
  launchUrl(Uri.parse(paymentUrl));
}

// ❌ WRONG - Don't try to use these (they are null)
final qrCode = response['data']['qrCodeBase64'];  // NULL!
final deepLink = response['data']['deepLink'];    // NULL!
```

### 6. Duplicate Subscription Prevention
- User **không thể** subscribe cùng 1 plan 2 lần
- User **không thể** subscribe plan khác khi đang có active subscription
- Phải **cancel** subscription hiện tại trước khi đăng ký gói mới

### 7. Payment Method Selection
- User chọn payment method từ danh sách available payment methods
- Hiện tại hệ thống support: MoMo, VNPay, và các payment gateways khác
- Payment method ID phải được truyền vào API register subscription

---

## 🎯 Quick Reference

### Get Payment Methods (Public)
```bash
GET /api/user/payment-methods
```

### Get Plans (Public)
```bash
GET /api/user/subscription-plans
```

### Get Plan Details (Public)
```bash
GET /api/user/subscription-plans/{id}
```

### Register Subscription (User)
```bash
POST /api/user/subscriptions/register
Authorization: Bearer {token}
Body: { subscriptionPlanId, paymentMethodId }
```

### Get My Subscription (User)
```bash
GET /api/user/subscriptions/me
Authorization: Bearer {token}
```

---

**Document Version**: 1.0  
**Last Updated**: October 15, 2025  
**Status**: ✅ Ready for Frontend Implementation
