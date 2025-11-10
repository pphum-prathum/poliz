package com.example.demo.service;

import com.example.demo.model.Chat;
import com.example.demo.model.Message;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
public class ChatService {

    private final List<Chat> chats = new ArrayList<>();

    public ChatService() {
        Chat c1 = new Chat("Pim", "Ploy");
        Chat c2 = new Chat("Nine", "Earn");
        Chat c3 = new Chat("Parn", "Sunny");
        Chat c4 = new Chat("Ploy", "Earn");

        // ตั้งค่าเริ่มต้นข้อความ
        c1.setLastMessage("Hey Ploy! How's the report?");
        c2.setLastMessage("Got it, heading to station now.");
        c3.setLastMessage("System maintenance scheduled at 6PM.");
        c4.setLastMessage("Ready for patrol.");

        // ตัวอย่าง: Pim ส่งหาพลอย → unreadForB = 1 (เพราะ Ploy ยังไม่ได้อ่าน)
        c1.setUnreadForA(0);
        c1.setUnreadForB(1);

        c2.setUnreadForA(0);
        c2.setUnreadForB(0);

        c3.setUnreadForA(2);
        c3.setUnreadForB(0);

        c4.setUnreadForA(0);
        c4.setUnreadForB(0);

        chats.addAll(List.of(c1, c2, c3, c4));
    }

    public List<Chat> getAll() {
        return chats;
    }

    public List<Chat> search(String keyword) {
        return chats.stream()
                .filter(c ->
                        (c.getUserA() + " " + c.getUserB()).toLowerCase().contains(keyword.toLowerCase()) ||
                                (c.getLastMessage() != null && c.getLastMessage().toLowerCase().contains(keyword.toLowerCase()))
                )
                .toList();
    }

    public Chat addMessage(Long id, Message msg) {
        for (Chat c : chats) {
            if (c.getId() != null && c.getId().equals(id)) {
                c.getMessages().add(msg);
                c.setLastMessage(msg.getText());

                // เพิ่ม unread เฉพาะฝั่งผู้รับ
                if (msg.getSender().equalsIgnoreCase(c.getUserA())) {
                    c.setUnreadForB(c.getUnreadForB() + 1);
                } else if (msg.getSender().equalsIgnoreCase(c.getUserB())) {
                    c.setUnreadForA(c.getUnreadForA() + 1);
                }

                return c;
            }
        }
        return null;
    }

    public Chat findById(Long id) {
        return chats.stream()
                .filter(c -> c.getId() != null && c.getId().equals(id))
                .findFirst()
                .orElse(null);
    }

    public boolean markAsReadByName(String name) {
        boolean updated = false;

        for (Chat c : chats) {
            if (c.getUserA().equalsIgnoreCase(name)) {
                if (c.getUnreadForA() > 0) {
                    c.setUnreadForA(0);
                    updated = true;
                }
            } else if (c.getUserB().equalsIgnoreCase(name)) {
                if (c.getUnreadForB() > 0) {
                    c.setUnreadForB(0);
                    updated = true;
                }
            }
        }

        return updated;
    }
}
