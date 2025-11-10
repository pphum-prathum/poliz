package com.example.demo.crime;

public record CrimeIncidentDto(
        Long id,
        String type,
        String placeName,
        String timeLabel,
        String description,
        Double latitude,
        Double longitude
) {
    public static CrimeIncidentDto fromEntity(CrimeIncident c) {
        return new CrimeIncidentDto(
                c.getId(),
                c.getType(),
                c.getPlaceName(),
                c.getTimeLabel(),
                c.getDescription(),
                c.getLatitude(),
                c.getLongitude()
        );
    }
}