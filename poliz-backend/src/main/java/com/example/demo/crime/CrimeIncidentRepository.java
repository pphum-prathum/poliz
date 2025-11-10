package com.example.demo.crime;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface CrimeIncidentRepository extends JpaRepository<CrimeIncident, Long> {

    // Optional filter by type
    List<CrimeIncident> findByType(String type);
}