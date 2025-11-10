package com.example.demo.controller;

import com.example.demo.model.Chat;
import com.example.demo.model.Message;
import com.example.demo.model.User;
import com.example.demo.repository.ChatRepository;
import com.example.demo.repository.MessageRepository;
import com.example.demo.repository.UserRepository;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.util.*;

@RestController
@RequestMapping("/api/chats")
@CrossOrigin(origins = "*")
public class ChatController {

    private final UserRepository userRepo;
    private final ChatRepository chatRepo;
    private final MessageRepository msgRepo;

    public ChatController(UserRepository userRepo,
                          ChatRepository chatRepo,
                          MessageRepository msgRepo) {
        this.userRepo = userRepo;
        this.chatRepo = chatRepo;
        this.msgRepo = msgRepo;
    }

    // ---------- LOGIN ----------
    @PostMapping("/login")
    public Map<String, Object> login(@RequestBody Map<String, String> body) {
        String name = body.get("name");
        String password = body.get("password");

        User user = userRepo.findAll().stream()
                .filter(u -> u.getName().equalsIgnoreCase(name)
                        && u.getPassword().equals(password))
                .findFirst()
                .orElseThrow(() -> new RuntimeException("Invalid credentials"));

        return Map.of(
                "name", user.getName(),
                "initials", user.getInitials()
        );
    }

    // ---------- รายชื่อคู่แชท (หน้า SecureChatPage) ----------
    @GetMapping("/users")
    public List<Map<String, Object>> getAllUsers(@RequestParam String exclude) {
        List<User> users = userRepo.findAll();
        List<Map<String, Object>> result = new ArrayList<>();

        for (User u : users) {
            if (u.getName().equalsIgnoreCase(exclude)) continue;
            String other = u.getName();

            Chat chat = chatRepo.findByUserAAndUserB(exclude, other);
            if (chat == null)
                chat = chatRepo.findByUserAAndUserB(other, exclude);

            int unread = 0;
            String lastMessage = "Say hi 👋";

            if (chat != null) {
                unread = chat.getUnreadCountFor(exclude);
                if (chat.getLastMessage() != null && !chat.getLastMessage().isBlank()) {
                    lastMessage = chat.getLastMessage();
                }
            }

            Map<String, Object> map = new HashMap<>();
            map.put("id", u.getId());
            map.put("name", u.getName());
            map.put("initials", u.getInitials());
            map.put("unread", unread);
            map.put("lastMessage", lastMessage);
            result.add(map);
        }
        return result;
    }

    // ---------- ดึงข้อความระหว่างผู้ใช้สองคน ----------
    @GetMapping("/{user1}/{user2}/messages")
    public List<Message> getMessages(@PathVariable String user1, @PathVariable String user2) {
        Chat chat = chatRepo.findByUserAAndUserB(user1, user2);
        if (chat == null)
            chat = chatRepo.findByUserAAndUserB(user2, user1);
        if (chat == null)
            return List.of();

        return msgRepo.findByChatId(chat.getId());
    }

    // ---------- ส่งข้อความ ----------
    @Transactional
    @PostMapping("/{sender}/{receiver}/send")
    public Message sendMessage(
            @PathVariable String sender,
            @PathVariable String receiver,
            @RequestBody Map<String, String> body
    ) {
        String text = body.get("text");
        String time = body.get("time");

        if (text == null || text.isBlank()) {
            throw new RuntimeException("Message text is empty");
        }

        // หา (หรือสร้าง) ห้องแชท
        Chat chat = chatRepo.findByUserAAndUserB(sender, receiver);
        if (chat == null)
            chat = chatRepo.findByUserAAndUserB(receiver, sender);
        if (chat == null)
            chat = new Chat(sender, receiver);

        Message msg = new Message(sender, receiver, text, time);
        msg.setChat(chat);
        chat.addMessage(msg);

        chatRepo.save(chat);
        msgRepo.save(msg); // เผื่อกรณี cascade ยังไม่ทำงาน

        return msg;
    }

    // ---------- Mark-as-read ----------
    @PostMapping("/{username}/mark-read/{peer}")
    public void markChatAsReadForPeer(
            @PathVariable String username,
            @PathVariable String peer
    ) {
        Chat chat = chatRepo.findByUserAAndUserB(username, peer);
        if (chat == null)
            chat = chatRepo.findByUserAAndUserB(peer, username);

        if (chat != null) {
            chat.markAsReadFor(username);
            chatRepo.save(chat);
        }
    }

    // ---------- Mark-all ----------
    @PostMapping("/{username}/mark-read")
    public void markAllAsRead(@PathVariable String username) {
        List<Chat> chats = chatRepo.findByUserAOrUserB(username, username);
        for (Chat c : chats) {
            c.markAsReadFor(username);
            chatRepo.save(c);
        }
    }
}
