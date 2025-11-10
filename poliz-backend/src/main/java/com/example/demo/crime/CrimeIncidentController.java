package com.example.demo.crime;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.net.URI;
import java.util.List;

@RestController
@RequestMapping("/api/v1/crime-incidents")
public class CrimeIncidentController {

    private final CrimeIncidentService service;

    public CrimeIncidentController(CrimeIncidentService service) {
        this.service = service;
    }

    // GET /api/v1/crime-incidents
    // GET /api/v1/crime-incidents?type=Robbery
    @GetMapping
    public List<CrimeIncidentDto> getIncidents(
            @RequestParam(required = false) String type
    ) {
        List<CrimeIncident> list =
                (type == null || type.isBlank())
                        ? service.getAllIncidents()
                        : service.getIncidentsByType(type);

        return list.stream()
                .map(CrimeIncidentDto::fromEntity)
                .toList();
    }

    // POST /api/v1/crime-incidents
    @PostMapping
    public ResponseEntity<CrimeIncidentDto> createIncident(
            @RequestBody CrimeIncidentDto dto
    ) {
        CrimeIncident c = new CrimeIncident();
        c.setType(dto.type());
        c.setPlaceName(dto.placeName());
        c.setTimeLabel(dto.timeLabel());
        c.setDescription(dto.description());
        c.setLatitude(dto.latitude());
        c.setLongitude(dto.longitude());

        CrimeIncident saved = service.save(c);
        CrimeIncidentDto body = CrimeIncidentDto.fromEntity(saved);

        return ResponseEntity
                .created(URI.create("/api/v1/crime-incidents/" + saved.getId()))
                .body(body);
    }
}