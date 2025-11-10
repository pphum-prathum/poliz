package com.example.demo.crime;

import jakarta.annotation.PostConstruct;
import org.springframework.stereotype.Component;

@Component
public class CrimeIncidentDataLoader {

    private final CrimeIncidentService service;

    public CrimeIncidentDataLoader(CrimeIncidentService service) {
        this.service = service;
    }

    @PostConstruct
    public void init() {
        // IMPORTANT: only seed if table is empty
        if (!service.getAllIncidents().isEmpty()) {
            return;
        }

        // 1) Central Ladprao
        service.save(create(
                "Robbery",
                "Central Ladprao",
                "18.53",
                "Armed robbery reported at mall parking area.",
                13.817174,
                100.561963
        ));

        // 2) Chulalongkorn Hospital
        service.save(create(
                "Accident",
                "Chulalongkorn Hospital",
                "12.05",
                "Traffic accident near hospital main entrance. EMS on site.",
                13.732561,
                100.536426
        ));

        // 3) Lumpini Park
        service.save(create(
                "Violence",
                "Lumpini Park",
                "09.38",
                "Assault reported near the lake jogging path. Patrol dispatched.",
                13.730556,
                100.541664
        ));

        // 4) BTS Bang Wa
        service.save(create(
                "Accident",
                "BTS Bang Wa",
                "08.58",
                "Collision between motorcycle and taxi at station entrance.",
                13.7225,
                100.4597
        ));

        // 5) Mahidol University (Salaya)
        service.save(create(
                "Arson",
                "Mahidol University (Salaya Campus)",
                "08.30",
                "Small fire reported near parking area, under investigation.",
                13.79452,
                100.32183
        ));
    }

    private CrimeIncident create(
            String type,
            String placeName,
            String timeLabel,
            String description,
            double latitude,
            double longitude
    ) {
        CrimeIncident c = new CrimeIncident();
        c.setType(type);
        c.setPlaceName(placeName);
        c.setTimeLabel(timeLabel);
        c.setDescription(description);
        c.setLatitude(latitude);
        c.setLongitude(longitude);
        return c;
    }
}