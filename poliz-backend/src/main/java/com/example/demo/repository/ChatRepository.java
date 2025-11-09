package com.example.demo.repository;

import com.example.demo.model.Chat;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface ChatRepository extends JpaRepository<Chat, Long> {
    List<Chat> findByUserAOrUserB(String userA, String userB);
    Chat findByUserAAndUserB(String userA, String userB);
    Chat findByUserBAndUserA(String userB, String userA);
}
