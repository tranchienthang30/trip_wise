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
      intent: 'cancel_policy',
      keywords: ['huy', 'hoan tien', 'doi lich', 'cancel', 'refund'],
      response:
          'Thông thường bạn có thể hủy hoặc đổi lịch theo điều kiện của từng booking. Hãy kiểm tra mục My Trips để xem hạn hủy và phí phạt nếu có.',
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
