package com.example.demo.model;

import jakarta.persistence.*;

@Entity
@Table(name = "users")
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;        // ชื่อผู้ใช้
    private String initials;    // ตัวย่อ (แสดงในวงกลม Avatar)
    private String password;    // รหัสผ่าน (ใช้ login mock)

    // ---------- Constructors ----------
    public User() {}

    // ✅ ใช้ constructor นี้เวลา seed ข้อมูลใน DataLoader
    public User(String name, String password) {
        this.name = name;
        this.password = password;
        // ตั้ง initials จากชื่อโดยอัตโนมัติ เช่น "Ploy" -> "PL"
        this.initials = name.length() >= 2
                ? name.substring(0, 2).toUpperCase()
                : name.toUpperCase();
    }

    // ✅ ใช้ constructor แบบกำหนด initials เอง (กรณีต้องการ override)
    public User(String name, String initials, String password) {
        this.name = name;
        this.initials = initials;
        this.password = password;
    }

    // ---------- Getters / Setters ----------
    public Long getId() { return id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getInitials() { return initials; }
    public void setInitials(String initials) { this.initials = initials; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    // ---------- Utility ----------
    @Override
    public String toString() {
        return "User{" +
                "id=" + id +
                ", name='" + name + '\'' +
                ", initials='" + initials + '\'' +
                '}';
    }
}
