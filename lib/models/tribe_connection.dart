// Selected model excerpt; service and backend integrations omitted.
class TribeConnection {
  final int connectionId;
  final String otherUid;
  final String otherName;
  final String otherImage;
  final String status; // 'connected' or 'tribe'
  final int healthBar; // 0-100
  final int sharedActivities;
  final DateTime? tribeSince;
  final DateTime lastActivityAt;

  const TribeConnection({
    required this.connectionId,
    required this.otherUid,
    required this.otherName,
    required this.otherImage,
    required this.status,
    required this.healthBar,
    required this.sharedActivities,
    this.tribeSince,
    required this.lastActivityAt,
  });

  bool get isTribe => status == 'tribe';

  /// How many days since last interaction.
  int get daysSinceActivity =>
      DateTime.now().difference(lastActivityAt).inDays;

  /// Label for the health bar.
  String get healthLabel {
    if (healthBar >= 90) return 'On Fire';
    if (healthBar >= 70) return 'Strong';
    if (healthBar >= 50) return 'Good';
    if (healthBar >= 30) return 'Cooling Off';
    if (healthBar >= 10) return 'Fading';
    return 'Almost Gone';
  }

  factory TribeConnection.fromJson(Map<String, dynamic> j) => TribeConnection(
        connectionId: j['connection_id'] as int,
        otherUid: j['other_uid'] as String,
        otherName: j['other_name'] as String? ?? 'Unknown',
        otherImage: j['other_image'] as String? ?? '',
        status: j['status'] as String? ?? 'connected',
        healthBar: j['health_bar'] as int? ?? 0,
        sharedActivities: j['shared_activities'] as int? ?? 0,
        tribeSince: j['tribe_since'] != null
            ? DateTime.tryParse(j['tribe_since'] as String)
            : null,
        lastActivityAt: j['last_activity_at'] != null
            ? DateTime.parse(j['last_activity_at'] as String)
            : DateTime.now(),
      );
}
