import 'package:flutter/material.dart';

class AppLocalizations {
  static const String _enLocale = 'en';
  static const String _viLocale = 'vi';

  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale(_enLocale));
  }

  late final Map<String, Map<String, String>> _localizedStrings = {
    _enLocale: _en(),
    _viLocale: _vi(),
  };

  Map<String, String> get strings =>
      _localizedStrings[locale.languageCode] ?? _localizedStrings[_enLocale]!;

  // English strings
  Map<String, String> _en() => {
        // App names
        'app_name_server': 'Clinical Sentinel',
        'app_name_client': 'Vital Horizon',

        // Client navigation
        'nav_home': 'Home',
        'nav_alerts': 'Alerts',
        'nav_profile': 'Profile',

        // Server navigation
        'nav_dashboard': 'Dashboard',
        'nav_camera': 'Camera',
        'nav_family': 'Family',
        'nav_logs': 'Logs',

        // Common
        'switch_app': 'Switch to Client',
        'switch_server': 'Switch to Server',
        'language': 'Language',
        'english': 'English',
        'vietnamese': 'Tiếng Việt',
        'logout': 'Logout',
        'login': 'Login',
        'welcome': 'Welcome',
        'settings': 'Settings',
        'back': 'Back',
        'cancel': 'Cancel',
        'save': 'Save',
        'delete': 'Delete',
        'edit': 'Edit',
        'add': 'Add',
        'refresh': 'Refresh',
        'loading': 'Loading...',
        'error': 'Error',
        'success': 'Success',

        // Home Screen
        'home_title': 'Home',
        'vital_signs': 'Vital Signs',
        'recent_activity': 'Recent Activity',
        'health_status': 'Health Status',
        'normal': 'Normal',
        'alert': 'Alert',
        'warning': 'Warning',

        // Alerts Screen
        'alerts_title': 'Alerts',
        'no_alerts': 'No alerts',
        'new_alert': 'New Alert',
        'clear_all': 'Clear All',

        // Profile Screen
        'profile_title': 'Profile',
        'personal_info': 'Personal Information',
        'emergency_contacts': 'Emergency Contacts',
        'medical_history': 'Medical History',
        'edit_profile': 'Edit Profile',
        'name': 'Name',
        'age': 'Age',
        'phone': 'Phone',
        'email': 'Email',
        'address': 'Address',

        // Dashboard Screen
        'dashboard_title': 'Dashboard',
        'monitored_elderly': 'Monitored Elderly',
        'active': 'Active',
        'inactive': 'Inactive',
        'system_status': 'System Status',
        'healthy': 'Healthy',
        'at_risk': 'At Risk',

        // Camera Config Screen
        'camera_config': 'Camera Configuration',
        'camera_setup': 'Camera Setup',
        'test_connection': 'Test Connection',
        'connected': 'Connected',
        'disconnected': 'Disconnected',
        'ip_address': 'IP Address',
        'port': 'Port',
        'username': 'Username',
        'password': 'Password',

        // Family Screen
        'family_title': 'Family Members',
        'add_member': 'Add Member',
        'manage_members': 'Manage Members',
        'relation': 'Relation',
        'contact_info': 'Contact Information',
        'primary_caregiver': 'Primary Caregiver',
        'add_to_family': 'Add to Family',
        'join_family': 'Join Family',
        'family_code': 'Family Code',
        'enter_family_code': 'Enter family code',
        'invite_link': 'Invite Link',
        'copy_link': 'Copy Link',
        'share_link': 'Share Link',
        'family_added': 'Successfully added to family',
        'family_joined': 'Successfully joined family',
        'invalid_code': 'Invalid family code',
        'member_exists': 'This member already exists',

        // System Log Screen
        'logs_title': 'System Logs',
        'log_entries': 'Log Entries',
        'export_logs': 'Export Logs',
        'timestamp': 'Timestamp',
        'event': 'Event',
        'status': 'Status',
        'details': 'Details',
        'no_logs': 'No logs available',

        // Welcome Screen
        'welcome_title': 'Welcome to Vital Horizon',
        'login_description': 'Sign in to monitor health metrics',
        'continue_button': 'Continue',

        // Live View
        'live_view': 'Live View',
        'no_camera': 'No camera available',
        'start_streaming': 'Start Streaming',
        'stop_streaming': 'Stop Streaming',

        // Messages
        'confirm_logout': 'Are you sure you want to logout?',
        'confirm_delete': 'Are you sure you want to delete this?',
        'save_success': 'Saved successfully',
        'save_failed': 'Failed to save',
        'connection_error': 'Connection error',
        'try_again': 'Try Again',

        // Authentication
        'sign_in': 'Sign In',
        'sign_up': 'Sign Up',
        'forgot_password': 'Forgot Password?',
        'dont_have_account': "Don't have an account?",
        'already_have_account': 'Already have an account?',
        'email_address': 'Email Address',
        'password_label': 'Password',
        'confirm_password': 'Confirm Password',
        'full_name': 'Full Name',
        'phone_number': 'Phone Number (Optional)',
        'password_hint': 'Min. 6 characters',
        'remember_me': 'Remember Me',
        'terms_conditions': 'I agree to the Terms & Conditions',
        'verification_code': 'Verification Code',
        'enter_code': 'Enter 6-digit code',
        'verify': 'Verify',
        'verify_email': 'Verify Email',
        'verify_password_reset': 'Verify Password Reset',
        'resend_code': 'Resend Code',
        'code_sent': 'Code sent to your email',
        'enter_email': 'Enter your email address',
        'send_code': 'Send Code',
        'new_password': 'New Password',
        'confirm_new_password': 'Confirm New Password',
        'reset_password': 'Reset Password',
        'login_success': 'Login successful',
        'register_success': 'Registration successful',
        'email_verified': 'Email verified successfully',
        'password_reset_success': 'Password reset successfully',
        'user_type_caregiver': 'Caregiver',
        'user_type_family_member': 'Family Member',
        'user_type_nurse': 'Nurse',
        'user_type_admin': 'Administrator',
        'select_role': 'Select Your Role',
        'demo_credentials': 'Demo Credentials',
        'demo_email': 'Email:',
        'demo_password': 'Password:',
      };

  // Vietnamese strings
  Map<String, String> _vi() => {
        // App names
        'app_name_server': 'Chức Năng Giám Sát',
        'app_name_client': 'Chỉ Số Sức Khỏe',

        // Client navigation
        'nav_home': 'Trang Chủ',
        'nav_alerts': 'Cảnh Báo',
        'nav_profile': 'Hồ Sơ',

        // Server navigation
        'nav_dashboard': 'Bảng Điều Khiển',
        'nav_camera': 'Camera',
        'nav_family': 'Gia Đình',
        'nav_logs': 'Nhật Ký',

        // Common
        'switch_app': 'Chuyển sang Client',
        'switch_server': 'Chuyển sang Server',
        'language': 'Ngôn Ngữ',
        'english': 'English',
        'vietnamese': 'Tiếng Việt',
        'logout': 'Đăng Xuất',
        'login': 'Đăng Nhập',
        'welcome': 'Chào Mừng',
        'settings': 'Cài Đặt',
        'back': 'Quay Lại',
        'cancel': 'Hủy',
        'save': 'Lưu',
        'delete': 'Xóa',
        'edit': 'Chỉnh Sửa',
        'add': 'Thêm',
        'refresh': 'Làm Mới',
        'loading': 'Đang Tải...',
        'error': 'Lỗi',
        'success': 'Thành Công',

        // Home Screen
        'home_title': 'Trang Chủ',
        'vital_signs': 'Dấu Hiệu Sinh Tồn',
        'recent_activity': 'Hoạt Động Gần Đây',
        'health_status': 'Tình Trạng Sức Khỏe',
        'normal': 'Bình Thường',
        'alert': 'Cảnh Báo',
        'warning': 'Cảnh Báo Cao',

        // Alerts Screen
        'alerts_title': 'Cảnh Báo',
        'no_alerts': 'Không có cảnh báo',
        'new_alert': 'Cảnh Báo Mới',
        'clear_all': 'Xóa Tất Cả',

        // Profile Screen
        'profile_title': 'Hồ Sơ Cá Nhân',
        'personal_info': 'Thông Tin Cá Nhân',
        'emergency_contacts': 'Liên Hệ Khẩn Cấp',
        'medical_history': 'Tiền Sử Bệnh',
        'edit_profile': 'Chỉnh Sửa Hồ Sơ',
        'name': 'Tên',
        'age': 'Tuổi',
        'phone': 'Số Điện Thoại',
        'email': 'Email',
        'address': 'Địa Chỉ',

        // Dashboard Screen
        'dashboard_title': 'Bảng Điều Khiển',
        'monitored_elderly': 'Người Cao Tuổi Được Giám Sát',
        'active': 'Hoạt Động',
        'inactive': 'Không Hoạt Động',
        'system_status': 'Trạng Thái Hệ Thống',
        'healthy': 'Khỏe Mạnh',
        'at_risk': 'Có Nguy Hiểm',

        // Camera Config Screen
        'camera_config': 'Cài Đặt Camera',
        'camera_setup': 'Thiết Lập Camera',
        'test_connection': 'Kiểm Tra Kết Nối',
        'connected': 'Đã Kết Nối',
        'disconnected': 'Chưa Kết Nối',
        'ip_address': 'Địa Chỉ IP',
        'port': 'Cổng',
        'username': 'Tên Đăng Nhập',
        'password': 'Mật Khẩu',

        // Family Screen
        'family_title': 'Thành Viên Gia Đình',
        'add_member': 'Thêm Thành Viên',
        'manage_members': 'Quản Lý Thành Viên',
        'relation': 'Mối Quan Hệ',
        'contact_info': 'Thông Tin Liên Hệ',
        'primary_caregiver': 'Người Chăm Sóc Chính',
        'add_to_family': 'Thêm Vào Gia Đình',
        'join_family': 'Gia Nhập Gia Đình',
        'family_code': 'Mã Gia Đình',
        'enter_family_code': 'Nhập mã gia đình',
        'invite_link': 'Liên Kết Mời',
        'copy_link': 'Sao Chép Liên Kết',
        'share_link': 'Chia Sẻ Liên Kết',
        'family_added': 'Đã thêm vào gia đình thành công',
        'family_joined': 'Đã gia nhập gia đình thành công',
        'invalid_code': 'Mã gia đình không hợp lệ',
        'member_exists': 'Thành viên này đã tồn tại',

        // System Log Screen
        'logs_title': 'Nhật Ký Hệ Thống',
        'log_entries': 'Mục Nhập Nhật Ký',
        'export_logs': 'Xuất Nhật Ký',
        'timestamp': 'Thời Gian',
        'event': 'Sự Kiện',
        'status': 'Trạng Thái',
        'details': 'Chi Tiết',
        'no_logs': 'Không có nhật ký',

        // Welcome Screen
        'welcome_title': 'Chào Mừng Đến Với Chỉ Số Sức Khỏe',
        'login_description': 'Đăng nhập để giám sát các chỉ số sức khỏe',
        'continue_button': 'Tiếp Tục',

        // Live View
        'live_view': 'Xem Trực Tiếp',
        'no_camera': 'Không có camera khả dụng',
        'start_streaming': 'Bắt Đầu Phát',
        'stop_streaming': 'Dừng Phát',

        // Messages
        'confirm_logout': 'Bạn có chắc chắn muốn đăng xuất?',
        'confirm_delete': 'Bạn có chắc chắn muốn xóa cái này?',
        'save_success': 'Lưu thành công',
        'save_failed': 'Lưu không thành công',
        'connection_error': 'Lỗi kết nối',
        'try_again': 'Thử Lại',

        // Authentication
        'sign_in': 'Đăng Nhập',
        'sign_up': 'Đăng Ký',
        'forgot_password': 'Quên Mật Khẩu?',
        'dont_have_account': 'Chưa có tài khoản?',
        'already_have_account': 'Đã có tài khoản?',
        'email_address': 'Địa Chỉ Email',
        'password_label': 'Mật Khẩu',
        'confirm_password': 'Xác Nhận Mật Khẩu',
        'full_name': 'Họ Và Tên',
        'phone_number': 'Số Điện Thoại (Tùy Chọn)',
        'password_hint': 'Tối thiểu 6 ký tự',
        'remember_me': 'Ghi Nhớ Tôi',
        'terms_conditions': 'Tôi Đồng Ý Với Điều Khoản & Điều Kiện',
        'verification_code': 'Mã Xác Thực',
        'enter_code': 'Nhập mã 6 chữ số',
        'verify': 'Xác Thực',
        'verify_email': 'Xác Thực Email',
        'verify_password_reset': 'Xác Thực Đặt Lại Mật Khẩu',
        'resend_code': 'Gửi Lại Mã',
        'code_sent': 'Mã đã được gửi tới email của bạn',
        'enter_email': 'Nhập địa chỉ email của bạn',
        'send_code': 'Gửi Mã',
        'new_password': 'Mật Khẩu Mới',
        'confirm_new_password': 'Xác Nhận Mật Khẩu Mới',
        'reset_password': 'Đặt Lại Mật Khẩu',
        'login_success': 'Đăng nhập thành công',
        'register_success': 'Đăng ký thành công',
        'email_verified': 'Email đã được xác thực thành công',
        'password_reset_success': 'Mật khẩu đã được đặt lại thành công',
        'user_type_caregiver': 'Người Chăm Sóc',
        'user_type_family_member': 'Thành Viên Gia Đình',
        'user_type_nurse': 'Y Tá',
        'user_type_admin': 'Quản Trị Viên',
        'select_role': 'Chọn Vai Trò Của Bạn',
        'demo_credentials': 'Thông Tin Đăng Nhập Demo',
        'demo_email': 'Email:',
        'demo_password': 'Mật Khẩu:',
      };

  String translate(String key) {
    return strings[key] ?? key;
  }

  String get appNameServer => translate('app_name_server');
  String get appNameClient => translate('app_name_client');
  String get navHome => translate('nav_home');
  String get navAlerts => translate('nav_alerts');
  String get navProfile => translate('nav_profile');
  String get navDashboard => translate('nav_dashboard');
  String get navCamera => translate('nav_camera');
  String get navFamily => translate('nav_family');
  String get navLogs => translate('nav_logs');
  String get switchApp => translate('switch_app');
  String get switchServer => translate('switch_server');
  String get language => translate('language');
  String get english => translate('english');
  String get vietnamese => translate('vietnamese');
  String get logout => translate('logout');
  String get homeTitle => translate('home_title');
  String get vitalSigns => translate('vital_signs');
  String get alertsTitle => translate('alerts_title');
  String get profileTitle => translate('profile_title');
  String get dashboardTitle => translate('dashboard_title');
  String get cameraConfig => translate('camera_config');
  String get familyTitle => translate('family_title');
  String get logsTitle => translate('logs_title');
  String get welcomeTitle => translate('welcome_title');
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'vi'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
