# **Locket Clone**
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-0175C2%3Flogo%3Ddart%26logoColor%3Dwhite)](https://dart.dev)
[![Java](https://img.shields.io/badge/Java-17-blue.svg)](https://www.oracle.com/java/technologies/javase/jdk17-archive-downloads.html)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.x-brightgreen.svg)](https://spring.io/projects/spring-boot)
[![MySQL](https://img.shields.io/badge/MySQL-4479A1%3Flogo%3Dmysql%26logoColor%3Dwhite)](https://www.mysql.com/)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.x-brightgreen.svg)](https://spring.io/projects/spring-boot)
[![Redis](https://img.shields.io/badge/Redis-DC382D%3Flogo%3Dredis%26logoColor%3Dwhite)](https://redis.io)

A full-stack project simulating the Locket social media application, including a **Spring Boot Backend** server and a **Flutter Frontend** mobile app.

---

## Key Features

* **User Authentication:** Register, login, logout using **JWT (Access Token + Refresh Token)**. The Access Token is stored on the client, and the Refresh Token is handled to automatically refresh the token.
* **Password Recovery:** Password recovery flow via email using **Redis** to store and validate OTPs.
* **Friend Management:** Search for users by email, send, accept, decline friend requests, and unfriend users.
* **Posts (Feed):** Users can create posts (image and caption). The feed displays posts from friends and oneself.
* **Image Upload:** Integrated with **Cloudinary** service for storing profile pictures and post images.
* **Realtime Chat:** Real-time messaging between two users using **WebSocket (STOMP)**, including a "typing indicator" feature.
* **Profile Management:** Users can update their display name and profile picture.

## Project Structure

This repository includes two main projects:

1.  `./BackEnd/`: The Spring Boot API project.
2.  `./locket_clone/`: The Flutter mobile application project.

## Tech Stack

### Backend (Spring Boot)

* **Language:** Java 17
* **Framework:** Spring Boot 3
* **Security:** Spring Security (JWT Authentication)
* **Database:** Spring Data JPA, MySQL
* **Realtime:** Spring WebSocket (STOMP) for chat
* **Cache/OTP:** Redis
* **File Storage:** Cloudinary
* **Email:** Spring Boot Starter Mail (for OTP)
* **Containerization:** Docker (for Redis)

### Frontend (Flutter)

* **State Management:** Provider
* **Networking:** Dio (with interceptor for auto token refresh)
* **Secure Storage:** `flutter_secure_storage` (for storing Access Token)
* **Realtime:** `stomp_dart_client` (for WebSocket connection)
* **Device:** `camera`, `image_picker`
* **Permissions:** `permission_handler`

## License

This project is licensed under the **MIT License**. See the [LICENSE](LICENSE) file for details.
