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

        // Family invite & deep link
        'family_subtitle': 'Family code, join requests and email invites',
        'pending_admin_approval': 'Waiting for admin approval',
        'pending_admin_subtitle':
            'You sent a join request (code or email invite). Admin must accept before you join.',
        'send_join_request': 'Send join request (family code / ID)',
        'email_invite_section': 'Email invite (link)',
        'email_invite_help':
            'After opening the invite link, the app will apply the token automatically. Admin must still approve.',
        'invite_token_label': 'Invite token (from link)',
        'submit_email_invite': 'Submit email invite request',
        'invite_token_required': 'Enter the token from the invite link',
        'invite_processing': 'Processing family invite…',
        'invite_accepted':
            'Invite submitted. Admin will approve your request soon.',
        'invite_invalid': 'Invalid or expired invite link',
        'invite_login_required': 'Sign in to accept a family invite',
        'invite_opened': 'Family invite link received',
        'copied': 'Copied',
        'no_members_yet': 'No members yet',
        'admin_badge': 'Admin',
        'name_required': 'Full name is required',

        // Home
        'registered_cameras': 'Registered Cameras',
        'no_cameras_admin_hint': 'No cameras yet. Admin adds cameras in the server app.',
        'recent_alerts': 'Recent Alerts',
        'no_alerts_yet': 'No alerts yet.',
        'join_family_hint': 'Join a family group from the Family tab to see cameras and alerts.',
        'scan_chip_qr': 'Scan device QR (chip link)',
        'online_count': 'Online',

        // Alerts
        'alerts_subtitle': 'Recent detections — Safety is our priority',
        'tab_all': 'All',
        'tab_emergency': 'Emergency',
        'tab_history': 'History',
        'no_alerts_category': 'No alerts in this category',
        'all_safe': 'Everything looks safe',
        'mark_all_resolved': 'Mark all as resolved',
        'alert_resolved': 'Alert marked as resolved',
        'resolve': 'Resolve',
        'join_family_for_alerts': 'Join a family group to receive alerts.',
        'emergency_alert': 'EMERGENCY ALERT',
        'respond': 'Respond',
        'earlier_history': 'Earlier History',

        // Profile extras
        'profile_header': 'Profile',
        'shared_devices': 'Shared Devices',
        'shared_devices_sub': 'Manage connected health monitors',
        'family_members_setting': 'Family Members',
        'family_members_sub': 'Complete your security circle',
        'alert_preferences': 'Alert Preferences',
        'alert_preferences_sub': 'Push, SMS & email settings',
        'monitoring_schedule': 'Monitoring Schedule',
        'monitoring_on': 'ON',
        'monitoring_schedule_sub': '24/7 continuous monitoring',
        'app_settings': 'App Settings',
        'app_settings_sub': 'Theme, language & display',
        'dark_mode': 'Dark mode',
        'text_size': 'Text size',
        'privacy_security': 'Privacy & Security',
        'privacy_secure': 'Secure',
        'privacy_sub': '2FA enabled · Data encrypted',
        'help_support': 'Help & Support',
        'help_sub': 'FAQ, guides & contact support',
        'about': 'About',
        'about_sub': 'Version 1.0.0',
        'logout_subtitle': 'Sign out of the app',
        'logout_confirm_message':
            'Are you sure you want to log out? You will stop receiving real-time alerts.',
        'member_default': 'Member',
        'admin_profile_header': 'Admin Profile',

        // Auth messages
        'login_failed': 'Login failed',
        'firestore_permission_denied':
            'Firestore access denied. Deploy firestore.rules in Firebase Console (project pbl7-2a6ad).',
        'register_failed': 'Registration failed',
        'login_verify_email':
            'Signed in. Please verify your email to continue.',
        'error_prefix': 'Error',

        // Auth gate
        'loading_app': 'Loading…',
        'back_to_login': 'Back to Login',

        // Welcome
        'sign_in_tab': 'Sign In',
        'sign_up_tab': 'Sign Up',
        'create_account': 'Create Account',
        'reset_password_title': 'Reset Password',
        'role_family': 'Family member',
        'role_admin': 'Administrator (server)',
        'welcome_back': 'Welcome Back',
        'sign_in_subtitle': 'Sign in to monitor your loved one',
        'join_vital_horizon': 'Join the Vital Horizon network',
        'account_type': 'Account Type',
        'register_tab': 'Register',
        'register_success_email':
            'Registration successful! Please confirm your email',
        'email_required': 'Please enter your email',
        'password_valid': 'Enter a valid password',
        'email_required_short': 'Email is required',
        'password_min_6': 'Password must be at least 6 characters',
        'sign_in_arrow': 'Sign In →',
        'create_account_arrow': 'Create Account →',
        'feature_live_view': 'Live View',
        'feature_instant_alerts': 'Instant Alerts',
        'feature_ai_detect': 'AI Detect',
        'forgot_password_body':
            'Firebase Authentication will send a reset link to your email.',
        'send_reset_email': 'Send reset email',
        'reset_email_sent':
            'Password reset email sent. Check your inbox (and spam).',
        'reset_email_failed': 'Failed to send reset email',
        'enter_email_snack': 'Enter your email',
        'filter_alerts': 'Filter Alerts',
        'severity': 'Severity',
        'time_period': 'Time Period',
        'reset': 'Reset',
        'apply_filter': 'Apply Filter',
        'severity_all': 'All',
        'severity_emergency': 'Emergency',
        'severity_high': 'High',
        'severity_medium': 'Medium',
        'severity_notice': 'Notice',
        'period_today': 'Today',
        'period_week': 'This Week',
        'period_month': 'This Month',
        'period_all': 'All Time',
        'monitoring_section': 'Monitoring',
        'app_section': 'App',
        'family_code_label': 'Family code',
        'family_code_not_assigned': 'Not assigned',
        'admin_logout_message':
            'Are you sure you want to log out from the admin panel?',
        'app_title': 'Vital Horizon',

        // Server — dashboard
        'system_overview': 'System Overview',
        'dashboard_no_family':
            'Create or select a family to view dashboard metrics.',
        'stat_cameras': 'Cameras',
        'stat_online': 'Online',
        'stat_active_alerts': 'Active Alerts',
        'stat_family_members': 'Family Members',
        'system_online': 'System Online',
        'uptime_sample': 'Uptime: 14d 02h 45m',
        'status_active': '● ACTIVE',
        'monitoring_label': 'Monitoring',

        // Server — family management
        'server_family_title': 'Family Management',
        'server_family_subtitle':
            'One admin per group — approve members & invite via Gmail',
        'create_family_dialog_title': 'Create family group',
        'family_group_name': 'Group name',
        'create_btn': 'Create',
        'close': 'Close',
        'my_family_default': 'My family',
        'family_create_failed':
            'Could not create (you may already admin another group).',
        'family_created': 'Family group created',
        'invite_created_title': 'Invite created',
        'invite_email_line': 'Email',
        'invite_relation_line': 'Relation',
        'invite_link_line': 'Invite link (send to member)',
        'invite_approval_hint':
            'After they sign in and submit the token, approve Accept/Reject like join-code requests.',
        'no_family_banner_title': 'No family group yet',
        'no_family_banner_subtitle':
            'Admin creates one group. You will get familyId and a 6-digit join code.',
        'create_family_btn': 'Create family group',
        'invite_gmail_otp': 'Invite via Gmail + OTP',
        'join_code_6': 'Join code (6 digits)',
        'join_code': 'Join code',
        'join_code_copied': 'Join code copied',
        'family_id_label': 'Family ID',
        'pending_join_requests': 'Join requests (pending)',
        'no_pending_requests': 'No pending requests',
        'source_email_invite': 'Email invite',
        'source_join_code': 'Join code',
        'request_accepted': 'Request accepted',
        'request_rejected': 'Request rejected',
        'members_section': 'Members',
        'search_members_hint': 'Search members...',
        'administrator_role': 'Administrator',
        'administrator_default': 'Administrator',
        'account_type_label': 'Account Type',
        'contact_label': 'Contact',
        'not_set': 'Not set',
        'copied_label': 'Copied',
        'system_section': 'System',
        'permissions': 'Permissions',
        'full_system_access': 'Full system access',
        'activity_log': 'Activity Log',
        'view_system_changes': 'View system changes',
        'about_server_sub': 'Version 1.0.0 · Clinical Sentinel',
        'logout_admin_subtitle': 'Sign out of the system',

        // Server — camera
        'camera_config_subtitle':
            'Register cameras linked to edge devices (chip ID)',
        'create_family_before_camera':
            'Create a family before adding cameras.',
        'add_new_camera': 'Add New Camera',
        'camera_limit_reached': 'Maximum 4 cameras reached',
        'stat_total': 'Total',
        'stat_offline': 'Offline',
        'configured_cameras': 'Configured Cameras',
        'no_cameras_chip_hint':
            'No cameras registered. Add a camera with its chip/device ID.',
        'camera_live': 'LIVE',
        'camera_offline_badge': 'OFFLINE',
        'mark_online': 'Mark online',
        'mark_offline': 'Mark offline',
        'remove': 'Remove',
        'chip_prefix': 'Chip',
        'camera_registered': 'Camera registered',
        'camera_add_failed': 'Could not add camera',
        'add_camera_sheet_title': 'Add New Camera',
        'add_camera_sheet_help':
            'Tenda CP6: enter LAN IP — RTSP URLs are auto-filled. Run publisher on chip/laptop, then mark online.',
        'add_camera_mode_tenda': 'Tenda CP6',
        'add_camera_mode_manual': 'Manual',
        'camera_type_label': 'Camera type',
        'camera_auto_config_hint':
            'Relay ID, RTSP main stream and AI sub-stream are generated automatically from this IP.',
        'tenda_ip_label': 'Camera IP (LAN)',
        'tenda_ip_helper': 'Main: rtsp://IP/tenda · Sub: rtsp://IP/tenda_sub',
        'tenda_ip_invalid': 'Invalid IPv4 address',
        'relay_id_tenda_hint': 'Must match CAMERA_ID in python/.env on chip',
        'camera_name_label': 'Camera name',
        'chip_device_id_label': 'Chip / device ID (optional)',
        'chip_device_id_optional_hint': 'Optional edge device label',
        'relay_camera_id_label': 'Relay camera ID (VPS)',
        'relay_camera_id': 'Relay ID',
        'camera_hub_subtitle': 'Configure cameras & watch live via GCP relay',
        'camera_tab_config': 'Configure',
        'camera_tab_watch': 'Watch live',
        'relay_watch_loading': 'Fetching token & connecting…',
        'relay_watch_connected': 'Live stream connected',
        'relay_watch_reconnecting': 'Reconnecting…',
        'relay_watch_failed': 'Connection failed',
        'relay_watch_disconnected': 'Disconnected',
        'relay_watch_idle': 'Ready',
        'relay_watch_retry': 'Retry',
        'relay_not_configured':
            'Relay not configured. In Firebase Console → Firestore, create document app_config/relay with baseUrl and relayToken (see project docs).',
        'relay_token_not_configured':
            'Relay token not set. Add app_config/relay.relayToken in Firestore (same as VPS RELAY_TOKEN).',
        'relay_on_vps': 'Publishing on VPS',
        'relay_off_vps': 'Not on VPS',
        'relay_online_hint': 'Green = camera is publishing to relay (GET /cameras)',
        'camera_not_online': 'Camera is not publishing to relay yet',
        'relay_auth_failed': 'Invalid relay token — check Firestore relayToken vs VPS RELAY_TOKEN',

        // Server — logs
        'operational_logs': 'Operational Logs',
        'system_event_stream': 'System Event Stream',
        'pause_stream': 'Pause stream',
        'resume_stream': 'Resume stream',
        'export_logs_tooltip': 'Export logs',
        'tab_all_activities': 'All Activities',
        'tab_errors': 'Errors',
        'tab_warnings': 'Warnings',
        'no_family_selected': 'No family selected.',
        'event_stream_title': 'Event stream from alerts & system activity',
        'event_stream_subtitle': 'Updates in real time from Firestore',
        'uptime_label': 'Uptime',
        'latency_label': 'Latency',
        'no_events_category': 'No events in this category',
        'load_historical': 'Load Historical Records',
        'relation_spouse': 'Spouse',
        'relation_child': 'Child',
        'relation_parent': 'Parent',
        'relation_sibling': 'Sibling',
        'relation_grandchild': 'Grandchild',
        'relation_caregiver': 'Caregiver',
        'join_family_dialog_help':
            'Enter the 6-digit group code or Family ID to send a join request. Admin will approve.',
        'join_family_code_hint': 'e.g. 123456 or Family ID',

        // Wi-Fi QR family join
        'wifi_show_qr': 'Show Wi-Fi join QR',
        'wifi_qr_title': 'Join via same Wi-Fi',
        'wifi_qr_admin_help':
            'Ask the family member to scan this QR while connected to the same Wi-Fi network as this device.',
        'wifi_network_label': 'Wi-Fi network',
        'wifi_expires_in': 'Expires in',
        'wifi_refresh_qr': 'Refresh QR',
        'wifi_scan_join': 'Scan admin QR (same Wi-Fi)',
        'wifi_same_network_hint':
            'Both phones must use the same Wi-Fi. Location permission is required to verify the network name.',
        'wifi_scan_title': 'Scan family QR',
        'wifi_scan_help':
            'Point the camera at the QR code on the admin app (Family tab).',
        'wifi_your_network': 'Your Wi-Fi',
        'wifi_join_processing': 'Joining family…',
        'wifi_join_success': 'You joined the family successfully',
        'wifi_unavailable':
            'Cannot read Wi-Fi name. Connect to Wi-Fi and grant location permission.',
        'wifi_mismatch':
            'Not on the same Wi-Fi as the admin. Connect to the same network and try again.',
        'wifi_session_invalid': 'QR code is invalid or already used',
        'wifi_session_expired': 'QR code expired — ask admin to refresh',
        'wifi_permission_denied': 'Camera and location permissions are required',
        'wifi_invalid_qr': 'Invalid family QR code',
        'wifi_not_admin': 'Only the family admin can create a join QR',
        'already_member_family': 'You are already in this family',
        'cannot_join_own_family': 'Admin cannot join their own family as a member',
        'already_pending_join': 'You already have a pending join request',
        'already_in_other_family':
            'You are already in another family. Leave it before joining a new one.',
        'qr_refresh_cooldown': 'You can refresh the QR once per minute. Please wait.',
        'qr_refresh_wait': 'Refresh available in',
        'remove_member': 'Remove member',
        'remove_member_confirm':
            'Remove this member from the family? They will lose access immediately.',
        'member_removed': 'Member removed',
        'member_not_found': 'Member not found',
        'cannot_remove_admin': 'Cannot remove the family admin',
        'device_session_kicked':
            'This account was signed in on another device. You have been signed out.',
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

        'family_subtitle': 'Mã gia đình, yêu cầu tham gia và lời mời qua email',
        'pending_admin_approval': 'Đang chờ admin duyệt',
        'pending_admin_subtitle':
            'Bạn đã gửi yêu cầu (mã nhóm hoặc lời mời email). Admin chấp nhận sau bạn mới vào nhóm.',
        'send_join_request': 'Gửi yêu cầu tham gia (mã / ID gia đình)',
        'email_invite_section': 'Lời mời qua email (link)',
        'email_invite_help':
            'Sau khi mở link mời, app sẽ tự áp dụng token. Bạn vẫn phải chờ admin chấp nhận.',
        'invite_token_label': 'Token từ link mời',
        'submit_email_invite': 'Gửi yêu cầu từ lời mời email',
        'invite_token_required': 'Nhập token từ link mời',
        'invite_processing': 'Đang xử lý lời mời gia đình…',
        'invite_accepted': 'Đã gửi yêu cầu. Admin sẽ duyệt bạn sớm.',
        'invite_invalid': 'Link mời không hợp lệ hoặc đã hết hạn',
        'invite_login_required': 'Đăng nhập để chấp nhận lời mời gia đình',
        'invite_opened': 'Đã nhận link mời gia đình',
        'copied': 'Đã sao chép',
        'no_members_yet': 'Chưa có thành viên',
        'admin_badge': 'Admin',
        'name_required': 'Họ tên không được để trống',

        'registered_cameras': 'Camera đã đăng ký',
        'no_cameras_admin_hint': 'Chưa có camera. Admin thêm camera trong app server.',
        'recent_alerts': 'Cảnh báo gần đây',
        'no_alerts_yet': 'Chưa có cảnh báo.',
        'join_family_hint':
            'Gia nhập nhóm gia đình ở tab Gia đình để xem camera và cảnh báo.',
        'scan_chip_qr': 'Quét QR thiết bị (liên kết chip)',
        'online_count': 'Trực tuyến',

        'alerts_subtitle': 'Phát hiện gần đây — An toàn là ưu tiên',
        'tab_all': 'Tất cả',
        'tab_emergency': 'Khẩn cấp',
        'tab_history': 'Lịch sử',
        'no_alerts_category': 'Không có cảnh báo trong mục này',
        'all_safe': 'Mọi thứ đều an toàn',
        'mark_all_resolved': 'Đánh dấu tất cả đã xử lý',
        'alert_resolved': 'Đã đánh dấu cảnh báo đã xử lý',
        'resolve': 'Xử lý',
        'join_family_for_alerts': 'Gia nhập nhóm gia đình để nhận cảnh báo.',
        'emergency_alert': 'CẢNH BÁO KHẨN CẤP',
        'respond': 'Phản hồi',
        'earlier_history': 'Lịch sử trước đó',

        'profile_header': 'Hồ sơ',
        'shared_devices': 'Thiết bị dùng chung',
        'shared_devices_sub': 'Quản lý thiết bị giám sát sức khỏe',
        'family_members_setting': 'Thành viên gia đình',
        'family_members_sub': 'Hoàn thiện vòng an toàn',
        'alert_preferences': 'Tùy chọn cảnh báo',
        'alert_preferences_sub': 'Push, SMS & email',
        'monitoring_schedule': 'Lịch giám sát',
        'monitoring_on': 'BẬT',
        'monitoring_schedule_sub': 'Giám sát 24/7',
        'app_settings': 'Cài đặt ứng dụng',
        'app_settings_sub': 'Giao diện, ngôn ngữ & hiển thị',
        'dark_mode': 'Chế độ tối',
        'text_size': 'Cỡ chữ',
        'privacy_security': 'Riêng tư & bảo mật',
        'privacy_secure': 'An toàn',
        'privacy_sub': 'Mã hóa dữ liệu',
        'help_support': 'Trợ giúp & hỗ trợ',
        'help_sub': 'FAQ, hướng dẫn & liên hệ',
        'about': 'Giới thiệu',
        'about_sub': 'Phiên bản 1.0.0',
        'logout_subtitle': 'Đăng xuất khỏi ứng dụng',
        'logout_confirm_message':
            'Bạn có chắc muốn đăng xuất? Bạn sẽ không nhận cảnh báo thời gian thực.',
        'member_default': 'Thành viên',
        'admin_profile_header': 'Hồ sơ Admin',

        'login_failed': 'Đăng nhập thất bại',
        'firestore_permission_denied':
            'Firestore từ chối quyền truy cập. Cần deploy firestore.rules trên Firebase Console (project pbl7-2a6ad).',
        'register_failed': 'Đăng ký thất bại',
        'login_verify_email':
            'Đăng nhập thành công. Vui lòng xác thực email để tiếp tục.',
        'error_prefix': 'Lỗi',

        'loading_app': 'Đang tải…',
        'back_to_login': 'Về đăng nhập',

        'sign_in_tab': 'Đăng nhập',
        'sign_up_tab': 'Đăng ký',
        'create_account': 'Tạo tài khoản',
        'reset_password_title': 'Đặt lại mật khẩu',
        'role_family': 'Thành viên gia đình',
        'role_admin': 'Quản trị viên (server)',
        'welcome_back': 'Chào mừng trở lại',
        'sign_in_subtitle': 'Đăng nhập để theo dõi người thân',
        'join_vital_horizon': 'Tham gia mạng lưới Vital Horizon',
        'account_type': 'Loại tài khoản',
        'register_tab': 'Đăng ký',
        'register_success_email':
            'Đăng ký thành công! Vui lòng xác nhận email',
        'email_required': 'Vui lòng nhập email',
        'password_valid': 'Nhập mật khẩu hợp lệ',
        'email_required_short': 'Email là bắt buộc',
        'password_min_6': 'Mật khẩu tối thiểu 6 ký tự',
        'sign_in_arrow': 'Đăng nhập →',
        'create_account_arrow': 'Tạo tài khoản →',
        'feature_live_view': 'Xem trực tiếp',
        'feature_instant_alerts': 'Cảnh báo tức thì',
        'feature_ai_detect': 'AI phát hiện',
        'forgot_password_body':
            'Firebase Authentication sẽ gửi liên kết đặt lại mật khẩu đến email của bạn.',
        'send_reset_email': 'Gửi email đặt lại mật khẩu',
        'reset_email_sent':
            'Đã gửi email đặt lại mật khẩu. Kiểm tra hộp thư (và Spam).',
        'reset_email_failed': 'Gửi email thất bại',
        'enter_email_snack': 'Nhập email',
        'filter_alerts': 'Lọc cảnh báo',
        'severity': 'Mức độ',
        'time_period': 'Khoảng thời gian',
        'reset': 'Đặt lại',
        'apply_filter': 'Áp dụng',
        'severity_all': 'Tất cả',
        'severity_emergency': 'Khẩn cấp',
        'severity_high': 'Cao',
        'severity_medium': 'Trung bình',
        'severity_notice': 'Thông báo',
        'period_today': 'Hôm nay',
        'period_week': 'Tuần này',
        'period_month': 'Tháng này',
        'period_all': 'Tất cả',
        'monitoring_section': 'Giám sát',
        'app_section': 'Ứng dụng',
        'family_code_label': 'Mã gia đình',
        'family_code_not_assigned': 'Chưa gán',
        'admin_logout_message':
            'Bạn có chắc muốn đăng xuất khỏi bảng quản trị?',
        'app_title': 'Vital Horizon',

        'system_overview': 'Tổng quan hệ thống',
        'dashboard_no_family':
            'Tạo hoặc chọn nhóm gia đình để xem số liệu bảng điều khiển.',
        'stat_cameras': 'Camera',
        'stat_online': 'Trực tuyến',
        'stat_active_alerts': 'Cảnh báo đang mở',
        'stat_family_members': 'Thành viên',
        'system_online': 'Hệ thống hoạt động',
        'uptime_sample': 'Uptime: 14 ngày 02g 45p',
        'status_active': '● HOẠT ĐỘNG',
        'monitoring_label': 'Giám sát',

        'server_family_title': 'Quản lý gia đình',
        'server_family_subtitle':
            'Một admin / nhóm — duyệt thành viên & mời qua Gmail',
        'create_family_dialog_title': 'Tạo nhóm gia đình',
        'family_group_name': 'Tên nhóm',
        'create_btn': 'Tạo',
        'close': 'Đóng',
        'my_family_default': 'Gia đình của tôi',
        'family_create_failed':
            'Không tạo được (có thể bạn đã là admin của một nhóm khác).',
        'family_created': 'Đã tạo nhóm gia đình',
        'invite_created_title': 'Lời mời đã tạo',
        'invite_email_line': 'Email',
        'invite_relation_line': 'Quan hệ',
        'invite_link_line': 'Liên kết mời (gửi cho thành viên)',
        'invite_approval_hint':
            'Sau khi thành viên đăng nhập và gửi token trong app, bạn vẫn duyệt Chấp nhận/Từ chối như yêu cầu bằng mã nhóm.',
        'no_family_banner_title': 'Chưa có nhóm gia đình',
        'no_family_banner_subtitle':
            'Admin tạo một nhóm duy nhất. Bạn sẽ có familyId và mã tham gia 6 số.',
        'create_family_btn': 'Tạo nhóm gia đình',
        'invite_gmail_otp': 'Mời qua Gmail + OTP',
        'join_code_6': 'Mã tham gia (6 số)',
        'join_code': 'Mã tham gia',
        'join_code_copied': 'Đã sao chép mã',
        'family_id_label': 'Family ID',
        'pending_join_requests': 'Yêu cầu tham gia (chờ duyệt)',
        'no_pending_requests': 'Không có yêu cầu chờ duyệt',
        'source_email_invite': 'Lời mời email',
        'source_join_code': 'Mã nhóm',
        'request_accepted': 'Đã chấp nhận',
        'request_rejected': 'Đã từ chối',
        'members_section': 'Thành viên',
        'search_members_hint': 'Tìm thành viên...',
        'administrator_role': 'Quản trị viên',
        'administrator_default': 'Quản trị viên',
        'account_type_label': 'Loại tài khoản',
        'contact_label': 'Liên hệ',
        'not_set': 'Chưa thiết lập',
        'copied_label': 'Đã sao chép',
        'system_section': 'Hệ thống',
        'permissions': 'Quyền hạn',
        'full_system_access': 'Toàn quyền hệ thống',
        'activity_log': 'Nhật ký hoạt động',
        'view_system_changes': 'Xem thay đổi hệ thống',
        'about_server_sub': 'Phiên bản 1.0.0 · Clinical Sentinel',
        'logout_admin_subtitle': 'Đăng xuất khỏi hệ thống',

        'camera_config_subtitle':
            'Đăng ký camera gắn thiết bị biên (chip ID)',
        'create_family_before_camera':
            'Tạo nhóm gia đình trước khi thêm camera.',
        'add_new_camera': 'Thêm camera mới',
        'camera_limit_reached': 'Tối đa 4 camera',
        'stat_total': 'Tổng',
        'stat_offline': 'Ngoại tuyến',
        'configured_cameras': 'Camera đã cấu hình',
        'no_cameras_chip_hint':
            'Chưa có camera. Thêm camera kèm chip/device ID.',
        'camera_live': 'TRỰC TIẾP',
        'camera_offline_badge': 'NGOẠI TUYẾN',
        'mark_online': 'Đánh dấu online',
        'mark_offline': 'Đánh dấu offline',
        'remove': 'Xóa',
        'chip_prefix': 'Chip',
        'camera_registered': 'Đã đăng ký camera',
        'camera_add_failed': 'Không thêm được camera',
        'add_camera_sheet_title': 'Thêm camera mới',
        'add_camera_sheet_help':
            'Tenda CP6: nhập IP LAN — URL RTSP tự điền. Chạy publisher trên chip/laptop, rồi đánh dấu online.',
        'add_camera_mode_tenda': 'Tenda CP6',
        'add_camera_mode_manual': 'Thủ công',
        'camera_type_label': 'Loại camera',
        'camera_auto_config_hint':
            'Relay ID, luồng RTSP chính và luồng phụ cho AI sẽ tự sinh từ IP này.',
        'tenda_ip_label': 'IP camera (LAN)',
        'tenda_ip_helper': 'Chính: rtsp://IP/tenda · Phụ: rtsp://IP/tenda_sub',
        'tenda_ip_invalid': 'Địa chỉ IPv4 không hợp lệ',
        'relay_id_tenda_hint': 'Phải khớp CAMERA_ID trong python/.env trên chip',
        'camera_name_label': 'Tên camera',
        'chip_device_id_label': 'Chip / device ID (tùy chọn)',
        'chip_device_id_optional_hint': 'Nhãn thiết bị biên (tùy chọn)',
        'relay_camera_id_label': 'Relay camera ID (VPS)',
        'relay_camera_id': 'Relay ID',
        'camera_hub_subtitle': 'Cấu hình camera & xem live qua GCP relay',
        'camera_tab_config': 'Cấu hình',
        'camera_tab_watch': 'Xem trực tiếp',
        'relay_watch_loading': 'Đang lấy token & kết nối…',
        'relay_watch_connected': 'Đã kết nối luồng trực tiếp',
        'relay_watch_reconnecting': 'Đang kết nối lại…',
        'relay_watch_failed': 'Kết nối thất bại',
        'relay_watch_disconnected': 'Đã ngắt kết nối',
        'relay_watch_idle': 'Sẵn sàng',
        'relay_watch_retry': 'Thử lại',
        'relay_not_configured':
            'Chưa cấu hình relay. Trên Firebase Console → Firestore, tạo document app_config/relay với baseUrl và relayToken.',
        'relay_token_not_configured':
            'Chưa cấu hình relay token. Thêm app_config/relay.relayToken trên Firestore (trùng RELAY_TOKEN trên VPS).',
        'relay_on_vps': 'Đang publish trên VPS',
        'relay_off_vps': 'Chưa có trên VPS',
        'relay_online_hint': 'Xanh = camera đang publish lên relay (GET /cameras)',
        'camera_not_online': 'Camera chưa publish lên relay',
        'relay_auth_failed': 'Sai relay token — kiểm tra Firestore relayToken và RELAY_TOKEN trên VPS',

        'operational_logs': 'Nhật ký vận hành',
        'system_event_stream': 'Luồng sự kiện hệ thống',
        'pause_stream': 'Tạm dừng luồng',
        'resume_stream': 'Tiếp tục luồng',
        'export_logs_tooltip': 'Xuất nhật ký',
        'tab_all_activities': 'Tất cả hoạt động',
        'tab_errors': 'Lỗi',
        'tab_warnings': 'Cảnh báo',
        'no_family_selected': 'Chưa chọn nhóm gia đình.',
        'event_stream_title': 'Luồng sự kiện từ cảnh báo & hoạt động hệ thống',
        'event_stream_subtitle': 'Cập nhật thời gian thực từ Firestore',
        'uptime_label': 'Uptime',
        'latency_label': 'Độ trễ',
        'no_events_category': 'Không có sự kiện trong mục này',
        'load_historical': 'Tải lịch sử',
        'relation_spouse': 'Vợ/Chồng',
        'relation_child': 'Con',
        'relation_parent': 'Cha/Mẹ',
        'relation_sibling': 'Anh/Chị/Em',
        'relation_grandchild': 'Cháu',
        'relation_caregiver': 'Người chăm sóc',
        'join_family_dialog_help':
            'Nhập mã 6 số của nhóm hoặc Family ID để gửi yêu cầu tham gia. Admin sẽ duyệt.',
        'join_family_code_hint': 'VD: 123456 hoặc Family ID',

        'wifi_show_qr': 'Hiển thị QR tham gia (cùng Wi-Fi)',
        'wifi_qr_title': 'Tham gia qua cùng Wi-Fi',
        'wifi_qr_admin_help':
            'Nhờ thành viên quét mã QR khi điện thoại đang kết nối cùng mạng Wi-Fi với thiết bị admin.',
        'wifi_network_label': 'Mạng Wi-Fi',
        'wifi_expires_in': 'Hết hạn sau',
        'wifi_refresh_qr': 'Làm mới QR',
        'wifi_scan_join': 'Quét QR admin (cùng Wi-Fi)',
        'wifi_same_network_hint':
            'Hai điện thoại phải dùng chung Wi-Fi. Cần quyền vị trí để xác minh tên mạng.',
        'wifi_scan_title': 'Quét QR gia đình',
        'wifi_scan_help':
            'Hướng camera vào mã QR trên app admin (tab Gia đình).',
        'wifi_your_network': 'Wi-Fi của bạn',
        'wifi_join_processing': 'Đang tham gia nhóm…',
        'wifi_join_success': 'Đã tham gia nhóm gia đình thành công',
        'wifi_unavailable':
            'Không đọc được tên Wi-Fi. Hãy bật Wi-Fi và cấp quyền vị trí.',
        'wifi_mismatch':
            'Không cùng Wi-Fi với admin. Kết nối đúng mạng rồi thử lại.',
        'wifi_session_invalid': 'Mã QR không hợp lệ hoặc đã dùng',
        'wifi_session_expired': 'Mã QR hết hạn — nhờ admin làm mới',
        'wifi_permission_denied': 'Cần quyền camera và vị trí',
        'wifi_invalid_qr': 'Mã QR gia đình không hợp lệ',
        'wifi_not_admin': 'Chỉ admin nhóm mới tạo được QR',
        'already_member_family': 'Bạn đã ở trong nhóm này',
        'cannot_join_own_family': 'Admin không thể tham gia nhóm của chính mình',
        'already_pending_join': 'Bạn đã có yêu cầu tham gia đang chờ',
        'already_in_other_family':
            'Bạn đã thuộc một nhóm khác. Rời nhóm đó trước khi tham gia nhóm mới.',
        'qr_refresh_cooldown': 'Chỉ làm mới QR tối đa 1 lần/phút. Vui lòng đợi.',
        'qr_refresh_wait': 'Làm mới sau',
        'remove_member': 'Xóa thành viên',
        'remove_member_confirm':
            'Xóa thành viên khỏi nhóm? Họ sẽ mất quyền truy cập ngay.',
        'member_removed': 'Đã xóa thành viên',
        'member_not_found': 'Không tìm thấy thành viên',
        'cannot_remove_admin': 'Không thể xóa admin nhóm',
        'device_session_kicked':
            'Tài khoản đã đăng nhập trên thiết bị khác. Bạn đã bị đăng xuất.',
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
  String get signInTab => translate('sign_in_tab');
  String get signUpTab => translate('sign_up_tab');
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
