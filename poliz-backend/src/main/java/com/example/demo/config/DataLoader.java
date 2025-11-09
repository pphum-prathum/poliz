package com.example.demo.config;

import com.example.demo.model.User;
import com.example.demo.repository.UserRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class DataLoader {

    @Bean
    CommandLineRunner initUsers(UserRepository repo) {
        return args -> {
            if (repo.count() == 0) {
                repo.save(new User("Pim", "PM", "Pim"));
                repo.save(new User("Ploy", "PP", "Ploy"));
                repo.save(new User("Nine", "NE", "Nine"));
                repo.save(new User("Earn", "EN", "Earn"));
                repo.save(new User("Parn", "PN", "Parn"));
                repo.save(new User("Sunny", "SN", "Sunny"));
                System.out.println("✅ Sample users inserted into H2 DB!");
            } else {
                System.out.println("ℹ️ Users already exist in DB.");
            }
        };
    }
}
