package com.example.demo.service;

import com.example.demo.model.Incident;
import com.example.demo.model.Message;
import com.example.demo.model.PerformanceSummary;
import com.example.demo.model.PerformanceSummary.IncidentStats;
import com.example.demo.model.PerformanceSummary.MessagingStats;
import com.example.demo.model.PerformanceSummary.Percentiles;
import com.example.demo.model.PerformanceSummary.RangeDTO;
import com.example.demo.repository.IncidentRepository;
import com.example.demo.repository.MessageRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.*;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.*;
import java.util.stream.Collectors;

/**
 * Performance v1 (simplified for String-based Message.time):
 * - conversations, messagesSent, messagesReceived, activeDays
 * - response-time metrics are ZERO (reserved for future)
 * - incident stats come from Incident.rankLevel counts (CRITICAL/HIGH/MEDIUM/LOW)
 */
@Service
@RequiredArgsConstructor
public class PerformanceService {

    private final MessageRepository messageRepository;
    private final IncidentRepository incidentRepository;

    private static final DateTimeFormatter ISO_INSTANT = DateTimeFormatter.ISO_INSTANT;
    private static final List<DateTimeFormatter> FALLBACKS = List.of(
            DateTimeFormatter.ISO_DATE_TIME,                       // 2025-11-11T01:23:45 or ...Z
            DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"),
            DateTimeFormatter.ofPattern("yyyy/MM/dd HH:mm:ss"),
            DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm"),
            DateTimeFormatter.ofPattern("dd-MM-yyyy HH:mm")
    );

    public PerformanceSummary getSummary(Instant from, Instant to, String officer) {
        // --- Messaging (filter Message.time strings into the [from,to] window) ---
        List<Message> inRange = messageRepository.findAll().stream()
                .filter(m -> parseToInstantUTC(m.getTime()).map(t -> !t.isBefore(from) && !t.isAfter(to)).orElse(false))
                .collect(Collectors.toList());

        List<Message> relevant = (officer == null || officer.isBlank())
                ? inRange
                : inRange.stream()
                .filter(m -> officer.equals(m.getSender()) || officer.equals(m.getReceiver()))
                .collect(Collectors.toList());

        MessagingStats messaging = computeSimpleMessaging(relevant, officer);

        IncidentStats incidents = computeIncidentStatsFromIncidents(from, to);

        return PerformanceSummary.builder()
                .range(new RangeDTO(ISO_INSTANT.format(from), ISO_INSTANT.format(to)))
                .officer(officer)
                .messaging(messaging)
                .incidents(incidents)
                .build();
    }

    /** Counts Incident.rankLevel occurrences (CRITICAL/HIGH/MEDIUM/LOW). */
    private IncidentStats computeIncidentStatsFromIncidents(Instant from, Instant toInclusive) {
        // Convert the incoming UTC instants to LOCAL time,
        // then make the end boundary EXCLUSIVE at local next-day 00:00.
        ZoneId zone = ZoneId.systemDefault();
        LocalDate fromDateLocal = LocalDateTime.ofInstant(from, zone).toLocalDate();
        LocalDate toDateLocal   = LocalDateTime.ofInstant(toInclusive, zone).toLocalDate();

        LocalDateTime startLocal = fromDateLocal.atStartOfDay();
        LocalDateTime endExclusiveLocal = toDateLocal.plusDays(1).atStartOfDay();

        List<Incident> window = incidentRepository
                .findByTimeGreaterThanEqualAndTimeLessThan(startLocal, endExclusiveLocal);

        int critical = 0, high = 0, medium = 0, low = 0;
        for (Incident inc : window) {
            String level = inc.getRankLevel();
            if (level == null) continue;
            switch (level.toUpperCase(java.util.Locale.ROOT)) {
                case "CRITICAL" -> critical++;
                case "HIGH"     -> high++;
                case "MEDIUM"   -> medium++;
                case "LOW"      -> low++;
            }
        }

        return IncidentStats.builder()
                .incidentsViewed(0)
                .newAlertsCleared(0)
                .byRankLevel(PerformanceSummary.RankDistribution.builder()
                        .CRITICAL(critical).HIGH(high).MEDIUM(medium).LOW(low)
                        .build())
                .build();
    }

    private MessagingStats computeSimpleMessaging(List<Message> messages, String officer) {
        if (officer == null || officer.isBlank()) {
            // Conversations = distinct unordered pairs
            Set<String> pairs = new HashSet<>();
            for (Message m : messages) {
                String a = m.getSender(), b = m.getReceiver();
                if (a == null || b == null) continue;
                pairs.add((a.compareTo(b) < 0) ? a + "|" + b : b + "|" + a);
            }

            int activeDays = (int) messages.stream()
                    .map(m -> parseToInstantUTC(m.getTime()))
                    .filter(Optional::isPresent)
                    .map(opt -> opt.get().atZone(ZoneOffset.UTC).toLocalDate())
                    .collect(Collectors.toSet())
                    .size();

            int total = messages.size();
            return MessagingStats.builder()
                    .conversations(pairs.size())
                    .messagesSent(total)
                    .messagesReceived(total)
                    .firstResponseTimeMs(new Percentiles(0, 0, 0))
                    .avgResponseTimeMs(new Percentiles(0, 0, 0))
                    .activeDays(activeDays)
                    .unreadClearedCount(0)
                    .build();
        }

        String me = officer;

        Set<String> peers = messages.stream()
                .flatMap(m -> {
                    if (me.equals(m.getSender())) return Arrays.stream(new String[]{m.getReceiver()});
                    if (me.equals(m.getReceiver())) return Arrays.stream(new String[]{m.getSender()});
                    return Arrays.stream(new String[0]);
                })
                .filter(Objects::nonNull)
                .collect(Collectors.toSet());

        int sent = (int) messages.stream().filter(m -> me.equals(m.getSender())).count();
        int received = (int) messages.stream().filter(m -> me.equals(m.getReceiver())).count();

        int activeDays = (int) messages.stream()
                .filter(m -> me.equals(m.getSender()) || me.equals(m.getReceiver()))
                .map(m -> parseToInstantUTC(m.getTime()))
                .filter(Optional::isPresent)
                .map(opt -> opt.get().atZone(ZoneOffset.UTC).toLocalDate())
                .collect(Collectors.toSet())
                .size();

        return MessagingStats.builder()
                .conversations(peers.size())
                .messagesSent(sent)
                .messagesReceived(received)
                .firstResponseTimeMs(new Percentiles(0, 0, 0))
                .avgResponseTimeMs(new Percentiles(0, 0, 0))
                .activeDays(activeDays)
                .unreadClearedCount(0)
                .build();
    }

    /** Parse Message.time (String) to UTC Instant. */
    private Optional<Instant> parseToInstantUTC(String s) {
        if (s == null || s.isBlank()) return Optional.empty();

        // 1) ISO instant (e.g., "2025-11-11T01:23:45Z")
        try { return Optional.of(Instant.parse(s)); }
        catch (DateTimeParseException ignored) {}

        // 2) ISO date-time and fallbacks (assume UTC if no zone)
        for (DateTimeFormatter f : FALLBACKS) {
            try {
                var acc = f.parse(s);
                if (acc.isSupported(java.time.temporal.ChronoField.OFFSET_SECONDS)) {
                    return Optional.of(OffsetDateTime.from(acc).toInstant());
                } else {
                    return Optional.of(LocalDateTime.from(acc).toInstant(ZoneOffset.UTC));
                }
            } catch (DateTimeParseException ignored) { }
        }

        // 3) Time-only formats -> assume today's local date
        try {
            if (s.matches("^\\d{1,2}:\\d{2}$")) { // "HH:mm"
                var today = LocalDate.now();
                var parts = s.split(":");
                var ldt = LocalDateTime.of(today,
                        LocalTime.of(Integer.parseInt(parts[0]), Integer.parseInt(parts[1])));
                return Optional.of(ldt.toInstant(ZoneOffset.UTC));
            }
            if (s.matches("(?i)^\\d{1,2}:\\d{2}\\s*(AM|PM)$")) { // "h:mm AM/PM"
                var today = LocalDate.now();
                var fmt = DateTimeFormatter.ofPattern("h:mm a");
                var lt = LocalTime.parse(s.toUpperCase(Locale.ROOT), fmt);
                var ldt = LocalDateTime.of(today, lt);
                return Optional.of(ldt.toInstant(ZoneOffset.UTC));
            }
        } catch (Exception ignored) {}

        return Optional.empty();
    }
}