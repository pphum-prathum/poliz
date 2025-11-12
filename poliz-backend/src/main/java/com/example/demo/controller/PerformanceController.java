package com.example.demo.controller;

import com.example.demo.model.PerformanceSummary;
import com.example.demo.service.PerformanceService;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.*;

import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneOffset;

@RestController
@RequestMapping("/api/v1/performance")
@CrossOrigin
@RequiredArgsConstructor
public class PerformanceController {

    private final PerformanceService performanceService;

    // Example:
    // GET /api/v1/performance/summary?from=2025-11-01&to=2025-11-30
    @GetMapping("/summary")
    public PerformanceSummary getSummary(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to,
            @RequestParam(required = false) String officer
    ) {
        Instant fromUtc = from.atStartOfDay().toInstant(ZoneOffset.UTC);
        Instant toUtc   = to.plusDays(1).atStartOfDay().toInstant(ZoneOffset.UTC).minusMillis(1);
        return performanceService.getSummary(fromUtc, toUtc, officer);
    }
}