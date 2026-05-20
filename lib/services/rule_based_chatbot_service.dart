enum ChatbotState { idle, waitingForDestination, waitingForDuration }

class ChatbotRule {
  const ChatbotRule({
    required this.intent,
    required this.keywords,
    required this.response,
  });

  final String intent;
  final List<String> keywords;
  final String response;
}

class RuleBasedChatbotService {
  ChatbotState _state = ChatbotState.idle;
  String? _selectedDestination;

  static const String greeting =
      'Xin chào! Mình là TripWise Assistant. Mình có thể hỗ trợ đặt tour, hỏi giá, lịch trình, gợi ý địa điểm và chính sách hủy tour.';

  static const List<String> quickPrompts = [
    'Tôi muốn đặt tour',
    'Gợi ý địa điểm du lịch',
    'Hỏi giá tour Đà Lạt',
    'Chính sách hủy tour',
    'Cách thanh toán',
    'Kiểm tra booking',
  ];

  static const List<ChatbotRule> _rules = [
    ChatbotRule(
      intent: 'greeting',
      keywords: ['xin chao', 'chao', 'hello', 'hi'],
      response:
          'Xin chào! Bạn cần mình hỗ trợ tìm tour, xem giá, lịch trình hay chính sách đặt/hủy tour?',
    ),
    ChatbotRule(
      intent: 'ask_price',
      keywords: ['gia', 'bao nhieu', 'chi phi', 've', 'price', 'cost'],
      response:
          'Bạn muốn hỏi giá tour nào? Hãy nhập điểm đến như Đà Lạt, Đà Nẵng, Phú Quốc hoặc Nha Trang.',
    ),
    ChatbotRule(
      intent: 'ask_itinerary',
      keywords: ['lich trinh', 'itinerary', 'ke hoach', 'di may ngay'],
      response:
          'Mình có thể gợi ý lịch trình theo ngày. Bạn hãy cho mình biết điểm đến và thời lượng, ví dụ: Đà Lạt 3 ngày 2 đêm.',
    ),
    ChatbotRule(
      intent: 'suggest_destination',
      keywords: [
        'goi y',
        'dia diem',
        'nen di dau',
        'du lich o dau',
        'recommend',
      ],
      response:
          'Nếu bạn thích biển, hãy xem Phú Quốc, Đà Nẵng hoặc Nha Trang. Nếu thích khí hậu mát và cảnh đẹp, Đà Lạt và Sa Pa là lựa chọn tốt.',
    ),
    ChatbotRule(
      intent: 'beach_destination',
      keywords: ['bien', 'beach', 'hai san', 'lan bien', 'nghi duong bien'],
      response:
          'Nếu bạn muốn đi biển, Phú Quốc hợp nghỉ dưỡng, Đà Nẵng hợp lịch trình cân bằng, Nha Trang hợp hoạt động biển và hải sản.',
    ),
    ChatbotRule(
      intent: 'mountain_destination',
      keywords: ['nui', 'mat me', 'sapa', 'da lat', 'san may', 'trekking'],
      response:
          'Nếu bạn thích núi và thời tiết mát, Đà Lạt phù hợp nghỉ dưỡng nhẹ nhàng, còn Sa Pa hợp săn mây, trekking và trải nghiệm văn hóa địa phương.',
    ),
    ChatbotRule(
      intent: 'family_trip',
      keywords: ['gia dinh', 'tre em', 'em be', 'family', 'kid'],
      response:
          'Với chuyến đi gia đình, bạn nên chọn lịch trình nhẹ, khách sạn gần trung tâm, ít di chuyển xa và ưu tiên điểm đến như Đà Nẵng, Đà Lạt hoặc Phú Quốc.',
    ),
    ChatbotRule(
      intent: 'couple_trip',
      keywords: ['cap doi', 'honeymoon', 'trang mat', 'lang man', 'couple'],
      response:
          'Cho chuyến đi cặp đôi, Đà Lạt, Hội An, Phú Quốc và Sa Pa là các lựa chọn dễ tạo lịch trình lãng mạn, nhiều điểm chụp ảnh và nghỉ dưỡng.',
    ),
    ChatbotRule(
      intent: 'budget_trip',
      keywords: ['tiet kiem', 're', 'budget', 'kinh phi', 'it tien'],
      response:
          'Nếu muốn tiết kiệm, bạn nên đặt sớm, đi ngày thường, chọn phòng tiêu chuẩn và ưu tiên combo có sẵn khách sạn hoặc hoạt động trong lịch trình.',
    ),
    ChatbotRule(
      intent: 'book_tour',
      keywords: [
        'dat tour',
        'booking',
        'dang ky tour',
        'mua tour',
        'dat phong',
      ],
      response: 'Bạn muốn đặt tour ở đâu?',
    ),
    ChatbotRule(
      intent: 'search_service',
      keywords: ['tim kiem', 'search', 'loc', 'filter', 'sap xep', 'tim tour'],
      response:
          'Bạn có thể vào Explore hoặc Search, nhập điểm đến, sau đó dùng bộ lọc giá, đánh giá, loại dịch vụ và thời gian để tìm lựa chọn phù hợp.',
    ),
    ChatbotRule(
      intent: 'hotel_booking',
      keywords: ['khach san', 'hotel', 'phong', 'check in', 'check out'],
      response:
          'Để đặt khách sạn, hãy mở trang chi tiết nơi lưu trú, chọn ngày nhận/trả phòng, số khách, loại phòng rồi tiếp tục đến thanh toán.',
    ),
    ChatbotRule(
      intent: 'activity_booking',
      keywords: ['hoat dong', 'activity', 've tham quan', 'tour trong ngay'],
      response:
          'Bạn có thể đặt hoạt động hoặc tour trong ngày từ trang chi tiết dịch vụ. Hãy kiểm tra thời gian diễn ra, điểm gặp và điều kiện hủy trước khi thanh toán.',
    ),
    ChatbotRule(
      intent: 'booking_status',
      keywords: [
        'trang thai booking',
        'kiem tra booking',
        'don cua toi',
        'my trips',
        'xac nhan dat cho',
      ],
      response:
          'Bạn có thể kiểm tra trạng thái booking trong mục My Trips. Các trạng thái thường gặp gồm chờ xác nhận, đã xác nhận, đã hoàn tất hoặc đã hủy.',
    ),
    ChatbotRule(
      intent: 'change_booking',
      keywords: [
        'doi ngay',
        'doi lich',
        'doi phong',
        'doi tour',
        'thay doi booking',
      ],
      response:
          'Nếu muốn đổi ngày, đổi phòng hoặc đổi tour, hãy mở booking trong My Trips và kiểm tra điều kiện thay đổi. Một số dịch vụ có thể phát sinh chênh lệch giá.',
    ),
    ChatbotRule(
      intent: 'cancel_policy',
      keywords: ['huy', 'hoan tien', 'doi lich', 'cancel', 'refund'],
      response:
          'Thông thường bạn có thể hủy hoặc đổi lịch theo điều kiện của từng booking. Hãy kiểm tra mục My Trips để xem hạn hủy và phí phạt nếu có.',
    ),
    ChatbotRule(
      intent: 'refund_time',
      keywords: [
        'bao lau hoan tien',
        'khi nao hoan tien',
        'refund time',
        'tien ve dau',
      ],
      response:
          'Thời gian hoàn tiền phụ thuộc phương thức thanh toán và chính sách của nhà cung cấp. Bạn nên kiểm tra chi tiết booking hoặc liên hệ hỗ trợ nếu quá thời gian dự kiến.',
    ),
    ChatbotRule(
      intent: 'payment_method',
      keywords: [
        'thanh toan',
        'payment',
        'the ngan hang',
        'vi',
        'momo',
        'zalopay',
        'credit card',
      ],
      response:
          'TripWise hỗ trợ thanh toán qua các phương thức được hiển thị ở màn hình checkout. Hãy kiểm tra tổng tiền, ngày đi và chính sách hủy trước khi xác nhận.',
    ),
    ChatbotRule(
      intent: 'payment_failed',
      keywords: [
        'thanh toan loi',
        'payment failed',
        'khong thanh toan duoc',
        'loi giao dich',
      ],
      response:
          'Nếu thanh toán thất bại, hãy kiểm tra số dư, kết nối mạng, thông tin thẻ hoặc thử lại bằng phương thức khác. Nếu vẫn lỗi, bạn nên liên hệ hỗ trợ.',
    ),
    ChatbotRule(
      intent: 'voucher',
      keywords: ['ma giam gia', 'voucher', 'coupon', 'khuyen mai', 'promo'],
      response:
          'Bạn có thể nhập mã giảm giá ở màn hình checkout nếu dịch vụ hỗ trợ. Một số voucher có điều kiện về ngày đi, giá trị đơn hoặc loại dịch vụ.',
    ),
    ChatbotRule(
      intent: 'wallet',
      keywords: [
        'wallet',
        'vi tripwise',
        'so du',
        'diem thuong',
        'loyalty',
        'coin',
      ],
      response:
          'Bạn có thể xem số dư, điểm thưởng và lịch sử giao dịch trong mục Wallet. Điểm thưởng hoặc ưu đãi sẽ phụ thuộc hạng thành viên và chương trình hiện có.',
    ),
    ChatbotRule(
      intent: 'invoice',
      keywords: ['hoa don', 'invoice', 'bien lai', 'receipt', 'xuat hoa don'],
      response:
          'Bạn có thể kiểm tra biên lai trong chi tiết booking hoặc lịch sử giao dịch. Nếu cần hóa đơn riêng, hãy liên hệ hỗ trợ kèm mã booking.',
    ),
    ChatbotRule(
      intent: 'review',
      keywords: ['danh gia', 'review', 'rating', 'nhan xet', 'sao'],
      response:
          'Sau khi hoàn tất chuyến đi hoặc dịch vụ, bạn có thể để lại đánh giá trong trang chi tiết booking hoặc trang dịch vụ để giúp người khác tham khảo.',
    ),
    ChatbotRule(
      intent: 'notification',
      keywords: [
        'thong bao',
        'notification',
        'push',
        'nhac lich',
        'tin nhan moi',
      ],
      response:
          'Bạn có thể xem thông báo trong Notification Inbox. Nếu không nhận được thông báo, hãy kiểm tra quyền thông báo của ứng dụng trên thiết bị.',
    ),
    ChatbotRule(
      intent: 'profile_account',
      keywords: [
        'tai khoan',
        'profile',
        'ho so',
        'dang nhap',
        'dang ky',
        'mat khau',
      ],
      response:
          'Bạn có thể cập nhật hồ sơ, thông tin tài khoản và bảo mật trong Profile. Nếu quên mật khẩu, hãy dùng luồng khôi phục tài khoản ở màn đăng nhập.',
    ),
    ChatbotRule(
      intent: 'identity_verification',
      keywords: ['xac minh', 'cccd', 'cmnd', 'passport', 'ho chieu', 'verify'],
      response:
          'Một số booking hoặc tài khoản provider có thể yêu cầu xác minh danh tính. Hãy chuẩn bị giấy tờ hợp lệ và đảm bảo ảnh rõ, không bị che thông tin quan trọng.',
    ),
    ChatbotRule(
      intent: 'travel_document',
      keywords: ['giay to', 'can mang gi', 'passport', 'visa', 'cmnd', 'cccd'],
      response:
          'Bạn nên mang CCCD/hộ chiếu, xác nhận booking, giấy tờ trẻ em nếu có và giấy tờ đặc thù theo điểm đến. Với chuyến quốc tế, hãy kiểm tra visa và hạn hộ chiếu.',
    ),
    ChatbotRule(
      intent: 'weather',
      keywords: ['thoi tiet', 'mua', 'nang', 'bao', 'weather', 'mua nao dep'],
      response:
          'Bạn nên kiểm tra thời tiết trước ngày đi. Với biển, mùa khô thường thuận lợi hơn; với Đà Lạt hoặc Sa Pa, hãy chuẩn bị áo ấm và áo mưa nhẹ.',
    ),
    ChatbotRule(
      intent: 'transport',
      keywords: [
        'di chuyen',
        'dua don',
        'san bay',
        'xe dua don',
        'taxi',
        'transport',
      ],
      response:
          'Bạn nên kiểm tra dịch vụ có bao gồm đưa đón hay không. Nếu không, hãy đặt xe sân bay, taxi hoặc phương tiện địa phương trước để tránh bị động.',
    ),
    ChatbotRule(
      intent: 'meal',
      keywords: ['an sang', 'bua an', 'an uong', 'meal', 'breakfast', 'buffet'],
      response:
          'Thông tin bữa ăn thường nằm trong chi tiết dịch vụ hoặc khách sạn. Hãy kiểm tra gói đã bao gồm ăn sáng, buffet hoặc phụ thu trẻ em chưa.',
    ),
    ChatbotRule(
      intent: 'pet_policy',
      keywords: [
        'thu cung',
        'pet',
        'cho meo',
        'mang theo cho',
        'mang theo meo',
      ],
      response:
          'Chính sách thú cưng tùy từng nơi lưu trú hoặc tour. Bạn nên kiểm tra chi tiết dịch vụ và liên hệ trước để tránh phát sinh phụ phí.',
    ),
    ChatbotRule(
      intent: 'accessibility',
      keywords: [
        'xe lan',
        'nguoi gia',
        'khuyet tat',
        'accessibility',
        'di lai kho',
      ],
      response:
          'Nếu đi cùng người lớn tuổi hoặc cần hỗ trợ di chuyển, bạn nên chọn khách sạn có thang máy, lịch trình ít leo dốc và liên hệ nhà cung cấp trước.',
    ),
    ChatbotRule(
      intent: 'insurance',
      keywords: ['bao hiem', 'insurance', 'tai nan', 'y te', 'suc khoe'],
      response:
          'Bạn nên kiểm tra tour có bao gồm bảo hiểm du lịch hay không. Với chuyến dài hoặc quốc tế, bảo hiểm y tế và hành lý là lựa chọn nên cân nhắc.',
    ),
    ChatbotRule(
      intent: 'safety',
      keywords: ['an toan', 'lua dao', 'emergency', 'cap cuu', 'khẩn cấp'],
      response:
          'Để an toàn, hãy lưu số liên hệ khẩn cấp, giữ giấy tờ quan trọng, kiểm tra đánh giá dịch vụ và tránh chuyển tiền ngoài nền tảng khi chưa xác minh.',
    ),
    ChatbotRule(
      intent: 'provider_listing',
      keywords: [
        'dang dich vu',
        'tao listing',
        'provider',
        'nha cung cap',
        'quan ly phong',
      ],
      response:
          'Nhà cung cấp có thể quản lý dịch vụ trong Provider Dashboard, thêm listing, cập nhật giá, tồn kho, hình ảnh và mô tả để khách dễ đặt hơn.',
    ),
    ChatbotRule(
      intent: 'provider_order',
      keywords: [
        'quan ly don',
        'order manager',
        'xac nhan don',
        'don dat phong',
      ],
      response:
          'Nhà cung cấp có thể xem và xử lý đơn trong Order Manager. Hãy phản hồi sớm để khách nhận được xác nhận booking kịp thời.',
    ),
    ChatbotRule(
      intent: 'provider_payout',
      keywords: [
        'rut tien',
        'payout',
        'doanh thu',
        'tai chinh',
        'thanh toan cho provider',
      ],
      response:
          'Thông tin doanh thu và rút tiền của nhà cung cấp nằm trong khu vực Finance/Payout. Hãy kiểm tra trạng thái thanh toán và thông tin tài khoản nhận tiền.',
    ),
    ChatbotRule(
      intent: 'contact_support',
      keywords: ['lien he', 'ho tro', 'support', 'tu van vien', 'hotline'],
      response:
          'Bạn có thể gửi tin nhắn tại màn hình này hoặc vào Profile > Help Center để xem kênh hỗ trợ phù hợp.',
    ),
    ChatbotRule(
      intent: 'thanks',
      keywords: ['cam on', 'thank', 'thanks'],
      response:
          'Rất vui được hỗ trợ bạn. Bạn cần mình giúp thêm về chuyến đi nào không?',
    ),
  ];

  String respondTo(String message) {
    final normalized = _normalize(message);

    if (_state == ChatbotState.waitingForDestination) {
      _selectedDestination = message.trim();
      _state = ChatbotState.waitingForDuration;
      return 'Bạn muốn đi ${message.trim()} trong bao lâu? Ví dụ: 2 ngày 1 đêm hoặc 3 ngày 2 đêm.';
    }

    if (_state == ChatbotState.waitingForDuration) {
      final destination = _selectedDestination ?? 'điểm đến này';
      _selectedDestination = null;
      _state = ChatbotState.idle;
      return 'Mình sẽ tìm tour $destination với thời lượng ${message.trim()}. Bạn có thể vào Explore để chọn tour phù hợp và bấm đặt tour.';
    }

    final matchedRule = _bestRuleFor(normalized);
    if (matchedRule == null) {
      return 'Xin lỗi, mình chưa hiểu câu hỏi. Bạn có thể hỏi về giá tour, đặt tour, lịch trình, gợi ý địa điểm hoặc chính sách hủy tour.';
    }

    if (matchedRule.intent == 'book_tour') {
      _state = ChatbotState.waitingForDestination;
    }

    return matchedRule.response;
  }

  ChatbotRule? _bestRuleFor(String normalizedMessage) {
    ChatbotRule? bestRule;
    var bestScore = 0;

    for (final rule in _rules) {
      var score = 0;
      for (final keyword in rule.keywords) {
        if (normalizedMessage.contains(_normalize(keyword))) {
          score++;
        }
      }

      if (score > bestScore) {
        bestScore = score;
        bestRule = rule;
      }
    }

    return bestRule;
  }

  String _normalize(String text) {
    var value = text.toLowerCase().trim();
    const replacements = {
      '\u00e0': 'a',
      '\u00e1': 'a',
      '\u1ea1': 'a',
      '\u1ea3': 'a',
      '\u00e3': 'a',
      '\u00e2': 'a',
      '\u1ea7': 'a',
      '\u1ea5': 'a',
      '\u1ead': 'a',
      '\u1ea9': 'a',
      '\u1eab': 'a',
      '\u0103': 'a',
      '\u1eb1': 'a',
      '\u1eaf': 'a',
      '\u1eb7': 'a',
      '\u1eb3': 'a',
      '\u1eb5': 'a',
      '\u00e8': 'e',
      '\u00e9': 'e',
      '\u1eb9': 'e',
      '\u1ebb': 'e',
      '\u1ebd': 'e',
      '\u00ea': 'e',
      '\u1ec1': 'e',
      '\u1ebf': 'e',
      '\u1ec7': 'e',
      '\u1ec3': 'e',
      '\u1ec5': 'e',
      '\u00ec': 'i',
      '\u00ed': 'i',
      '\u1ecb': 'i',
      '\u1ec9': 'i',
      '\u0129': 'i',
      '\u00f2': 'o',
      '\u00f3': 'o',
      '\u1ecd': 'o',
      '\u1ecf': 'o',
      '\u00f5': 'o',
      '\u00f4': 'o',
      '\u1ed3': 'o',
      '\u1ed1': 'o',
      '\u1ed9': 'o',
      '\u1ed5': 'o',
      '\u1ed7': 'o',
      '\u01a1': 'o',
      '\u1edd': 'o',
      '\u1edb': 'o',
      '\u1ee3': 'o',
      '\u1edf': 'o',
      '\u1ee1': 'o',
      '\u00f9': 'u',
      '\u00fa': 'u',
      '\u1ee5': 'u',
      '\u1ee7': 'u',
      '\u0169': 'u',
      '\u01b0': 'u',
      '\u1eeb': 'u',
      '\u1ee9': 'u',
      '\u1ef1': 'u',
      '\u1eed': 'u',
      '\u1eef': 'u',
      '\u1ef3': 'y',
      '\u00fd': 'y',
      '\u1ef5': 'y',
      '\u1ef7': 'y',
      '\u1ef9': 'y',
      '\u0111': 'd',
    };

    for (final entry in replacements.entries) {
      value = value.replaceAll(entry.key, entry.value);
    }
    return value;
  }
}
