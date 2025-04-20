package com.example.SendMailDemo.entity;

// Importing required classes
import lombok.*;

// Annotations
@Data
@AllArgsConstructor
@NoArgsConstructor
// Class
public class EmailDetails {

    // Class data members
    private String recipient;
    private String msgBody;
    private String subject;
    private String attachment;

    public String getAttachment() {
        return attachment;
    }

    public String getMsgBody() {
        return msgBody;
    }

    public String getRecipient() {
        return recipient;
    }

    public String getSubject() {
        return subject;
    }
}
