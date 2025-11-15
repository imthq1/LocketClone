# **Locket Clone**
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-0175C2%3Flogo%3Ddart%26logoColor%3Dwhite)](https://dart.dev)
[![Java](https://img.shields.io/badge/Java-17-blue.svg)](https://www.oracle.com/java/technologies/javase/jdk17-archive-downloads.html)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.x-brightgreen.svg)](https://spring.io/projects/spring-boot)
[![MySQL](https://img.shields.io/badge/MySQL-4479A1%3Flogo%3Dmysql%26logoColor%3Dwhite)](https://www.mysql.com/)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.x-brightgreen.svg)](https://spring.io/projects/spring-boot)
[![Redis](https://img.shields.io/badge/Redis-DC382D%3Flogo%3Dredis%26logoColor%3Dwhite)](https://redis.io)

---

Dự án full-stack mô phỏng ứng dụng mạng xã hội Locket, bao gồm một máy chủ **Backend Spring Boot** và một ứng dụng di động **Frontend Flutter**.

## Tính năng chính

  * **Xác thực người dùng:** Đăng ký, đăng nhập, đăng xuất sử dụng **JWT (Access Token + Refresh Token)**. Access Token được lưu trên client và Refresh Token được xử lý để làm mới token tự động.
  * **Khôi phục mật khẩu:** Luồng khôi phục mật khẩu qua email sử dụng **Redis** để lưu trữ và xác thực OTP.
  * **Quản lý bạn bè:** Tìm kiếm người dùng qua email, gửi, chấp nhận, từ chối lời mời kết bạn và hủy kết bạn.
  * **Bài đăng (Feed):** Người dùng có thể tạo bài đăng (ảnh và chú thích). Feed hiển thị các bài đăng từ bạn bè và của chính mình.
  * **Upload ảnh:** Tích hợp dịch vụ **Cloudinary** để lưu trữ ảnh đại diện và ảnh bài đăng.
  * **Chat Realtime:** Nhắn tin thời gian thực giữa hai người dùng sử dụng **WebSocket (STOMP)**, bao gồm cả tính năng "đang gõ" (typing indicator).
  * **Quản lý hồ sơ:** Người dùng có thể cập nhật tên hiển thị và ảnh đại diện.

## Cấu trúc dự án

Kho lưu trữ này bao gồm hai dự án chính:

1.  `./BackEnd/`: Dự án Spring Boot API.
2.  `./locket_clone/`: Dự án ứng dụng di động Flutter.

## 🛠️ Công nghệ sử dụng

### Backend (Spring Boot)

  * **Ngôn ngữ:** Java 17
  * **Framework:** Spring Boot 3
  * **Bảo mật:** Spring Security (Xác thực JWT)
  * **Database:** Spring Data JPA, MySQL
  * **Realtime:** Spring WebSocket (STOMP) cho tính năng chat
  * **Cache/OTP:** Redis
  * **Lưu trữ file:** Cloudinary
  * **Gửi Email:** Spring Boot Starter Mail (dùng cho OTP)
  * **Container:** Docker (cho Redis)

### Frontend (Flutter)

  * **Quản lý State:** Provider
  * **Networking:** Dio (với Interceptor tự động refresh token)
  * **Lưu trữ an toàn:** `flutter_secure_storage` (để lưu Access Token)
  * **Realtime:** `stomp_dart_client` (để kết nối WebSocket với backend)
  * **Thiết bị:** `camera`, `image_picker`
  * **Quyền:** `permission_handler`
