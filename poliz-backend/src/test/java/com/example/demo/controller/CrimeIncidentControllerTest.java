package com.example.demo.controller;

import com.example.demo.model.CrimeIncidentDto;
import com.example.demo.model.Incident;
import com.example.demo.service.IncidentService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.ResponseEntity;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.*;

/**
 * Unit tests for CrimeIncidentController type filtering.
 * We use IncidentService as a mocked dependency and focus on:
 *  - Logic coverage over the predicate:
 *        (type == null || type.isBlank() || equalsIgnoreCase("All Types"))
 *  - Correct filtering by concrete type (e.g., "Traffic Accident")
 *  - Behavior when no incident matches the requested type.
 */
@ExtendWith(MockitoExtension.class)
class CrimeIncidentControllerTest {

    @Mock
    private IncidentService incidentService;

    private CrimeIncidentController controller;

    @BeforeEach
    void setUp() {
        controller = new CrimeIncidentController(incidentService);
    }

    // -------------------------------------------------------------------------
    // Test 1: type == null  → should behave like "no filter"
    // Technique: Logic coverage (predicate TRUE via type == null).
    // -------------------------------------------------------------------------

    /**
     * When type is null, the controller should treat it as "All Types"
     * and return all incidents from IncidentService without filtering.
     */
    @Test
    @DisplayName("getCrimeIncidents returns all when type is null")
    void returnsAll_whenTypeIsNull() {
        when(incidentService.getAllIncidents()).thenReturn(sampleIncidents());

        ResponseEntity<List<CrimeIncidentDto>> response =
                controller.getCrimeIncidents(null);

        verify(incidentService, times(1)).getAllIncidents();
        List<CrimeIncidentDto> body = response.getBody();
        assertThat(body).isNotNull();
        assertThat(body).hasSize(3);

        // LOG for Maven output (similar style to IncidentServiceTest)
        String types = body.stream()
                .map(CrimeIncidentDto::type)
                .collect(Collectors.joining(", "));
        System.out.println("LOG: [CrimeIncidentController] type=null -> "
                + body.size() + " incident(s): [" + types + "]");
    }

    // -------------------------------------------------------------------------
    // Test 2: type == "All Types" → should also behave like "no filter"
    // Technique: Logic coverage (clause equalsIgnoreCase("All Types") TRUE).
    // -------------------------------------------------------------------------

    /**
     * When type is "All Types", the third clause of the predicate is TRUE.
     * The controller should still return all incidents with no filtering.
     */
    @Test
    @DisplayName("getCrimeIncidents returns all when type is 'All Types'")
    void returnsAll_whenTypeIsAllTypes() {
        when(incidentService.getAllIncidents()).thenReturn(sampleIncidents());

        ResponseEntity<List<CrimeIncidentDto>> response =
                controller.getCrimeIncidents("All Types");

        verify(incidentService, times(1)).getAllIncidents();
        List<CrimeIncidentDto> body = response.getBody();
        assertThat(body).isNotNull();
        assertThat(body).hasSize(3);

        String types = body.stream()
                .map(CrimeIncidentDto::type)
                .collect(Collectors.joining(", "));
        System.out.println("LOG: [CrimeIncidentController] type='All Types' -> "
                + body.size() + " incident(s): [" + types + "]");
    }

    // -------------------------------------------------------------------------
    // Test 3: concrete matching type  → should filter correctly
    // Technique: Logic coverage (predicate FALSE path).
    // -------------------------------------------------------------------------

    /**
     * When a concrete type "Traffic Accident" is provided,
     * the predicate is FALSE and the controller should filter the list
     * and only return CrimeIncidentDto with type = "Traffic Accident".
     */
    @Test
    @DisplayName("getCrimeIncidents filters correctly for 'Traffic Accident'")
    void returnsOnlyMatchingType_whenTrafficAccidentProvided() {
        when(incidentService.getAllIncidents()).thenReturn(sampleIncidents());

        ResponseEntity<List<CrimeIncidentDto>> response =
                controller.getCrimeIncidents("Traffic Accident");

        verify(incidentService, times(1)).getAllIncidents();

        List<CrimeIncidentDto> body = response.getBody();
        assertThat(body).isNotNull();
        assertThat(body).hasSize(1);
        assertThat(body.get(0).type()).isEqualTo("Traffic Accident");

        String types = body.stream()
                .map(CrimeIncidentDto::type)
                .collect(Collectors.joining(", "));
        System.out.println("LOG: [CrimeIncidentController] type='Traffic Accident' -> "
                + body.size() + " incident(s): [" + types + "]");
    }

    // -------------------------------------------------------------------------
    // Test 4: concrete type with no matching incidents → empty list
    // Technique: Logic coverage (predicate FALSE with empty result).
    // -------------------------------------------------------------------------

    /**
     * When a type that has no matches is provided (e.g., "Disturbance"),
     * the controller should return an empty list after filtering.
     */
    @Test
    @DisplayName("getCrimeIncidents returns empty list when no incident matches type")
    void returnsEmpty_whenNoIncidentMatchesType() {
        when(incidentService.getAllIncidents()).thenReturn(sampleIncidents());

        ResponseEntity<List<CrimeIncidentDto>> response =
                controller.getCrimeIncidents("Disturbance");

        verify(incidentService, times(1)).getAllIncidents();

        List<CrimeIncidentDto> body = response.getBody();
        assertThat(body).isNotNull();
        assertThat(body).isEmpty();

        System.out.println("LOG: [CrimeIncidentController] type='Disturbance' -> "
                + body.size() + " incident(s): [] (no matches)");
    }

    // -------------------------------------------------------------------------
    // Test 5: type is blank (e.g., "   " or "")
    // Technique: Logic coverage (clause type.isBlank() TRUE).
    // -------------------------------------------------------------------------

    /**
     * When type is blank (e.g., only whitespace),
     * the second clause of the predicate (type.isBlank()) is TRUE.
     * According to the controller logic, this should be treated the same as
     * "All Types" and return all incidents without filtering.
     */
    @Test
    @DisplayName("getCrimeIncidents returns all when type is blank")
    void returnsAll_whenTypeIsBlank() {
        when(incidentService.getAllIncidents()).thenReturn(sampleIncidents());

        ResponseEntity<List<CrimeIncidentDto>> response =
                controller.getCrimeIncidents("   ");

        verify(incidentService, times(1)).getAllIncidents();
        List<CrimeIncidentDto> body = response.getBody();
        assertThat(body).isNotNull();
        assertThat(body).hasSize(3);

        String types = body.stream()
                .map(CrimeIncidentDto::type)
                .collect(Collectors.joining(", "));
        System.out.println("LOG: [CrimeIncidentController] type='(blank)' -> "
                + body.size() + " incident(s): [" + types + "]");
    }

    /**
     * List of sample incidents used in tests
     * that exercise both "return all" and filtered branches.
     * Types match your Incident types:
     *  - Traffic Accident
     *  - Medical Emergency
     *  - Fire
     */
    private List<Incident> sampleIncidents() {
        Incident trafficAccident = new Incident();
        trafficAccident.setId(1L);
        trafficAccident.setType("Traffic Accident");
        trafficAccident.setPlace("Main Road Intersection");
        trafficAccident.setTime(LocalDateTime.of(2025, 1, 1, 8, 30));
        trafficAccident.setNotes("Two-car collision, no serious injuries.");

        Incident medicalEmergency = new Incident();
        medicalEmergency.setId(2L);
        medicalEmergency.setType("Medical Emergency");
        medicalEmergency.setPlace("Dormitory Building");
        medicalEmergency.setTime(LocalDateTime.of(2025, 1, 1, 10, 15));
        medicalEmergency.setNotes("Student fainted in hallway.");

        Incident fire = new Incident();
        fire.setId(3L);
        fire.setType("Fire");
        fire.setPlace("Cafeteria Kitchen");
        fire.setTime(LocalDateTime.of(2025, 1, 1, 12, 0));
        fire.setNotes("Small kitchen fire, quickly contained.");

        return List.of(trafficAccident, medicalEmergency, fire);
    }
}