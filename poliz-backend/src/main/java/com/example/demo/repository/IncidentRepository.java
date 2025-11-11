package com.example.demo.repository;

import com.example.demo.model.Incident;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.time.LocalDateTime;
import java.util.List;

public interface IncidentRepository extends JpaRepository<Incident, Long> {

    List<Incident> findByIsNewTrue();
    List<Incident> findByTimeGreaterThanEqualAndTimeLessThan(LocalDateTime from, LocalDateTime toExclusive);
}