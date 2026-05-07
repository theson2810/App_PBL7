# Multi-Language Support (Tiếng Anh & Tiếng Việt)

## Tổng Quan

Ứng dụng hiện đã hỗ trợ hai ngôn ngữ:
- **English (EN)** - Mặc định
- **Tiếng Việt (VI)** - Dịch đầy đủ

## Cách Sử Dụng

### 1. **Chuyển Đổi Ngôn Ngữ Trong Ứng Dụng**

Người dùng có thể chuyển đổi ngôn ngữ qua:
- **Settings** → **Language** → Chọn **EN** hoặc **VN**

### 2. **Sử Dụng Translations Trong Code**

#### Cách Cơ Bản:
```dart
import 'package:flutter/material.dart';
import '../../localization/app_localization.dart';

// Trong build method
Text(AppLocalizations.of(context).navHome)
```

#### Hoặc Sử Dụng translate() Method:
```dart
Text(AppLocalizations.of(context).translate('nav_home'))
```

### 3. **Thêm Các Chuỗi Mới**

Để thêm một translation mới:

1. Mở file: `lib/localization/app_localization.dart`
2. Thêm key-value vào hàm `_en()` (English) và `_vi()` (Vietnamese)

**Ví dụ:**
```dart
Map<String, String> _en() => {
  ...
  'my_key': 'English text here',
  ...
};

Map<String, String> _vi() => {
  ...
  'my_key': 'Văn bản Tiếng Việt ở đây',
  ...
};
```

3. (Tùy chọn) Thêm getter property cho dễ sử dụng:
```dart
String get myKey => translate('my_key');
```

### 4. **Cấu Trúc Thư Mục**

```
lib/
├── localization/
│   ├── app_localization.dart      # Chứa tất cả translations
│   └── language_provider.dart     # Quản lý state ngôn ngữ
├── screens/
│   ├── client/
│   │   ├── profile_screen.dart    # Có language switcher
│   │   └── ...
│   └── server/
│       └── ...
└── widgets/
    └── common_widgets.dart        # Chứa LanguageSwitcher widget
```

## Danh Sách Translations

### Navigation (Điều Hướng)
- `nav_home`: Trang Chủ / Home
- `nav_alerts`: Cảnh Báo / Alerts
- `nav_profile`: Hồ Sơ / Profile
- `nav_dashboard`: Bảng Điều Khiển / Dashboard
- `nav_camera`: Camera
- `nav_family`: Gia Đình / Family
- `nav_logs`: Nhật Ký / Logs

### Common (Chung)
- `language`: Ngôn Ngữ / Language
- `logout`: Đăng Xuất / Logout
- `save`: Lưu / Save
- `delete`: Xóa / Delete
- `edit`: Chỉnh Sửa / Edit
- `loading`: Đang Tải / Loading...
- `error`: Lỗi / Error
- `success`: Thành Công / Success

### Screens (Các Màn Hình)
- `home_title`: Trang Chủ / Home
- `alerts_title`: Cảnh Báo / Alerts
- `profile_title`: Hồ Sơ Cá Nhân / Profile
- `dashboard_title`: Bảng Điều Khiển / Dashboard
- `family_title`: Thành Viên Gia Đình / Family Members
- `logs_title`: Nhật Ký Hệ Thống / System Logs

### Profile/Personal (Cá Nhân)
- `personal_info`: Thông Tin Cá Nhân / Personal Information
- `name`: Tên / Name
- `age`: Tuổi / Age
- `phone`: Số Điện Thoại / Phone
- `email`: Email
- `address`: Địa Chỉ / Address

## Ví Dụ Thực Tế

### Cập Nhật Màn Hình Với Localization:

```dart
import 'package:flutter/material.dart';
import '../../localization/app_localization.dart';

class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).homeTitle),
      ),
      body: Column(
        children: [
          Text(AppLocalizations.of(context).vitalSigns),
          ElevatedButton(
            onPressed: () {},
            child: Text(AppLocalizations.of(context).save),
          ),
        ],
      ),
    );
  }
}
```

## Ghi Chú

- Ngôn ngữ mặc định là **English**
- Khi nhân vật chuyển đổi ngôn ngữ, **tất cả các màn hình đều được cập nhật tự động**
- Nếu một translation key không tồn tại, ứng dụng sẽ hiển thị key đó (fallback)
- Cân nhắc thêm các translations cho **tất cả text strings** để cung cấp trải nghiệm hoàn chỉnh

## Thêm Ngôn Ngữ Mới

Để thêm ngôn ngữ thứ ba (ví dụ: Tiếng Trung):

1. Cập nhật `app_localization.dart`:
   - Thêm map `_zh()` cho translations Tiếng Trung
   - Thêm `'zh'` vào `_localizedStrings`

2. Cập nhật `main.dart`:
   - Thêm `Locale('zh')` vào `supportedLocales`

3. Cập nhật `language_provider.dart` (nếu cần)

## Kiểm Tra

Để xác nhận translations đang hoạt động:
1. Mở Profile → Language
2. Chuyển đổi giữa EN và VN
3. Kiểm tra rằng UI được cập nhật ngay lập tức
