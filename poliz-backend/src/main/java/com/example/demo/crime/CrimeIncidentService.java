package com.example.demo.crime;

import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class CrimeIncidentService {

    private final CrimeIncidentRepository repo;

    public CrimeIncidentService(CrimeIncidentRepository repo) {
        this.repo = repo;
    }

    public List<CrimeIncident> getAllIncidents() {
        return repo.findAll();
    }

    public List<CrimeIncident> getIncidentsByType(String type) {
        if (type == null || type.isBlank() || type.equalsIgnoreCase("All Types")) {
            return repo.findAll();
        }
        // Make sure type in DB matches exactly: "Robbery", "Accident", etc.
        return repo.findByType(type);
    }

    public CrimeIncident save(CrimeIncident incident) {
        return repo.save(incident);
    }
}