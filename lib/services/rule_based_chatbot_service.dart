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
      'Hello! I am the Tripwise Assistant. I can help with bookings, prices, itineraries, destination ideas, payments, refunds, and provider questions.';

  static const List<String> quickPrompts = [
    'I want to book a trip',
    'Suggest destinations',
    'Ask about tour prices',
    'Cancellation policy',
    'Payment methods',
    'Check my booking',
  ];

  static const List<ChatbotRule> _rules = [
    ChatbotRule(
      intent: 'greeting',
      keywords: ['hello', 'hi', 'hey'],
      response:
          'Hello! What would you like help with: booking, prices, itinerary, cancellation, refund, or provider support?',
    ),
    ChatbotRule(
      intent: 'ask_price',
      keywords: ['price', 'cost', 'fee', 'how much'],
      response:
          'Which destination or service do you want a price for? You can enter a hotel, tour, city, or route.',
    ),
    ChatbotRule(
      intent: 'ask_itinerary',
      keywords: ['itinerary', 'plan', 'schedule', 'how many days'],
      response:
          'I can suggest a day-by-day itinerary. Tell me your destination and trip length, for example: Da Lat, 3 days 2 nights.',
    ),
    ChatbotRule(
      intent: 'suggest_destination',
      keywords: ['suggest', 'recommend', 'destination', 'where to go'],
      response:
          'For beaches, consider Phu Quoc, Da Nang, or Nha Trang. For cooler weather and scenery, consider Da Lat or Sa Pa.',
    ),
    ChatbotRule(
      intent: 'book_tour',
      keywords: ['book', 'booking', 'reserve', 'hotel', 'tour'],
      response: 'Where would you like to book?',
    ),
    ChatbotRule(
      intent: 'search_service',
      keywords: ['search', 'filter', 'sort', 'find'],
      response:
          'Open Search, enter your destination, then use filters for price, rating, service type, and dates.',
    ),
    ChatbotRule(
      intent: 'booking_status',
      keywords: ['booking status', 'my trips', 'confirmed', 'pending'],
      response:
          'You can check booking status in My Trips. Common statuses are pending, confirmed, completed, cancellation pending, and cancelled.',
    ),
    ChatbotRule(
      intent: 'change_booking',
      keywords: ['change booking', 'change date', 'change room', 'modify'],
      response:
          'Open the booking in My Trips and check whether the provider allows date or room changes. Some changes may require a price adjustment.',
    ),
    ChatbotRule(
      intent: 'cancel_policy',
      keywords: ['cancel', 'cancellation', 'refund', 'change date'],
      response:
          'Cancellation requests are sent to admin for review. If approved, the refund is returned to your Tripwise wallet.',
    ),
    ChatbotRule(
      intent: 'refund_time',
      keywords: ['refund time', 'when refund', 'where refund', 'refund status'],
      response:
          'Refund timing depends on admin approval and payment method. Approved Tripwise wallet refunds appear in your wallet transactions.',
    ),
    ChatbotRule(
      intent: 'payment_method',
      keywords: ['payment', 'wallet', 'card', 'paypal', 'pay'],
      response:
          'Tripwise supports the payment methods shown on checkout. Review the total, dates, guest count, and cancellation terms before confirming.',
    ),
    ChatbotRule(
      intent: 'payment_failed',
      keywords: ['payment failed', 'cannot pay', 'transaction error'],
      response:
          'If payment fails, check your balance, connection, and card details, or try another payment method.',
    ),
    ChatbotRule(
      intent: 'points',
      keywords: ['points', 'earned points', 'redeem points', 'loyalty'],
      response:
          'You earn points equal to 1% of completed bookings. At checkout, you can use points up to 20% of the current booking total.',
    ),
    ChatbotRule(
      intent: 'invoice',
      keywords: ['invoice', 'receipt', 'bill'],
      response:
          'You can check receipts in booking details or wallet transactions. Contact support with your booking code if you need help.',
    ),
    ChatbotRule(
      intent: 'review',
      keywords: ['review', 'rating', 'stars', 'feedback'],
      response:
          'After a completed trip or service, you can leave a review from the booking or service detail page.',
    ),
    ChatbotRule(
      intent: 'notification',
      keywords: ['notification', 'push', 'message'],
      response:
          'Open Notification Inbox to view updates. If push notifications do not arrive, check device notification permissions.',
    ),
    ChatbotRule(
      intent: 'profile_account',
      keywords: ['profile', 'account', 'password', 'login', 'register'],
      response:
          'You can update your account, profile, and security information from Profile.',
    ),
    ChatbotRule(
      intent: 'identity_verification',
      keywords: ['verify', 'verification', 'passport', 'identity'],
      response:
          'Some bookings or provider accounts may require identity verification. Upload a clear, valid document when requested.',
    ),
    ChatbotRule(
      intent: 'travel_document',
      keywords: ['document', 'passport', 'visa', 'id card'],
      response:
          'Bring your ID or passport, booking confirmation, and any destination-specific documents. For international travel, check visa and passport validity.',
    ),
    ChatbotRule(
      intent: 'weather',
      keywords: ['weather', 'rain', 'sunny', 'season'],
      response:
          'Check weather before departure. Beach trips are usually easier in dry season, while mountain trips may need warmer clothes.',
    ),
    ChatbotRule(
      intent: 'transport',
      keywords: ['transport', 'airport', 'transfer', 'taxi'],
      response:
          'Check whether your booking includes pickup. If not, arrange airport transfer, taxi, or local transport before arrival.',
    ),
    ChatbotRule(
      intent: 'provider_listing',
      keywords: ['provider', 'listing', 'create listing', 'manage room'],
      response:
          'Providers can manage listings, prices, inventory, images, and descriptions from Provider Dashboard.',
    ),
    ChatbotRule(
      intent: 'provider_order',
      keywords: ['order manager', 'provider order', 'confirm order'],
      response:
          'Providers can view and process booking orders in Order Manager. Respond early so users receive confirmation quickly.',
    ),
    ChatbotRule(
      intent: 'provider_payout',
      keywords: ['payout', 'provider finance', 'revenue', 'withdraw'],
      response:
          'Provider revenue and payout information are available in the Finance/Payout area.',
    ),
    ChatbotRule(
      intent: 'contact_support',
      keywords: ['support', 'contact', 'help center', 'hotline'],
      response:
          'You can send a message here or open Profile > Help Center to find the right support channel.',
    ),
    ChatbotRule(
      intent: 'thanks',
      keywords: ['thank', 'thanks'],
      response: 'Happy to help. What else would you like to plan?',
    ),
  ];

  String respondTo(String message) {
    final normalized = _normalize(message);

    if (_state == ChatbotState.waitingForDestination) {
      _selectedDestination = message.trim();
      _state = ChatbotState.waitingForDuration;
      return 'How long will you stay in ${message.trim()}? For example: 2 days 1 night or 3 days 2 nights.';
    }

    if (_state == ChatbotState.waitingForDuration) {
      final destination = _selectedDestination ?? 'this destination';
      _selectedDestination = null;
      _state = ChatbotState.idle;
      return 'I will look for options in $destination for ${message.trim()}. Open Explore to choose a suitable service and book it.';
    }

    final matchedRule = _bestRuleFor(normalized);
    if (matchedRule == null) {
      return 'Sorry, I did not understand that yet. You can ask about prices, booking, itinerary, destination ideas, payment, refund, or cancellation.';
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

  String _normalize(String text) => text.toLowerCase().trim();
}
