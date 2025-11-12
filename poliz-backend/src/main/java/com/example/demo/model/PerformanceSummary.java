package com.example.demo.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO for performance summary.
 * v1 focuses on simple counts; response-time and incident fields remain placeholders.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PerformanceSummary {

    private RangeDTO range;          // {"from": "...", "to": "..."}
    private String officer;          // username (or null if team summary)
    private MessagingStats messaging;
    private IncidentStats incidents;

    // ---------- Nested DTOs ----------

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class RangeDTO {
        private String from;
        private String to;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class MessagingStats {
        private int conversations;
        private int messagesSent;
        private int messagesReceived;
        private Percentiles firstResponseTimeMs; // reserved (zeros)
        private Percentiles avgResponseTimeMs;   // reserved (zeros)
        private int activeDays;
        private int unreadClearedCount;          // not tracked yet
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class IncidentStats {
        private int incidentsViewed;
        private int newAlertsCleared;
        private RankDistribution byRankLevel;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class RankDistribution {
        private int CRITICAL;
        private int HIGH;
        private int MEDIUM;
        private int LOW;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Percentiles {
        private long avg;
        private long p50;
        private long p90;
    }
}
