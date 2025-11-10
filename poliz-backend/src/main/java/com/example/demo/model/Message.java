package com.example.demo.model;

import com.fasterxml.jackson.annotation.JsonBackReference;
import jakarta.persistence.*;

@Entity
@Table(name = "messages")
public class Message {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // ----------- ผู้ส่ง / ผู้รับ -----------
    private String sender;
    private String receiver;

    // ----------- เนื้อหาข้อความ -----------
    private String text;
    private String time;

    // ----------- ความสัมพันธ์กับ Chat -----------

    @ManyToOne(fetch = FetchType.LAZY)
    @JsonBackReference
    @JoinColumn(name = "chat_id")
    private Chat chat;

    // ---------- Constructor ----------
    public Message() {}

    public Message(String sender, String receiver, String text, String time) {
        this.sender = sender;
        this.receiver = receiver;
        this.text = text;
        this.time = time;
    }

    // ---------- Getter / Setter ----------
    public Long getId() { return id; }

    public String getSender() { return sender; }
    public void setSender(String sender) { this.sender = sender; }

    public String getReceiver() { return receiver; }
    public void setReceiver(String receiver) { this.receiver = receiver; }

    public String getText() { return text; }
    public void setText(String text) { this.text = text; }

    public String getTime() { return time; }
    public void setTime(String time) { this.time = time; }

    public Chat getChat() { return chat; }
    public void setChat(Chat chat) { this.chat = chat; }

    // ---------- Utility ----------
    @Override
    public String toString() {
        return "Message{" +
                "id=" + id +
                ", sender='" + sender + '\'' +
                ", receiver='" + receiver + '\'' +
                ", text='" + text + '\'' +
                ", time='" + time + '\'' +
                '}';
    }
}
