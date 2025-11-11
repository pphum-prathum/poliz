class PerformanceSummary {
  final RangeDTO range;
  final String? officer;
  final MessagingStats messaging;
  final IncidentStats incidents;

  PerformanceSummary({
    required this.range,
    required this.officer,
    required this.messaging,
    required this.incidents,
  });

  factory PerformanceSummary.fromJson(Map<String, dynamic> json) {
    return PerformanceSummary(
      range: RangeDTO.fromJson(json['range'] as Map<String, dynamic>),
      officer: json['officer'] as String?,
      messaging: MessagingStats.fromJson(json['messaging'] as Map<String, dynamic>),
      incidents: IncidentStats.fromJson(json['incidents'] as Map<String, dynamic>),
    );
  }
}

class RangeDTO {
  final String from;
  final String to;
  RangeDTO({required this.from, required this.to});
  factory RangeDTO.fromJson(Map<String, dynamic> json) =>
      RangeDTO(from: json['from'] as String, to: json['to'] as String);
}

class MessagingStats {
  final int conversations;
  final int messagesSent;
  final int messagesReceived;
  final Percentiles firstResponseTimeMs; // zeros for now
  final Percentiles avgResponseTimeMs;   // zeros for now
  final int activeDays;
  final int unreadClearedCount;

  MessagingStats({
    required this.conversations,
    required this.messagesSent,
    required this.messagesReceived,
    required this.firstResponseTimeMs,
    required this.avgResponseTimeMs,
    required this.activeDays,
    required this.unreadClearedCount,
  });

  factory MessagingStats.fromJson(Map<String, dynamic> json) {
    return MessagingStats(
      conversations: (json['conversations'] ?? 0) as int,
      messagesSent: (json['messagesSent'] ?? 0) as int,
      messagesReceived: (json['messagesReceived'] ?? 0) as int,
      firstResponseTimeMs: Percentiles.fromJson(json['firstResponseTimeMs'] as Map<String, dynamic>),
      avgResponseTimeMs:  Percentiles.fromJson(json['avgResponseTimeMs']  as Map<String, dynamic>),
      activeDays: (json['activeDays'] ?? 0) as int,
      unreadClearedCount: (json['unreadClearedCount'] ?? 0) as int,
    );
  }
}

class Percentiles {
  final int avg;
  final int p50;
  final int p90;
  Percentiles({required this.avg, required this.p50, required this.p90});
  factory Percentiles.fromJson(Map<String, dynamic> json) => Percentiles(
    avg: (json['avg'] ?? 0) as int,
    p50: (json['p50'] ?? 0) as int,
    p90: (json['p90'] ?? 0) as int,
  );
}

class IncidentStats {
  final int incidentsViewed;
  final int newAlertsCleared;
  final RankDistribution byRankLevel;

  IncidentStats({
    required this.incidentsViewed,
    required this.newAlertsCleared,
    required this.byRankLevel,
  });

  factory IncidentStats.fromJson(Map<String, dynamic> json) {
    return IncidentStats(
      incidentsViewed: (json['incidentsViewed'] ?? 0) as int,
      newAlertsCleared: (json['newAlertsCleared'] ?? 0) as int,
      byRankLevel: RankDistribution.fromJson(json['byRankLevel'] as Map<String, dynamic>),
    );
  }
}

class RankDistribution {
  final int critical;
  final int high;
  final int medium;
  final int low;

  RankDistribution({
    required this.critical,
    required this.high,
    required this.medium,
    required this.low,
  });

  factory RankDistribution.fromJson(Map<String, dynamic> json) {
    int get2(String up, String low) {
      final v = json[up] ?? json[low];
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    return RankDistribution(
      critical: get2('CRITICAL', 'critical'),
      high:     get2('HIGH', 'high'),
      medium:   get2('MEDIUM', 'medium'),
      low:      get2('LOW', 'low'),
    );
  }
}