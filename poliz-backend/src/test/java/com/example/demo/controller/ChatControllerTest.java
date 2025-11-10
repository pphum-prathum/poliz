package com.example.demo.controller;

import com.example.demo.model.Chat;
import com.example.demo.model.Message;
import com.example.demo.repository.ChatRepository;
import com.example.demo.repository.MessageRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.springframework.boot.test.context.SpringBootTest;

import java.util.Map;

import static org.mockito.Mockito.*;
import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
class ChatControllerTest {

    @InjectMocks
    private ChatController chatController;

    @Mock
    private ChatRepository chatRepo;

    @Mock
    private MessageRepository msgRepo;

    @BeforeEach
    void setUp() {
        // Mock chat between Pim and Ploy
        Chat chat = new Chat("Pim", "Ploy");
        when(chatRepo.findByUserAAndUserB("Pim", "Ploy")).thenReturn(chat); // คืนค่า Chat แทน Optional
    }

    // T1: ข้อความไม่เป็นค่าว่าง, ห้องแชทมีอยู่, ข้อความไม่ถูกบันทึก (โยน exception)
    @Test
    void testSendMessage_ValidText_ExistingChat_Exception() {
        Map<String, String> messageBody = Map.of("text", "Hello Ploy!", "time", "12:30 PM");
        when(msgRepo.save(any(Message.class))).thenThrow(new RuntimeException("Message text is empty"));

        RuntimeException exception = assertThrows(RuntimeException.class, () -> {
            chatController.sendMessage("Pim", "Ploy", messageBody);
        });

        assertEquals("Message text is empty", exception.getMessage());
    }

    // T2: ข้อความไม่เป็นค่าว่าง, ห้องแชทมีอยู่, ข้อความถูกบันทึกสำเร็จ
    @Test
    void testSendMessage_ValidText_ExistingChat_Success() {
        Map<String, String> messageBody = Map.of("text", "Hello Ploy!", "time", "12:30 PM");
        Message message = new Message("Pim", "Ploy", "Hello Ploy!", "12:30 PM");
        when(msgRepo.save(any(Message.class))).thenReturn(message);

        Message savedMessage = chatController.sendMessage("Pim", "Ploy", messageBody);

        assertNotNull(savedMessage);
        assertEquals("Hello Ploy!", savedMessage.getText());
        assertEquals("Pim", savedMessage.getSender());
        assertEquals("Ploy", savedMessage.getReceiver());
    }

    // T3: ข้อความไม่เป็นค่าว่าง, ห้องแชทไม่มีอยู่, ข้อความไม่ถูกบันทึก (โยน exception)
    @Test
    void testSendMessage_ValidText_NewChat_Exception() {
        Map<String, String> messageBody = Map.of("text", "Hey Earn, let's chat!", "time", "12:45 PM");

        // Mock chatRepo ให้คืนค่า null (ไม่พบห้องแชท)
        when(chatRepo.findByUserAAndUserB("Pim", "Earn")).thenReturn(null);
        when(msgRepo.save(any(Message.class))).thenThrow(new RuntimeException("Message text is empty"));

        RuntimeException exception = assertThrows(RuntimeException.class, () -> {
            chatController.sendMessage("Pim", "Earn", messageBody);
        });

        assertEquals("Message text is empty", exception.getMessage());
    }

    // T4: ข้อความไม่เป็นค่าว่าง, ห้องแชทไม่มีอยู่, ข้อความถูกบันทึกสำเร็จ
    @Test
    void testSendMessage_ValidText_NewChat_Success() {
        Map<String, String> messageBody = Map.of("text", "Hey Earn, let's chat!", "time", "12:45 PM");

        // Mock chatRepo ให้คืนค่า null (ไม่พบห้องแชท)
        Chat newChat = new Chat("Pim", "Earn");
        when(chatRepo.findByUserAAndUserB("Pim", "Earn")).thenReturn(null);  // คืนค่า null เมื่อไม่พบห้องแชท
        when(chatRepo.save(any(Chat.class))).thenReturn(newChat);
        when(msgRepo.save(any(Message.class))).thenReturn(new Message("Pim", "Earn", "Hey Earn, let's chat!", "12:45 PM"));

        Message savedMessage = chatController.sendMessage("Pim", "Earn", messageBody);

        assertNotNull(savedMessage);
        assertEquals("Hey Earn, let's chat!", savedMessage.getText());
        assertEquals("Pim", savedMessage.getSender());
        assertEquals("Earn", savedMessage.getReceiver());
    }

    // T5: ข้อความเป็นค่าว่าง, ห้องแชทมีอยู่, ข้อความไม่ถูกบันทึก (โยน exception)
    @Test
    void testSendMessage_EmptyText_ExistingChat_Exception() {
        Map<String, String> messageBody = Map.of("text", "", "time", "12:50 PM");

        when(msgRepo.save(any(Message.class))).thenThrow(new RuntimeException("Message text is empty"));

        RuntimeException exception = assertThrows(RuntimeException.class, () -> {
            chatController.sendMessage("Pim", "Ploy", messageBody);
        });

        assertEquals("Message text is empty", exception.getMessage());
    }

    // T6: ข้อความเป็นค่าว่าง, ห้องแชทมีอยู่, ข้อความไม่ถูกบันทึก (โยน exception)
    @Test
    void testSendMessage_EmptyText_ExistingChat_Exception_2() {
        Map<String, String> messageBody = Map.of("text", "", "time", "12:50 PM");

        RuntimeException exception = assertThrows(RuntimeException.class, () -> {
            chatController.sendMessage("Pim", "Ploy", messageBody);
        });

        assertEquals("Message text is empty", exception.getMessage());
    }

    // T7: ข้อความเป็นค่าว่าง, ห้องแชทไม่มีอยู่, ข้อความไม่ถูกบันทึก (โยน exception)
    @Test
    void testSendMessage_EmptyText_NewChat_Exception() {
        Map<String, String> messageBody = Map.of("text", "", "time", "12:50 PM");

        RuntimeException exception = assertThrows(RuntimeException.class, () -> {
            chatController.sendMessage("Pim", "Earn", messageBody);
        });

        assertEquals("Message text is empty", exception.getMessage());
    }

    // T8: ข้อความเป็นค่าว่าง, ห้องแชทไม่มีอยู่, ข้อความไม่ถูกบันทึก (โยน exception)
    @Test
    void testSendMessage_EmptyText_NewChat_Exception_2() {
        Map<String, String> messageBody = Map.of("text", "", "time", "12:50 PM");

        RuntimeException exception = assertThrows(RuntimeException.class, () -> {
            chatController.sendMessage("Pim", "Earn", messageBody);
        });

        assertEquals("Message text is empty", exception.getMessage());
    }
}
