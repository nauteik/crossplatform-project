package com.example.ecommerceproject.service;

import com.example.ecommerceproject.model.Address;
import com.example.ecommerceproject.model.OrderItem;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import java.util.Map;
import java.util.List;
import java.lang.StringBuilder;

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
    
    @Async
    public void sendOrderConfirmationEmail(Map<String, Object> emailData) {
        String to = (String) emailData.get("to");
        String customerName = (String) emailData.get("customerName");
        String orderId = (String) emailData.get("orderId");
        Double totalAmount = (Double) emailData.get("totalAmount");
        List<OrderItem> orderItems = (List<OrderItem>) emailData.get("orderItems");
        String paymentMethod = (String) emailData.get("paymentMethod");
        Address shippingAddress = (Address) emailData.get("shippingAddress");
        boolean hasCoupon = (boolean) emailData.get("hasCoupon");
        Double couponDiscount = 0.0;
        Double finalAmount = totalAmount;
        String couponCode = "";
        
        if (hasCoupon) {
            couponCode = (String) emailData.get("couponCode");
            couponDiscount = (Double) emailData.get("couponDiscount");
            finalAmount = (Double) emailData.get("finalAmount");
        }
        
        try {
            MimeMessage mimeMessage = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(mimeMessage, true, "UTF-8");
            
            helper.setTo(to);
            helper.setSubject("Xác nhận đơn hàng #" + orderId);
            
            // Tạo phần hiển thị cho danh sách sản phẩm
            StringBuilder itemsHtml = new StringBuilder();
            for (OrderItem item : orderItems) {
                itemsHtml.append("<tr>")
                    .append("<td style=\"padding: 10px; border-bottom: 1px solid #ddd;\">")
                    .append(item.getProductName())
                    .append("</td>")
                    .append("<td style=\"padding: 10px; border-bottom: 1px solid #ddd; text-align: center;\">")
                    .append(item.getQuantity())
                    .append("</td>")
                    .append("<td style=\"padding: 10px; border-bottom: 1px solid #ddd; text-align: right;\">")
                    .append(String.format("%,.0f", item.getPrice()))
                    .append(" VNĐ</td>")
                    .append("<td style=\"padding: 10px; border-bottom: 1px solid #ddd; text-align: right;\">")
                    .append(String.format("%,.0f", item.getPrice() * item.getQuantity()))
                    .append(" VNĐ</td>")
                    .append("</tr>");
            }
            
            // Phần hiển thị thông tin địa chỉ giao hàng
            String addressHtml = "<p><strong>Địa chỉ giao hàng:</strong><br/>" +
                (shippingAddress.getFullName() != null && !shippingAddress.getFullName().isEmpty() ? 
                    shippingAddress.getFullName() + "<br/>" : "") +
                (shippingAddress.getPhoneNumber() != null && !shippingAddress.getPhoneNumber().isEmpty() ? 
                    shippingAddress.getPhoneNumber() + "<br/>" : "") +
                shippingAddress.getAddressLine() + "<br/>" +
                shippingAddress.getWard() + ", " + 
                shippingAddress.getDistrict() + ", " + 
                shippingAddress.getCity() + "</p>";
            
            // Phần hiển thị thông tin giảm giá nếu có áp dụng coupon
            String couponHtml = "";
            if (hasCoupon) {
                couponHtml = 
                    "<tr>" +
                    "   <td colspan=\"3\" style=\"text-align: right; padding: 10px;\"><strong>Tổng tiền hàng:</strong></td>" +
                    "   <td style=\"text-align: right; padding: 10px;\">" + String.format("%,.0f", totalAmount) + " VNĐ</td>" +
                    "</tr>" +
                    "<tr>" +
                    "   <td colspan=\"3\" style=\"text-align: right; padding: 10px; color: green;\"><strong>Giảm giá (Mã: " + couponCode + "):</strong></td>" +
                    "   <td style=\"text-align: right; padding: 10px; color: green;\">-" + String.format("%,.0f", couponDiscount) + " VNĐ</td>" +
                    "</tr>";
            }
            
            // HTML email template cho xác nhận đơn hàng
            String htmlContent = 
                "<!DOCTYPE html>" +
                "<html>" +
                "<head>" +
                "    <meta charset=\"UTF-8\">" +
                "    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">" +
                "    <title>Xác nhận đơn hàng của bạn</title>" +
                "    <style>" +
                "        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; line-height: 1.6; color: #333; max-width: 800px; margin: 0 auto; padding: 20px; }" +
                "        .header { background-color: #4361ee; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0; }" +
                "        .content { background-color: #ffffff; padding: 25px; border: 1px solid #ddd; border-top: none; }" +
                "        .footer { background-color: #f8f9fa; padding: 15px; text-align: center; font-size: 0.85em; color: #6c757d; border-radius: 0 0 8px 8px; border: 1px solid #ddd; border-top: none; }" +
                "        .order-info { background-color: #f8f9fa; border: 1px solid #e9ecef; padding: 20px; margin: 20px 0; border-radius: 8px; }" +
                "        .button { display: inline-block; background-color: #4361ee; color: white; padding: 12px 25px; text-decoration: none; border-radius: 6px; margin-top: 20px; font-weight: bold; }" +
                "        .total { font-size: 18px; font-weight: bold; margin-top: 15px; color: #e63946; }" +
                "        .thank-you { font-size: 20px; color: #4361ee; margin-top: 30px; text-align: center; }" +
                "        .logo { max-width: 150px; margin-bottom: 10px; }" +
                "        .items-table { width: 100%; border-collapse: collapse; margin-top: 20px; }" +
                "        .items-table th { background-color: #f8f9fa; text-align: left; padding: 12px; border-bottom: 2px solid #dee2e6; }" +
                "        .items-table td { padding: 12px; border-bottom: 1px solid #dee2e6; }" +
                "        .address-section { margin-top: 25px; padding: 15px; background-color: #f8f9fa; border-radius: 8px; }" +
                "        .payment-method { color: #2a9d8f; font-weight: bold; }" +
                "        .discount { color: #2a9d8f; }" +
                "        .order-id { font-family: monospace; background-color: #f8f9fa; padding: 5px 10px; border-radius: 4px; }" +
                "    </style>" +
                "</head>" +
                "<body>" +
                "    <div class=\"header\">" +
                "        <h1>Đơn hàng của bạn đã được xác nhận</h1>" +
                "    </div>" +
                "    <div class=\"content\">" +
                "        <p>Xin chào " + customerName + ",</p>" +
                "        <p>Cảm ơn bạn đã mua sắm tại cửa hàng của chúng tôi. Đơn hàng của bạn đã được xác nhận thành công và đang được xử lý.</p>" +
                "        <div class=\"order-info\">" +
                "            <p><strong>Mã đơn hàng:</strong> <span class=\"order-id\">" + orderId + "</span></p>" +
                "            <p><strong>Phương thức thanh toán:</strong> <span class=\"payment-method\">" + formatPaymentMethod(paymentMethod) + "</span></p>" +
                addressHtml +
                "        </div>" +
                "        <h3>Chi tiết đơn hàng:</h3>" +
                "        <table class=\"items-table\">" +
                "            <thead>" +
                "                <tr>" +
                "                    <th>Sản phẩm</th>" +
                "                    <th style=\"text-align: center;\">Số lượng</th>" +
                "                    <th style=\"text-align: right;\">Đơn giá</th>" +
                "                    <th style=\"text-align: right;\">Thành tiền</th>" +
                "                </tr>" +
                "            </thead>" +
                "            <tbody>" +
                itemsHtml.toString() +
                "            </tbody>" +
                "            <tfoot>" +
                couponHtml +
                "                <tr>" +
                "                    <td colspan=\"3\" style=\"text-align: right; padding: 15px;\"><strong>Tổng thanh toán:</strong></td>" +
                "                    <td style=\"text-align: right; padding: 15px;\" class=\"total\">" + String.format("%,.0f", finalAmount) + " VNĐ</td>" +
                "                </tr>" +
                "            </tfoot>" +
                "        </table>" +
                "        <p class=\"thank-you\">Cảm ơn bạn đã mua sắm cùng chúng tôi!</p>" +
                "        <p>Bạn có thể theo dõi trạng thái đơn hàng của mình trong mục 'Đơn hàng của tôi' trên trang web của chúng tôi.</p>" +
                "        <div style=\"text-align: center;\">" +
                "            <a href=\"http://localhost:3000/orders\" class=\"button\">Xem đơn hàng</a>" +
                "        </div>" +
                "    </div>" +
                "    <div class=\"footer\">" +
                "        <p>&copy; 2024 Computer Store. Tất cả các quyền được bảo lưu.</p>" +
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
    
    /**
     * Format payment method name for displaying in email
     */
    private String formatPaymentMethod(String method) {
        switch (method) {
            case "CREDIT_CARD":
                return "Thẻ tín dụng";
            case "COD":
                return "Thanh toán khi nhận hàng";
            case "BANK_TRANSFER":
                return "Chuyển khoản ngân hàng";
            case "MOMO":
                return "Ví MoMo";
            default:
                return method;
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