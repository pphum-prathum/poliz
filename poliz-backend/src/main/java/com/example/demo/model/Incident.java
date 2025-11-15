package com.example.demo.model; // เปลี่ยน demo เป็น Artifact name ของคุณ

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import lombok.Data;
import java.time.LocalDateTime;

@Entity
@Data
public class Incident {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String type;
    private String place;
    private LocalDateTime time;
    private String notes;

    private boolean isNew = true;
    private boolean isRanked = false;

    private int score;
    private String rankLevel;

    private Double latitude;
    private Double longitude;

}