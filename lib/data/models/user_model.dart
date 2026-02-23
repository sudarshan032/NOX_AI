class UserModel {
  final String id;
  final String phoneNumber;
  final String? name;
  final String? email;
  final bool agentEnabled;
  final bool memoryOptIn;
  final bool whatsappOptIn;
  final bool dailyBriefEnabled;
  final bool googleConnected;
  final bool calendarConnected;
  final bool gmailConnected;

  UserModel({
    required this.id,
    required this.phoneNumber,
    this.name,
    this.email,
    this.agentEnabled = true,
    this.memoryOptIn = true,
    this.whatsappOptIn = false,
    this.dailyBriefEnabled = true,
    this.googleConnected = false,
    this.calendarConnected = false,
    this.gmailConnected = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        phoneNumber: json['phone_number'] as String,
        name: json['name'] as String?,
        email: json['email'] as String?,
        agentEnabled: json['agent_enabled'] as bool? ?? true,
        memoryOptIn: json['memory_opt_in'] as bool? ?? true,
        whatsappOptIn: json['whatsapp_opt_in'] as bool? ?? false,
        dailyBriefEnabled: json['daily_brief_enabled'] as bool? ?? true,
        googleConnected: json['google_connected'] as bool? ?? false,
        calendarConnected: json['calendar_connected'] as bool? ?? false,
        gmailConnected: json['gmail_connected'] as bool? ?? false,
      );

  UserModel copyWith({
    String? name,
    String? email,
    bool? agentEnabled,
    bool? memoryOptIn,
    bool? dailyBriefEnabled,
  }) =>
      UserModel(
        id: id,
        phoneNumber: phoneNumber,
        name: name ?? this.name,
        email: email ?? this.email,
        agentEnabled: agentEnabled ?? this.agentEnabled,
        memoryOptIn: memoryOptIn ?? this.memoryOptIn,
        whatsappOptIn: whatsappOptIn,
        dailyBriefEnabled: dailyBriefEnabled ?? this.dailyBriefEnabled,
        googleConnected: googleConnected,
        calendarConnected: calendarConnected,
        gmailConnected: gmailConnected,
      );
}
