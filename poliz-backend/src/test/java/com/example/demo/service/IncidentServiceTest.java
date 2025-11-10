package com.example.demo.service;

import com.example.demo.model.Incident;
import com.example.demo.repository.IncidentRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDateTime;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

/**
 * Unit tests for IncidentService.addNewIncident(Incident).
 *
 * Test design technique: Input Space Partitioning (ISP) using Base-Choice coverage.
 *
 * We define four characteristics and their partitions:
 *
 *   1) Type
 *      { Other (base), Armed Robbery, Fire, Violent Crime,
 *        Medical Emergency, Traffic Accident, Disturbance }
 *
 *   2) Time
 *      { Day (base), Night }
 *
 *   3) Place
 *      { Normal (base), Vulnerable (e.g., park, school, hospital) }
 *
 *   4) Notes Severity
 *      { None (base, 0),
 *        Minor (+10),
 *        Crowd (+15),
 *        Serious (+20),
 *        Weapon (+25) }
 *
 * Base-choice coverage:
 *   - Start with one base test where all characteristics use their base values.
 *   - For each non-base partition, create a test that varies only that partition
 *     while keeping the others at their base values.
 *
 * Total tests:
 *   1 (base) +
 *   (7 - 1) Type partitions +
 *   (2 - 1) Time partitions +
 *   (2 - 1) Place partitions +
 *   (5 - 1) Notes partitions
 *   = 13 tests.
 */
@ExtendWith(MockitoExtension.class)
public class IncidentServiceTest {

    @Mock
    IncidentRepository repository;

    @InjectMocks
    IncidentService service;

    @BeforeEach
    void setup() {
        // Stub repository.save(...) to simply return the same Incident instance.
        // This lets us verify the calculated score, rankLevel, and flags on the returned object.
        when(repository.save(any(Incident.class)))
                .thenAnswer(inv -> inv.getArgument(0, Incident.class));
    }

    /**
     * Base values:
     *   - Type: "Other"
     *   - Time: Day (2025-01-01 14:00)
     *   - Place: "office" (normal, non-vulnerable)
     *   - Notes: "" (no extra severity)
     */
    private Incident baseIncident() {
        Incident i = new Incident();
        i.setType("Other");                                   // base Type
        i.setTime(LocalDateTime.of(2025, 1, 1, 14, 0));       // Daytime (base Time)
        i.setPlace("office");                                 // Normal place (base Place)
        i.setNotes("");                                       // Notes Severity: None (base)
        return i;
    }

    // -------------------------------------------------------------------------
    // BC-0: Base-choice test
    // -------------------------------------------------------------------------

    /**
     * BC-0 (Base-choice):
     * All characteristics use base partitions:
     *   Type = Other, Time = Day, Place = Normal, Notes Severity = None.
     * Expectation: base score is 10, rank LOW, isNew = true, isRanked = false.
     */
    @Test
    void BC0_baseChoice_LOW_10pts() {
        Incident out = service.addNewIncident(baseIncident());

        assertTrue(out.isNew());
        assertEquals(10, out.getScore());
        assertEquals("LOW", out.getRankLevel());
        assertFalse(out.isRanked());

        verify(repository).save(out);
    }

    // -------------------------------------------------------------------------
    // Time characteristic: vary Time while keeping other characteristics at base.
    // -------------------------------------------------------------------------

    /**
     * Time = Night partition:
     * Varies Time from base Day -> Night (23:00), all other characteristics base.
     * Expectation: +10 points from night-time, score increases from 10 -> 20, still LOW.
     */
    @Test
    void time_night_adds10_LOW_20pts() {
        Incident i = baseIncident();
        i.setTime(LocalDateTime.of(2025, 1, 1, 23, 0));   // Night

        Incident out = service.addNewIncident(i);

        assertEquals(20, out.getScore());
        assertEquals("LOW", out.getRankLevel());
    }

    // -------------------------------------------------------------------------
    // Place characteristic: vary Place while keeping others at base.
    // -------------------------------------------------------------------------

    /**
     * Place = Vulnerable partition:
     * Varies Place from base "office" -> "Central Park" (contains "park", treated as vulnerable).
     * All other characteristics remain base.
     * Expectation: +8 points for vulnerable location, score 10 -> 18, still LOW.
     */
    @Test
    void place_vulnerable_adds8_LOW_18pts() {
        Incident i = baseIncident();
        i.setPlace("Central Park");   // contains "park" => vulnerable

        Incident out = service.addNewIncident(i);

        assertEquals(18, out.getScore());
        assertEquals("LOW", out.getRankLevel());
    }

    // -------------------------------------------------------------------------
    // Notes Severity characteristic: vary notes pattern while others are base.
    // -------------------------------------------------------------------------

    /**
     * Notes Severity = Minor (+10):
     * Adds keywords indicating minor injury ("child injured").
     * Only Notes partition changes; Type, Time, Place stay at base.
     * Expectation: +10 points from minor notes, score 10 -> 20, still LOW.
     */
    @Test
    void notes_minor_plus10_LOW_20pts() {
        Incident i = baseIncident();
        i.setNotes("child injured");   // matches injur*/child pattern

        Incident out = service.addNewIncident(i);

        assertEquals(20, out.getScore());
        assertEquals("LOW", out.getRankLevel());
    }

    /**
     * Notes Severity = Crowd (+15):
     * Notes mention mass / crowd situation ("mass crowd incident").
     * Only Notes partition changes.
     * Expectation: +15 points, score 10 -> 25, still LOW.
     */
    @Test
    void notes_crowd_plus15_LOW_25pts() {
        Incident i = baseIncident();
        i.setNotes("mass crowd incident");   // matches mass/crowd pattern

        Incident out = service.addNewIncident(i);

        assertEquals(25, out.getScore());
        assertEquals("LOW", out.getRankLevel());
    }

    /**
     * Notes Severity = Serious (+20):
     * Notes indicate serious / life-threatening situation ("one person unconscious").
     * Only Notes partition changes.
     * Expectation: +20 points, score 10 -> 30, still LOW.
     */
    @Test
    void notes_serious_plus20_LOW_30pts() {
        Incident i = baseIncident();
        i.setNotes("one person unconscious");   // serious / life-threatening

        Incident out = service.addNewIncident(i);

        assertEquals(30, out.getScore());
        assertEquals("LOW", out.getRankLevel());
    }

    /**
     * Notes Severity = Weapon (+25):
     * Notes mention weapon/explosive ("suspect with weapon").
     * Only Notes partition changes.
     * Expectation: +25 points, score 10 -> 35, still LOW.
     */
    @Test
    void notes_weapon_plus25_LOW_35pts() {
        Incident i = baseIncident();
        i.setNotes("suspect with weapon");   // weapon/explosive keywords

        Incident out = service.addNewIncident(i);

        assertEquals(35, out.getScore());
        assertEquals("LOW", out.getRankLevel());
    }

    // -------------------------------------------------------------------------
    // Type characteristic: vary Type while keeping Time, Place, Notes at base.
    // -------------------------------------------------------------------------

    /**
     * Type = Fire (HIGH priority type):
     * Varies Type from base "Other" -> "Fire".
     * All other characteristics are base (Day, Normal place, Notes None).
     * Expectation: minimum score for Fire = 75, rank HIGH, isRanked = true.
     */
    @Test
    void type_fire_min75_HIGH() {
        Incident i = baseIncident();
        i.setType("Fire");

        Incident out = service.addNewIncident(i);

        assertEquals(75, out.getScore());
        assertEquals("HIGH", out.getRankLevel());
        assertTrue(out.isRanked());
    }

    /**
     * Type = Medical Emergency (MEDIUM priority type):
     * Varies Type to "Medical Emergency", others are base.
     * Expectation: minimum score 55, rank MEDIUM, isRanked = true.
     */
    @Test
    void type_medical_min55_MEDIUM() {
        Incident i = baseIncident();
        i.setType("Medical Emergency");

        Incident out = service.addNewIncident(i);

        assertEquals(55, out.getScore());
        assertEquals("MEDIUM", out.getRankLevel());
        assertTrue(out.isRanked());
    }

    /**
     * Type = Armed Robbery (HIGH priority type):
     * Varies Type to "Armed Robbery", others base.
     * Expectation: minimum score 80, rank HIGH, isRanked = true.
     */
    @Test
    void type_armedRobbery_80_HIGH() {
        Incident i = baseIncident();
        i.setType("Armed Robbery");

        Incident out = service.addNewIncident(i);

        assertEquals(80, out.getScore());
        assertEquals("HIGH", out.getRankLevel());
        assertTrue(out.isRanked());
    }

    /**
     * Type = Violent Crime (HIGH priority type):
     * Varies Type to "Violent Crime", others base.
     * Expectation: minimum score 70, rank HIGH, isRanked = true.
     */
    @Test
    void type_violentCrime_70_HIGH() {
        Incident i = baseIncident();
        i.setType("Violent Crime");

        Incident out = service.addNewIncident(i);

        assertEquals(70, out.getScore());
        assertEquals("HIGH", out.getRankLevel());
        assertTrue(out.isRanked());
    }

    /**
     * Type = Traffic Accident (LOW priority type):
     * Varies Type to "Traffic Accident", others base.
     * Expectation: minimum score 40, rank LOW, isRanked = false.
     */
    @Test
    void type_trafficAccident_40_LOW() {
        Incident i = baseIncident();
        i.setType("Traffic Accident");

        Incident out = service.addNewIncident(i);

        assertEquals(40, out.getScore());
        assertEquals("LOW", out.getRankLevel());
        assertFalse(out.isRanked());
    }

    /**
     * Type = Disturbance (LOW priority type):
     * Varies Type to "Disturbance", others base.
     * Expectation: minimum score 25, rank LOW, isRanked = false.
     */
    @Test
    void type_disturbance_25_LOW() {
        Incident i = baseIncident();
        i.setType("Disturbance");

        Incident out = service.addNewIncident(i);

        assertEquals(25, out.getScore());
        assertEquals("LOW", out.getRankLevel());
        assertFalse(out.isRanked());
    }
}