package com.example.demo.model;

import java.time.format.DateTimeFormatter;

public record CrimeIncidentDto(
        Long id,
        String type,
        String placeName,
        String time,        // HH:mm
        String description,
        String status,      // rankLevel or fallback
        Double latitude,
        Double longitude
) {

    private static final DateTimeFormatter TIME_FMT =
            DateTimeFormatter.ofPattern("HH:mm");

    public static CrimeIncidentDto fromIncident(Incident i) {
        String timeStr = null;
        if (i.getTime() != null) {
            // Use only the time part for dashboard display
            timeStr = i.getTime().toLocalTime().format(TIME_FMT);
        }

        // Use rankLevel as dashboard "status". Fall back if missing.
        String status = i.getRankLevel();
        if (status == null || status.isBlank()) {
            status = i.isNew() ? "NEW" : "NORMAL";
        }

        return new CrimeIncidentDto(
                i.getId(),
                i.getType(),
                i.getPlace(),     // placeName in JSON
                timeStr,
                i.getNotes(),
                status,
                i.getLatitude(),
                i.getLongitude()
        );
    }
}