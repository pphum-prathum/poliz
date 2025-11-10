package com.example.demo.model;

import com.fasterxml.jackson.annotation.JsonManagedReference;
import jakarta.persistence.*;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "chats")
public class Chat {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // ----------- คู่สนทนา -----------
    private String userA;
    private String userB;

    // ----------- ข้อความล่าสุดในห้องนี้ -----------
    private String lastMessage;

    // unreadForA = จำนวนข้อความที่ "userA ยังไม่ได้อ่าน"
    // unreadForB = จำนวนข้อความที่ "userB ยังไม่ได้อ่าน"
    private int unreadForA = 0;
    private int unreadForB = 0;

    // mappedBy = "chat" => ให้ Message เป็นเจ้าของ foreign key (chat_id)
    @OneToMany(
            mappedBy = "chat",
            cascade = CascadeType.ALL,
            orphanRemoval = true,
            fetch = FetchType.LAZY
    )
    @JsonManagedReference

    private List<Message> messages = new ArrayList<>();

    // ---------- Constructor ----------
    public Chat() {}

    public Chat(String userA, String userB) {
        this.userA = userA;
        this.userB = userB;
        this.unreadForA = 0;
        this.unreadForB = 0;
    }

    // ---------- Getter / Setter ----------
    public Long getId() { return id; }

    public String getUserA() { return userA; }
    public void setUserA(String userA) { this.userA = userA; }

    public String getUserB() { return userB; }
    public void setUserB(String userB) { this.userB = userB; }

    public String getLastMessage() { return lastMessage; }
    public void setLastMessage(String lastMessage) { this.lastMessage = lastMessage; }

    public int getUnreadForA() { return unreadForA; }
    public void setUnreadForA(int unreadForA) { this.unreadForA = unreadForA; }

    public int getUnreadForB() { return unreadForB; }
    public void setUnreadForB(int unreadForB) { this.unreadForB = unreadForB; }

    public List<Message> getMessages() { return messages; }

    // ---------- Logic: เวลาเพิ่มข้อความใหม่ ----------
    public void addMessage(Message msg) {
        msg.setChat(this);
        this.messages.add(msg);
        this.lastMessage = msg.getText();

        if (msg.getSender().equalsIgnoreCase(this.userA)) {
            this.unreadForB++;
        } else if (msg.getSender().equalsIgnoreCase(this.userB)) {
            this.unreadForA++;
        }
    }

    // ---------- Helper ----------
    public int getUnreadCountFor(String username) {
        if (username.equalsIgnoreCase(userA)) {
            return unreadForA;
        } else if (username.equalsIgnoreCase(userB)) {
            return unreadForB;
        }
        return 0;
    }

    public void markAsReadFor(String username) {
        if (username.equalsIgnoreCase(userA)) {
            this.unreadForA = 0;
        } else if (username.equalsIgnoreCase(userB)) {
            this.unreadForB = 0;
        }
    }

    // ---------- Utility ----------
    @Override
    public String toString() {
        return "Chat{" +
                "id=" + id +
                ", userA='" + userA + '\'' +
                ", userB='" + userB + '\'' +
                ", lastMessage='" + lastMessage + '\'' +
                ", unreadForA=" + unreadForA +
                ", unreadForB=" + unreadForB +
                '}';
    }
}
