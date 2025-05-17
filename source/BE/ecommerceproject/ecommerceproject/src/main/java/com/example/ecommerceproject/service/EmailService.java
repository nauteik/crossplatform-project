package com.example.ecommerceproject.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import java.util.Map;

@Service
public class EmailService {

    @Autowired
    private JavaMailSender mailSender;

    @Async
    public void sendAccountCreationEmail(Map<String, Object> emailData) {
        String to = (String) emailData.get("to");
        String username = (String) emailData.get("username");
        String email = (String) emailData.get("email");
        String password = (String) emailData.get("password");
        
        try {
            MimeMessage mimeMessage = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(mimeMessage, true, "UTF-8");
            
            helper.setTo(to);
            helper.setSubject("Tài khoản của bạn đã được tạo");
            
            // HTML email template với CSS styling
            String htmlContent = 
                "<!DOCTYPE html>" +
                "<html>" +
                "<head>" +
                "    <meta charset=\"UTF-8\">" +
                "    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">" +
                "    <title>Chào mừng bạn đến với cửa hàng của chúng tôi</title>" +
                "    <style>" +
                "        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px; }" +
                "        .header { background-color: #4CAF50; color: white; padding: 15px; text-align: center; border-radius: 5px 5px 0 0; }" +
                "        .content { background-color: #f9f9f9; padding: 20px; border-left: 1px solid #ddd; border-right: 1px solid #ddd; }" +
                "        .footer { background-color: #f1f1f1; padding: 15px; text-align: center; font-size: 0.8em; color: #777; border-radius: 0 0 5px 5px; border: 1px solid #ddd; }" +
                "        .credentials { background-color: #fff; border: 1px solid #ddd; padding: 15px; margin: 15px 0; border-radius: 4px; }" +
                "        .button { display: inline-block; background-color: #4CAF50; color: white; padding: 10px 20px; text-decoration: none; border-radius: 4px; margin-top: 15px; }" +
                "        .warning { color: #D8000C; background-color: #FFBABA; padding: 10px; border-radius: 4px; margin-top: 15px; }" +
                "    </style>" +
                "</head>" +
                "<body>" +
                "    <div class=\"header\">" +
                "        <h1>Chào mừng bạn!</h1>" +
                "    </div>" +
                "    <div class=\"content\">" +
                "        <p>Cảm ơn bạn đã mua hàng tại cửa hàng của chúng tôi. Tài khoản của bạn đã được tạo tự động.</p>" +
                "        <p>Dưới đây là thông tin đăng nhập của bạn:</p>" +
                "        <div class=\"credentials\">" +
                "            <p><strong>Tên đăng nhập:</strong> " + username + "</p>" +
                "            <p><strong>Email:</strong> " + email + "</p>" +
                "            <p><strong>Mật khẩu:</strong> " + password + "</p>" +
                "        </div>" +
                "        <p class=\"warning\">Vui lòng thay đổi mật khẩu của bạn ngay sau khi đăng nhập lần đầu tiên.</p>" +
                "        <a href=\"http://localhost:3000/login\" class=\"button\">Đăng nhập ngay</a>" +
                "        <p>Nếu bạn có bất kỳ câu hỏi nào, vui lòng liên hệ với chúng tôi qua email hỗ trợ.</p>" +
                "    </div>" +
                "    <div class=\"footer\">" +
                "        <p>&copy; 2024 Cửa hàng của chúng tôi. Tất cả các quyền được bảo lưu.</p>" +
                "        <p>Đây là email tự động, vui lòng không trả lời.</p>" +
                "    </div>" +
                "</body>" +
                "</html>";
            
            helper.setText(htmlContent, true); // 'true' parameter indicates html content
            mailSender.send(mimeMessage);
            
        } catch (MessagingException e) {
            e.printStackTrace();
            // Consider proper error handling/logging here
        }
    }
    
    // Thêm các phương thức gửi email khác nếu cần
    @Async
    public void sendOrderConfirmationEmail(Map<String, Object> emailData) {
        String to = (String) emailData.get("to");
        String customerName = (String) emailData.get("customerName");
        String orderId = (String) emailData.get("orderId");
        Double totalAmount = (Double) emailData.get("totalAmount");
        
        try {
            MimeMessage mimeMessage = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(mimeMessage, true, "UTF-8");
            
            helper.setTo(to);
            helper.setSubject("Xác nhận đơn hàng #" + orderId);
            
            // HTML email template cho xác nhận đơn hàng
            String htmlContent = 
                "<!DOCTYPE html>" +
                "<html>" +
                "<head>" +
                "    <meta charset=\"UTF-8\">" +
                "    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">" +
                "    <title>Xác nhận đơn hàng của bạn</title>" +
                "    <style>" +
                "        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px; }" +
                "        .header { background-color: #3498db; color: white; padding: 15px; text-align: center; border-radius: 5px 5px 0 0; }" +
                "        .content { background-color: #f9f9f9; padding: 20px; border-left: 1px solid #ddd; border-right: 1px solid #ddd; }" +
                "        .footer { background-color: #f1f1f1; padding: 15px; text-align: center; font-size: 0.8em; color: #777; border-radius: 0 0 5px 5px; border: 1px solid #ddd; }" +
                "        .order-info { background-color: #fff; border: 1px solid #ddd; padding: 15px; margin: 15px 0; border-radius: 4px; }" +
                "        .button { display: inline-block; background-color: #3498db; color: white; padding: 10px 20px; text-decoration: none; border-radius: 4px; margin-top: 15px; }" +
                "        .total { font-size: 18px; font-weight: bold; margin-top: 15px; }" +
                "    </style>" +
                "</head>" +
                "<body>" +
                "    <div class=\"header\">" +
                "        <h1>Đơn hàng đã được xác nhận!</h1>" +
                "    </div>" +
                "    <div class=\"content\">" +
                "        <p>Xin chào " + customerName + ",</p>" +
                "        <p>Cảm ơn bạn đã đặt hàng tại cửa hàng của chúng tôi. Đơn hàng của bạn đã được xác nhận và đang được xử lý.</p>" +
                "        <div class=\"order-info\">" +
                "            <p><strong>Mã đơn hàng:</strong> " + orderId + "</p>" +
                "            <p><strong>Tổng giá trị:</strong> " + String.format("%,.0f", totalAmount) + " VNĐ</p>" +
                "        </div>" +
                "        <p>Bạn có thể theo dõi trạng thái đơn hàng của mình trong mục 'Đơn hàng của tôi' trên trang web của chúng tôi.</p>" +
                "        <a href=\"http://localhost:3000/orders\" class=\"button\">Xem đơn hàng</a>" +
                "    </div>" +
                "    <div class=\"footer\">" +
                "        <p>&copy; 2024 Cửa hàng của chúng tôi. Tất cả các quyền được bảo lưu.</p>" +
                "        <p>Đây là email tự động, vui lòng không trả lời.</p>" +
                "    </div>" +
                "</body>" +
                "</html>";
            
            helper.setText(htmlContent, true);
            mailSender.send(mimeMessage);
            
        } catch (MessagingException e) {
            e.printStackTrace();
            // Consider proper error handling/logging here
        }
    }

    @Async
    public void sendPasswordResetEmail(Map<String, Object> emailData) {
        String to = (String) emailData.get("to");
        String username = (String) emailData.get("username");
        String newPassword = (String) emailData.get("newPassword");
        
        try {
            MimeMessage mimeMessage = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(mimeMessage, true, "UTF-8");
            
            helper.setTo(to);
            helper.setSubject("Mật khẩu mới cho tài khoản của bạn");
            
            // HTML email template với CSS styling
            String htmlContent = 
                "<!DOCTYPE html>" +
                "<html>" +
                "<head>" +
                "    <meta charset=\"UTF-8\">" +
                "    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">" +
                "    <title>Mật khẩu mới của bạn</title>" +
                "    <style>" +
                "        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px; }" +
                "        .header { background-color: #e74c3c; color: white; padding: 15px; text-align: center; border-radius: 5px 5px 0 0; }" +
                "        .content { background-color: #f9f9f9; padding: 20px; border-left: 1px solid #ddd; border-right: 1px solid #ddd; }" +
                "        .footer { background-color: #f1f1f1; padding: 15px; text-align: center; font-size: 0.8em; color: #777; border-radius: 0 0 5px 5px; border: 1px solid #ddd; }" +
                "        .credentials { background-color: #fff; border: 1px solid #ddd; padding: 15px; margin: 15px 0; border-radius: 4px; }" +
                "        .button { display: inline-block; background-color: #e74c3c; color: white; padding: 10px 20px; text-decoration: none; border-radius: 4px; margin-top: 15px; }" +
                "        .warning { color: #D8000C; background-color: #FFBABA; padding: 10px; border-radius: 4px; margin-top: 15px; }" +
                "        .note { font-style: italic; margin-top: 10px; }" +
                "    </style>" +
                "</head>" +
                "<body>" +
                "    <div class=\"header\">" +
                "        <h1>Đặt lại mật khẩu</h1>" +
                "    </div>" +
                "    <div class=\"content\">" +
                "        <p>Bạn đã yêu cầu đặt lại mật khẩu cho tài khoản của mình. Dưới đây là thông tin đăng nhập đầy đủ của bạn:</p>" +
                "        <div class=\"credentials\">" +
                "            <p><strong>Tên đăng nhập:</strong> " + username + "</p>" +
                "            <p><strong>Mật khẩu mới:</strong> " + newPassword + "</p>" +
                "        </div>" +
                "        <p class=\"note\">Bạn có thể đăng nhập với mật khẩu mới.</p>" +
                "        <p class=\"warning\">Vui lòng thay đổi mật khẩu ngay sau khi đăng nhập để đảm bảo an toàn cho tài khoản của bạn.</p>" +
                "    </div>" +
                "    <div class=\"footer\">" +
                "        <p>Đây là email tự động, vui lòng không trả lời.</p>" +
                "    </div>" +
                "</body>" +
                "</html>";
    
            helper.setText(htmlContent, true);
            mailSender.send(mimeMessage);
            
        } catch (MessagingException e) {
            e.printStackTrace();
            // Consider proper error handling/logging here
        }
    }
}