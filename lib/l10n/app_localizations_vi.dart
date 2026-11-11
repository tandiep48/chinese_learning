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
  String get navDashboard => 'Bảng Điều Khiển';

  @override
  String get navLibrary => 'Thư Viện';

  @override
  String get navVocabulary => 'Từ Vựng';

  @override
  String get navRecommend => 'Gợi Ý';

  @override
  String get navSettings => 'Cài Đặt';

  @override
  String get navLogout => 'Đăng Xuất';

  @override
  String get settingsLanguage => 'Ngôn ngữ';

  @override
  String get settingsScript => 'Chữ viết';

  @override
  String get settingsFont => 'Phông chữ';

  @override
  String get settingsLangVi => 'Tiếng Việt';

  @override
  String get settingsLangEn => 'English';

  @override
  String get settingsScriptSimplified => '简体 Giản thể';

  @override
  String get settingsScriptTraditional => '繁體 Phồn thể';

  @override
  String get settingsHanziNote =>
      'Kiểu chữ Hán sẽ được áp dụng trong bản cập nhật sau.';

  @override
  String get settingsSaveError => 'Không thể lưu tùy chọn.';

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
  String get registerTitle => 'Đăng Ký';

  @override
  String get registerEmailLabel => 'Email';

  @override
  String get registerSubmit => 'Đăng Ký';

  @override
  String get registerPasswordHint => 'Ít nhất 8 ký tự';

  @override
  String get registerFailed => 'Đăng ký thất bại';

  @override
  String get noAccountPrompt => 'Chưa có tài khoản?';

  @override
  String get registerHere => 'Đăng ký tại đây';

  @override
  String get haveAccountPrompt => 'Đã có tài khoản?';

  @override
  String get loginHere => 'Đăng nhập tại đây';

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
  String get homeBrowseHsk => 'Học theo cấp độ HSK';

  @override
  String get homeTabLesson => 'Bài học';

  @override
  String get homeTabReview => 'Ôn từ vựng';

  @override
  String get homeTabRecommend => 'Gợi ý';

  @override
  String get homeReviewStub => 'Ôn tập từ vựng sẽ sớm có mặt.';

  @override
  String get homeRecommendStub => 'Gợi ý luyện tập sẽ sớm có mặt.';

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
  String get libraryTabHsk => 'HSK';

  @override
  String get hskSelectLevelTitle => 'Chọn Cấp Độ HSK';

  @override
  String get hskSelectLevelSubtitle => 'Chọn cấp độ để xem các bài học';

  @override
  String get hskSelectLessonTitle => 'Chọn Bài Học';

  @override
  String hskLessonsAvailable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bài học',
    );
    return '$_temp0';
  }

  @override
  String get hskSearchPlaceholder => 'Tìm bài học';

  @override
  String get hskNoLessons => 'Không tìm thấy bài học nào cho cấp độ này.';

  @override
  String get hskNoMatch => 'Không có bài học nào khớp với tìm kiếm.';

  @override
  String get hskOtherPassages => 'Bài Khác';

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
  String get strokeAnimate => 'Diễn Hoạt';

  @override
  String get strokePractice => 'Luyện Tập';

  @override
  String get strokeReset => 'Đặt Lại';

  @override
  String get strokeLoadError => 'Không tải được thứ tự nét.';

  @override
  String get practiceLoading => 'Đang tải bài luyện tập…';

  @override
  String get practiceLoadFailed => 'Không thể tải dữ liệu luyện tập.';

  @override
  String get practiceCompleteTitle => 'Hoàn Thành Luyện Tập!';

  @override
  String get practiceSetLabel => 'Bộ Luyện Tập';

  @override
  String get practiceCorrectAnswers => 'Câu trả lời đúng';

  @override
  String get practiceRetry => 'Làm Lại';

  @override
  String get practiceCheck => 'Kiểm Tra';

  @override
  String get practiceSkip => 'Bỏ qua';

  @override
  String get practicePrevious => 'Câu trước';

  @override
  String get practiceSubmitting => 'Đang nộp bài...';

  @override
  String get practiceFinish => 'Hoàn thành';

  @override
  String get practiceBack => 'Quay lại';

  @override
  String get practiceListening => 'Nghe';

  @override
  String get practiceReading => 'Đọc';

  @override
  String get practiceTrueLabel => 'Đúng';

  @override
  String get practiceFalseLabel => 'Sai';

  @override
  String get practiceYourOrder => 'Thứ tự của bạn (nhấn để đặt):';

  @override
  String get practiceSentencesClickAdd => 'Các câu (nhấn để thêm):';

  @override
  String get practiceChooseFromOptions => 'Chọn từ các đáp án:';

  @override
  String get practiceChooseImagePerSentence =>
      'Chọn hình ảnh phù hợp với từng câu.';

  @override
  String get practiceChooseAnswerPerSentence =>
      'Chọn đáp án phù hợp với từng câu bên dưới.';

  @override
  String get practiceChooseImageForAudio =>
      'Nghe hội thoại và chọn hình ảnh phù hợp.';

  @override
  String get practicePlayPassage => 'Phát Đoạn Văn';

  @override
  String get practiceCorrectExclaim => 'Chính xác!';

  @override
  String get practiceBack5 => 'Lùi 5 giây';

  @override
  String get practiceForward5 => 'Tiến 5 giây';

  @override
  String get practiceStopAudio => 'Dừng âm thanh';

  @override
  String get practiceSeekSlider => 'Tua vị trí âm thanh';

  @override
  String get practiceAudioFallback => 'Âm thanh';

  @override
  String practiceQuestionNumber(int n) {
    return 'Câu $n';
  }

  @override
  String practiceQuestionsGroup(String progress) {
    return 'Câu $progress';
  }

  @override
  String practiceCorrectOrder(String order) {
    return 'Thứ tự đúng: $order';
  }

  @override
  String practiceCorrectAnswerColon(String answer) {
    return 'Đáp án đúng: $answer';
  }

  @override
  String practiceScoreCorrect(int correct, int total) {
    return '$correct / $total đúng';
  }

  @override
  String practiceAudioNumbered(int n) {
    return 'Âm Thanh $n';
  }

  @override
  String practicePlayLabel(String label) {
    return 'Phát $label';
  }

  @override
  String get commonLoadMore => 'Tải thêm';

  @override
  String get dashboardTotalTime => 'Tổng Thời Gian';

  @override
  String get dashboardWordsMastered => 'Từ Đã Thành Thạo';

  @override
  String get dashboardTimeLearned3days => 'Thời Gian Học (3 Ngày Gần Nhất)';

  @override
  String get dashboardWordsMastered3days =>
      'Từ Đã Thành Thạo (3 Ngày Gần Nhất)';

  @override
  String get dashboardNoChartData =>
      'Chưa có hoạt động gần đây để hiển thị biểu đồ.';

  @override
  String get dashboardExercise => 'Luyện Tập';

  @override
  String get dashboardExam => 'Kiểm Tra';

  @override
  String get dashboardLessonTrainer => 'Luyện Bài Học';

  @override
  String get dashboardVocabTrainer => 'Luyện Từ Vựng';

  @override
  String get dashboardLearningStatistics => 'Thống Kê Học Tập';

  @override
  String get profileTitle => 'Hồ Sơ';

  @override
  String get profileLearnedWords => 'Từ Đã Học';

  @override
  String get reviewHeading => 'Từ Của Bạn';

  @override
  String get reviewTabRecent => 'Từ học gần đây';

  @override
  String get reviewTabReview => 'Từ cần ôn';

  @override
  String get reviewSubtitleRecent =>
      'Những từ bạn vừa thành thạo gần đây nhất.';

  @override
  String get reviewSubtitleReview =>
      'Những từ cần xem lại — chưa thành thạo hoặc trả lời chậm.';

  @override
  String get reviewEmptyRecent => 'Bạn chưa thành thạo từ nào.';

  @override
  String get reviewEmptyReview => 'Hiện không có từ nào cần ôn.';

  @override
  String get reviewLoading => 'Đang tải từ vựng của bạn...';

  @override
  String get reviewLoadFailed => 'Không thể tải từ vựng. Vui lòng thử lại.';

  @override
  String get reviewPrevPage => 'Trang trước';

  @override
  String get reviewNextPage => 'Trang sau';

  @override
  String reviewPageRange(int start, int end, int total) {
    return '$start-$end trong $total';
  }

  @override
  String get recommendFinding => 'Đang tìm đề xuất…';

  @override
  String get recommendAnalysing => 'Đang phân tích tiến độ từ vựng của bạn.';

  @override
  String get recommendErrorTitle => 'Đã xảy ra lỗi';

  @override
  String get recommendConnectFailed => 'Không thể kết nối đến máy chủ.';

  @override
  String get recommendFailedLoad => 'Không thể tải đề xuất.';

  @override
  String get recommendEmptyTitle => 'Chưa có đề xuất nào';

  @override
  String get recommendEmptySub =>
      'Tiếp tục học từ vựng để mở khóa các nhóm luyện tập được đề xuất!';

  @override
  String get recommendNewUserTitle => 'Chào mừng! Bạn chỉ mới bắt đầu.';

  @override
  String get recommendNewUserSub =>
      'Bạn chưa luyện tập từ vựng nào. Các bài học đề xuất sẽ tự động mở khóa khi bạn học từ — hãy bắt đầu với Trình Luyện Từ Vựng!';

  @override
  String get recommendStart => 'Bắt đầu';

  @override
  String get recommendLessonPrefix => 'Bài';

  @override
  String get recommendStatusNotStart => 'Chưa bắt đầu';

  @override
  String get recommendStatusFinishSuccess => 'Hoàn thành và đúng';

  @override
  String get recommendStatusFinishFail => 'Hoàn thành và sai';

  @override
  String recommendGroupsFound(int count) {
    return 'Tìm thấy $count nhóm câu hỏi sẵn sàng luyện tập.';
  }

  @override
  String recommendQuestionCount(int count) {
    return '$count câu hỏi';
  }

  @override
  String recommendQuestionSingle(String n) {
    return 'Câu $n';
  }

  @override
  String recommendQuestionsRange(String a, String b) {
    return 'Câu $a–$b';
  }

  @override
  String recommendNewFocus(String words) {
    return 'Trọng tâm mới: $words';
  }

  @override
  String get grammarTitle => 'Ngữ Pháp';

  @override
  String get grammarErrorLoading => 'Lỗi khi tải ngữ pháp.';

  @override
  String get grammarNoRules => 'Không có quy tắc ngữ pháp cho bài này.';

  @override
  String get translationTitle => 'Bản Dịch';

  @override
  String get translationFailedLoad => 'Tải bản dịch thất bại.';

  @override
  String get translationEmpty => 'Không tìm thấy bản dịch cho bài học này.';

  @override
  String get translationInputPlaceholder => 'Nhập tiếng Trung vào đây';

  @override
  String get translationReveal => 'Xem đáp án';

  @override
  String get translationHide => 'Ẩn đáp án';

  @override
  String get translationShuffle => 'Xáo Trộn';

  @override
  String get translationPrev => 'Trước';

  @override
  String get translationNext => 'Tiếp';

  @override
  String get examChooseLevel => 'Chọn bộ HSK để bắt đầu bài kiểm tra của bạn.';

  @override
  String get examChooseLesson => 'Chọn một bài học để bắt đầu bài kiểm tra.';

  @override
  String get examNoLessons => 'Không tìm thấy bài học nào.';

  @override
  String get examListeningReading => 'Nghe & Đọc';

  @override
  String get examLessonPrefix => 'Bài';

  @override
  String get libraryTabPractice => 'Luyện tập';

  @override
  String get practiceChooseLevel => 'Chọn cấp HSK để luyện tập.';

  @override
  String get practiceChooseLesson => 'Chọn một bài để luyện tập.';

  @override
  String get practiceLessonPrefix => 'Bài';

  @override
  String get practiceNoLessons => 'Không tìm thấy bài học.';

  @override
  String get pinyinTitle => 'Pinyin';

  @override
  String get pinyinLessonHeading => 'HSK 1 - Bài 1';

  @override
  String get pinyinGuideEntry => 'Hướng Dẫn Pinyin';

  @override
  String get numbersEntry => 'Số Đếm';

  @override
  String get pinyinBasic => 'Cơ Bản';

  @override
  String get pinyinAdvanced => 'Nâng Cao';

  @override
  String get pinyinInitials => 'Phụ Âm Đầu';

  @override
  String get pinyinFinals => 'Vận Mẫu';

  @override
  String get pinyinTones => 'Thanh Điệu';

  @override
  String pinyinPronunciationFor(String syllable) {
    return 'Cách phát âm của $syllable';
  }

  @override
  String get comingSoon => 'Sắp ra mắt';

  @override
  String milestoneStepCounter(int n, int total) {
    return 'Bước $n/$total';
  }

  @override
  String get milestoneStepVocabSummary => 'Tổng quan từ vựng';

  @override
  String get milestoneStepVocabLearner => 'Học từ vựng';

  @override
  String get milestoneStepVocabTrainer => 'Luyện từ vựng';

  @override
  String get milestoneStepLessonSummary => 'Tổng quan bài học';

  @override
  String get milestoneStepLessonLearner => 'Học bài';

  @override
  String get milestoneStepLessonTrainer => 'Luyện bài';

  @override
  String get milestoneContinue => 'Tiếp tục';

  @override
  String get milestoneQuit => 'Thoát';

  @override
  String get milestoneStepComingSoon => 'Bước này sẽ sớm có mặt.';

  @override
  String trainerTaskCounter(int current, int total) {
    return 'Nhiệm vụ $current/$total';
  }

  @override
  String trainerScore(int correct, int total) {
    return 'Đúng $correct/$total';
  }

  @override
  String get trainerSkip => 'Bỏ Qua';

  @override
  String get trainerCheck => 'Kiểm tra';

  @override
  String get trainerNext => 'Tiếp theo';

  @override
  String get trainerLoadFailed => 'Không tải được bài học. Vui lòng thử lại.';

  @override
  String get trainerNoTasks => 'Phần này chưa có bài tập nào.';

  @override
  String get lessonInstructionMeaning => 'Câu này có nghĩa là gì?';

  @override
  String get lessonInstructionTyping => 'Nhập câu sau bằng tiếng Trung:';

  @override
  String get lessonInstructionReorder =>
      'Sắp xếp các từ để tạo thành câu đúng:';

  @override
  String get lessonTypingPlaceholder => 'Nhập câu vào đây...';

  @override
  String get lessonYourSentence => 'Câu Của Bạn:';

  @override
  String get lessonAvailableWords => 'Từ Có Sẵn:';

  @override
  String get lessonCorrectAnswerLabel => 'Đáp Án Đúng:';

  @override
  String get lessonCompleteTitle => 'Hoàn Thành Bài Học!';

  @override
  String get lessonCompleteBody => 'Bạn đã hoàn thành bài luyện tập này.';

  @override
  String get lessonRecapTitle => 'Tổng Kết Câu Sai';

  @override
  String get lessonTableYourAnswer => 'Câu Trả Lời Của Bạn';

  @override
  String get lessonTableCorrectAnswer => 'Đáp Án Đúng';

  @override
  String get lessonPerfect =>
      'Không có câu sai nào trong lượt này. Làm tốt lắm!';

  @override
  String get lessonRetryMissed => 'Làm Lại Câu Sai';

  @override
  String get vocabInstructionTyping => 'Nhập mỗi từ bằng tiếng Trung';

  @override
  String get vocabInstructionMatch => 'Nối mỗi từ với nghĩa của nó';

  @override
  String vocabGroupCounter(int current, int total) {
    return 'Nhóm $current/$total';
  }

  @override
  String get vocabNoWords => 'Phần này chưa có từ vựng để luyện.';

  @override
  String get vocabCompleteTitle => 'Hoàn Thành Từ Vựng!';

  @override
  String get flashTapToFlip => 'Chạm để xem nghĩa';

  @override
  String get competitionTitle => 'Học Cùng Nhau';

  @override
  String get competitionSubtitle =>
      'Thi đấu với người học khác theo thời gian thực';

  @override
  String get competitionCreateRoom => 'Tạo Phòng';

  @override
  String get competitionEditSettings => 'Chỉnh Cài Đặt';

  @override
  String get competitionMode => 'Chế độ';

  @override
  String get competitionModeVocab => 'Từ vựng';

  @override
  String get competitionModeLesson => 'Bài học';

  @override
  String get competitionModeBook => 'Sách';

  @override
  String get competitionBook => 'Sách';

  @override
  String get competitionSelectBook => 'Chọn một cuốn sách';

  @override
  String get competitionType => 'Loại kỹ năng';

  @override
  String get competitionTypeAll => 'Tất cả';

  @override
  String get competitionTypeTyping => 'Gõ chữ';

  @override
  String get competitionTypeListening => 'Nghe';

  @override
  String get competitionTypeReading => 'Đọc';

  @override
  String get competitionTypeMeaning => 'Nghĩa';

  @override
  String get competitionTypeReorder => 'Sắp xếp';

  @override
  String get competitionMaxUsers => 'Số người tối đa';

  @override
  String get competitionTimeLimit => 'Giới hạn thời gian';

  @override
  String competitionMinutes(int n) {
    return '$n phút';
  }

  @override
  String get competitionSaveChanges => 'Lưu Thay Đổi';

  @override
  String get competitionCancel => 'Hủy';

  @override
  String get competitionJoinRoom => 'Vào Phòng';

  @override
  String get competitionRoomCode => 'Mã phòng';

  @override
  String get competitionOpenRoomsTitle => 'Phòng Đang Mở';

  @override
  String get competitionNoOpenRooms => 'Hiện chưa có phòng nào đang mở.';

  @override
  String get competitionRoomFull => 'Đầy';

  @override
  String competitionLearnersCount(int current, int max) {
    return '$current/$max người học';
  }

  @override
  String competitionPageStatus(int current, int total) {
    return 'Trang $current/$total';
  }

  @override
  String get competitionSelectHsk => 'Chọn cấp HSK';

  @override
  String get competitionSelectAll => 'Chọn tất cả';

  @override
  String get competitionSelectLesson => 'Chọn một bài học';

  @override
  String get competitionSelectPart => 'Chọn một phần';

  @override
  String get competitionLessonPrefix => 'Bài';

  @override
  String get competitionPartPrefix => 'Phần';

  @override
  String get competitionOtherLabel => 'Khác';

  @override
  String competitionNSelected(int n) {
    return 'Đã chọn $n';
  }

  @override
  String get competitionDone => 'Xong';

  @override
  String get competitionSelectHskLessonPart =>
      'Vui lòng chọn ít nhất một phần.';

  @override
  String get competitionFailedLoadLessons => 'Không tải được bài học.';

  @override
  String get competitionNoLessonsFound => 'Không tìm thấy bài học.';

  @override
  String get competitionNoSavedBooks => 'Bạn chưa lưu từ nào trong sách nào.';

  @override
  String get competitionRoomLabel => 'Phòng';

  @override
  String get competitionLeave => 'Rời';

  @override
  String get competitionRoomSetup => 'Cài Đặt Phòng';

  @override
  String competitionLessonsPartsCount(int lessons, int parts) {
    return '$lessons bài · $parts phần';
  }

  @override
  String competitionWordsCount(int count) {
    return '$count từ';
  }

  @override
  String competitionTasksSourceCount(int count) {
    return '$count câu';
  }

  @override
  String get competitionBookPoolNote => 'Bộ từ được chốt khi phiên bắt đầu';

  @override
  String competitionUsersCount(int count, int max) {
    return '$count/$max người học';
  }

  @override
  String competitionTimeLimitValue(int n) {
    return 'Giới hạn: $n phút/phần';
  }

  @override
  String get competitionStartSession => 'Bắt Đầu';

  @override
  String get competitionChat => 'Trò chuyện';

  @override
  String get competitionMessagePlaceholder => 'Nhập tin nhắn…';

  @override
  String get competitionSend => 'Gửi';

  @override
  String get competitionUserFallback => 'Người dùng';

  @override
  String competitionPoints(int n) {
    return '$n điểm';
  }

  @override
  String get competitionScoreboard => 'Bảng Điểm';

  @override
  String get competitionNoTasks => 'Phòng này chưa có câu hỏi.';

  @override
  String get competitionNoWords => 'Phòng này chưa có từ.';

  @override
  String get competitionLoading => 'Đang tải…';

  @override
  String get competitionYouFinished => 'Bạn đã hoàn thành!';

  @override
  String competitionFinishedList(String names) {
    return 'Đã xong: $names';
  }

  @override
  String get competitionWaitingOthers =>
      'Đang chờ những người khác hoàn thành…';

  @override
  String get competitionRanking => 'Bảng Xếp Hạng';

  @override
  String get competitionBackToLobby => 'Về Sảnh';

  @override
  String get competitionServerConnectFailed => 'Không thể kết nối tới máy chủ.';

  @override
  String get competitionErrorFallback => 'Đã có lỗi xảy ra.';

  @override
  String get competitionCouldNotCreateRoom => 'Không thể tạo phòng.';
}
