package com.example.demo.controller;

import com.example.demo.model.CrimeIncidentDto;
import com.example.demo.model.Incident;
import com.example.demo.service.IncidentService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/crime-incidents")
@CrossOrigin
public class CrimeIncidentController {

    private final IncidentService incidentService;

    public CrimeIncidentController(IncidentService incidentService) {
        this.incidentService = incidentService;
    }

    /**
     * GET /api/v1/crime-incidents
     * Optional: ?type=Traffic%20Accident
     * This now returns incidents from the Incident table,
     * formatted as CrimeIncidentDto for the dashboard.
     */
    @GetMapping
    public ResponseEntity<List<CrimeIncidentDto>> getCrimeIncidents(
            @RequestParam(required = false) String type
    ) {
        List<Incident> incidents = incidentService.getAllIncidents();

        // Optional in-memory filter by type
        if (type != null && !type.isBlank()
                && !"All Types".equalsIgnoreCase(type)) {

            String normalizedType = type.trim().toLowerCase();
            incidents = incidents.stream()
                    .filter(i -> i.getType() != null
                            && i.getType().trim().toLowerCase().equals(normalizedType))
                    .toList();
        }

        List<CrimeIncidentDto> body = incidents.stream()
                .map(CrimeIncidentDto::fromIncident)
                .toList();

        return ResponseEntity.ok(body);
    }
}