package com.example.demo.crime;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import java.time.LocalTime;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.*;

/**
 * Unit tests for CrimeIncidentService.getIncidentsByType(String).
 *
 * Test design technique: Logic coverage (predicate / branch coverage).
 *
 * We exercise different truth values of the predicate:
 *   (type == null || type.isBlank() || type.equalsIgnoreCase("All Types"))
 */
class CrimeIncidentServiceTest {

    @Mock
    private CrimeIncidentRepository repo;

    private CrimeIncidentService service;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
        service = new CrimeIncidentService(repo);
    }

    // Technique: Logic coverage (predicate branch TRUE via type == null).
    // This test covers the case where type is null, so the condition
    // (type == null || type.isBlank() || equalsIgnoreCase("All Types")) is TRUE.
    // Expected behavior: the service should return all incidents (repo.findAll()).
    @Test
    @DisplayName("getIncidentsByType returns all when type is null")
    void returnsAll_whenTypeIsNull() {
        when(repo.findAll()).thenReturn(sampleIncidents());

        List<CrimeIncident> result = service.getIncidentsByType(null);

        verify(repo, times(1)).findAll();
        verify(repo, never()).findByType(anyString());
        assertThat(result).hasSize(3);
    }

    // Technique: Logic coverage (clause coverage where type.isBlank() is TRUE).
    // This test covers the case where type is a blank string ("   "),
    // so the predicate is TRUE due to the second clause.
    // Expected behavior: return all incidents (repo.findAll()).
    @Test
    @DisplayName("getIncidentsByType returns all when type is blank")
    void returnsAll_whenTypeIsBlank() {
        when(repo.findAll()).thenReturn(sampleIncidents());

        List<CrimeIncident> result = service.getIncidentsByType("   ");

        verify(repo, times(1)).findAll();
        verify(repo, never()).findByType(anyString());
        assertThat(result).hasSize(3);
    }

    // Technique: Logic coverage (clause coverage where equalsIgnoreCase(\"All Types\") is TRUE).
    // This test covers the case where type is "All Types", so the third clause is TRUE
    // and the method should still behave like "no filter" and return all incidents.
    @Test
    @DisplayName("getIncidentsByType returns all when type is 'All Types'")
    void returnsAll_whenTypeIsAllTypes() {
        when(repo.findAll()).thenReturn(sampleIncidents());

        List<CrimeIncident> result = service.getIncidentsByType("All Types");

        verify(repo, times(1)).findAll();
        verify(repo, never()).findByType(anyString());
        assertThat(result).hasSize(3);
    }

    // Technique: Logic coverage (predicate branch FALSE with matching incidents).
    // This test covers the branch where the predicate is FALSE by passing a concrete type "Robbery".
    // In this path the service should call repo.findByType("Robbery"), so we stub that method.
    @Test
    @DisplayName("getIncidentsByType filters correctly when specific type exists")
    void returnsOnlyMatchingType_whenConcreteTypeProvided() {
        // We only stub findByType here because that is what the service calls for concrete types.
        CrimeIncident robbery = robberyIncident();
        when(repo.findByType("Robbery")).thenReturn(List.of(robbery));

        List<CrimeIncident> result = service.getIncidentsByType("Robbery");

        verify(repo, never()).findAll();
        verify(repo, times(1)).findByType("Robbery");

        assertThat(result).hasSize(1);
        assertThat(result.get(0).getType()).isEqualToIgnoringCase("Robbery");
        assertThat(result.get(0).getPlaceName()).isEqualTo("Central Ladprao");
    }

    // Technique: Logic coverage (predicate branch FALSE with no matches).
    // This test also takes the FALSE branch of the predicate (concrete type "Arson"),
    // but there are no incidents with that type, so repo.findByType("Arson") returns an empty list.
    @Test
    @DisplayName("getIncidentsByType returns empty list when no incidents match type")
    void returnsEmpty_whenNoIncidentOfGivenType() {
        when(repo.findByType("Arson")).thenReturn(List.of()); // no matches

        List<CrimeIncident> result = service.getIncidentsByType("Arson");

        verify(repo, never()).findAll();
        verify(repo, times(1)).findByType("Arson");
        assertThat(result).isEmpty();
    }

    // ---------- helper methods ----------

    /**
     * Helper method to build a small, fixed list of incidents used in tests
     * that exercise the "return all" branch.
     */
    private List<CrimeIncident> sampleIncidents() {
        CrimeIncident robbery = robberyIncident();

        CrimeIncident accident = new CrimeIncident();
        accident.setId(2L);
        accident.setType("Accident");
        accident.setPlaceName("Chulalongkorn Hospital");
        accident.setIncidentTime(LocalTime.of(12, 5));
        accident.setDescription("Traffic accident near hospital main entrance.");
        accident.setLatitude(13.732561);
        accident.setLongitude(100.536426);

        CrimeIncident violence = new CrimeIncident();
        violence.setId(3L);
        violence.setType("Violence");
        violence.setPlaceName("Lumpini Park");
        violence.setIncidentTime(LocalTime.of(9, 38));
        violence.setDescription("Assault reported near the lake jogging path.");
        violence.setLatitude(13.730556);
        violence.setLongitude(100.541664);

        return List.of(robbery, accident, violence);
    }

    private CrimeIncident robberyIncident() {
        CrimeIncident robbery = new CrimeIncident();
        robbery.setId(1L);
        robbery.setType("Robbery");
        robbery.setPlaceName("Central Ladprao");
        robbery.setIncidentTime(LocalTime.of(18, 53));
        robbery.setDescription("Armed robbery reported at mall parking area.");
        robbery.setLatitude(13.817174);
        robbery.setLongitude(100.561963);
        return robbery;
    }
}