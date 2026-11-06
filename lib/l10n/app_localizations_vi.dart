// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'YiChinese';

  @override
  String get navHome => 'Trang Chính';

  @override
  String get navBooks => 'Sách';

  @override
  String get loginTitle => 'Đăng Nhập';

  @override
  String get loginUsernameLabel => 'Tên đăng nhập';

  @override
  String get loginPasswordLabel => 'Mật khẩu';

  @override
  String get loginSubmit => 'Đăng Nhập';

  @override
  String get loginFieldRequired => 'Vui lòng điền đầy đủ thông tin';

  @override
  String get loginFailed => 'Tên đăng nhập hoặc mật khẩu không đúng';

  @override
  String homeGreeting(String name) {
    return 'Xin chào, $name';
  }

  @override
  String get homeGreetingGeneric => 'Chào mừng trở lại';

  @override
  String get homeCurrentLessonKicker => 'Bài học hiện tại';

  @override
  String get homeContinueTitle => 'Bài Học Gần Đây';

  @override
  String homeContinueSubtitle(String hskLevel, int lesson, int part) {
    return '$hskLevel · Bài $lesson · Phần $part';
  }

  @override
  String get homeContinueButton => 'Tiếp Tục';

  @override
  String get homeNoRecentTitle => 'Bạn chưa bắt đầu bài học nào.';

  @override
  String get homeNoRecentMessage => 'Mở mục Sách để chọn một bài học.';

  @override
  String get homeBrowseBooks => 'Chọn Sách';

  @override
  String get homeError => 'Không thể tải bảng điều khiển.';

  @override
  String get commonRetry => 'Thử lại';

  @override
  String get commonClose => 'Đóng';

  @override
  String get logoutTooltip => 'Đăng Xuất';

  @override
  String get booksTitle => 'Chọn Sách';

  @override
  String get booksSubtitle => 'Chọn một cuốn sách để xem các bài học';

  @override
  String get booksBackToBooks => 'Về Danh Sách Sách';

  @override
  String get booksEmpty => 'Chưa có sách nào.';

  @override
  String get booksError => 'Không tải được sách.';

  @override
  String booksLessonsCount(int count) {
    return '$count bài';
  }

  @override
  String booksPartsCount(int count) {
    return '$count phần';
  }

  @override
  String get booksCompleted => 'Hoàn thành';

  @override
  String get bookError => 'Không tải được bài học.';

  @override
  String lessonLabel(String lesson) {
    return 'Bài $lesson';
  }

  @override
  String partLabel(String part) {
    return 'Phần $part';
  }

  @override
  String get studyError => 'Không thể tải đoạn văn.';

  @override
  String get studyEmpty => 'Không tìm thấy câu nào cho phần bài học này.';

  @override
  String get studyAutoPlay => 'Tự Động Phát';

  @override
  String get studyShowPinyin => 'Hiện Pinyin';

  @override
  String get studyHidePinyin => 'Ẩn Pinyin';

  @override
  String get studyShowMeaning => 'Hiện Nghĩa';

  @override
  String get studyHideMeaning => 'Ẩn Nghĩa';

  @override
  String get wordNotFound => 'Không có trong từ vựng';

  @override
  String get wordListen => 'Nghe';

  @override
  String get wordStroke => 'Nét Chữ';

  @override
  String get comingSoon => 'Sắp ra mắt';
}
