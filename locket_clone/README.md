## Luồng Xác Thực (Authentication Flow)
### 1. Đăng Nhập (Login)

1.  **UI**: Người dùng nhập email và mật khẩu, sau đó gọi `AuthController.login()`.
2.  **Repository & API**: `AuthRepository` gọi đến `AuthApi.login()` để gửi yêu cầu đến server.
3.  **Phản hồi**: Server trả về **Access Token (AT)** trong body và **Refresh Token (RT)** qua cookie.
4.  **Lưu trữ & Cập nhật**:
    * Lưu **AT** vào bộ nhớ an toàn (Secure Storage).
    * Gọi API `/auth/account` để lấy thông tin người dùng và cập nhật state.
5.  **Điều hướng**: Chuyển người dùng đến màn hình `/home`.

### 2. Đăng Ký (Register)

1.  **Nhập thông tin**:
    * `RegisterScreen`: Người dùng nhập email và mật khẩu.
    * `CreateUsernameScreen`: Người dùng nhập tên đầy đủ (Full Name).
2.  **Thực thi**: Hàm `registerThenLogin()` được gọi.
    * Đầu tiên, `AuthApi.register()` được gọi để tạo tài khoản.
    * Nếu thành công, ứng dụng tự động thực hiện luồng **Đăng Nhập** như trên để lấy token và điều hướng người dùng đến `/home`.

### 3. Xử lý khi Access Token (AT) hết hạn

1.  **Phát hiện lỗi**: Khi một yêu cầu API trả về mã lỗi `401 Unauthorized`.
2.  **Interceptor xử lý**: `RefreshInterceptor` sẽ tự động bắt lỗi này.
3.  **Làm mới Token**: Interceptor gửi yêu cầu đến endpoint `/auth/refresh` (kèm theo **RT** trong cookie) để lấy **AT** mới.
4.  **Cập nhật & Thử lại**:
    * Lưu **AT** mới vào Secure Storage.
    * Tự động thực hiện lại yêu cầu API ban đầu bị lỗi.

### 4. Đăng Xuất (Logout)

1.  **API Call**: Gọi `AuthApi.logout()`.
2.  **Xử lý**:
    * **Server**: Thu hồi **RT** và xóa cookie.
    * **Client**: Xóa **AT** khỏi Secure Storage.
3.  **Điều hướng**: Chuyển người dùng về màn hình `/login`.

---

## Cấu Trúc Dự Án (Project Structure)
### `core/` - Nền tảng và Hạ tầng chung

* `config/app_env.dart`: Khai báo và quản lý các biến môi trường.
* `storage/secure_storage.dart`: Lớp bao bọc (wrapper) `flutter_secure_storage` để lưu/đọc/xoá Access Token an toàn.
* `network/dio_client.dart`: Khởi tạo và cấu hình `Dio` cho các request API.
* `network/interceptors/auth_interceptor.dart`: Tự động đính kèm Access Token vào header `Authorization` cho mọi request.
* `network/interceptors/refresh_interceptor.dart`: Tự động xử lý logic làm mới token khi gặp lỗi `401`.

### `services/auth/` – Module nghiệp vụ Xác thực

* **`data/`**
    * `models/user_dto.dart`: Model cho dữ liệu người dùng.
    * `models/res_login_dto.dart`: Model cho phản hồi từ API login/refresh.
    * `datasources/auth_api.dart`: Giao tiếp trực tiếp với các REST API liên quan đến xác thực.
* **`domain/`**
    * `auth_repository.dart`: Đóng gói logic nghiệp vụ, là cầu nối giữa tầng ứng dụng và dữ liệu.
* **`application/`**
    * `auth_controller.dart`: `ChangeNotifier` quản lý state xác thực (trạng thái đăng nhập, thông tin user) cho UI.

### `screens/` – Giao diện người dùng (UI)

* `auth/auth_gate.dart`: "Cổng" kiểm tra trạng thái đăng nhập để quyết định hiển thị `LoginScreen` hay `HomeScreen`.
* `auth/login/login_screen.dart`: Màn hình chứa form đăng nhập.
* `auth/register/register_screen.dart`: Màn hình đăng ký bước 1 (email, mật khẩu).
* `auth/register/create_username_screen.dart`: Màn hình đăng ký bước 2 (nhập Full Name).
* `home/home_screen.dart`: Màn hình chính sau khi đăng nhập thành công.

### `main.dart` - Điểm khởi đầu ứng dụng

* **Khởi tạo**: Khởi tạo các services cốt lõi (`SecureStorage`, `DioClient`, `AuthApi`, `AuthRepository`).
* **Dependency Injection**: Cung cấp `AuthController` cho toàn bộ ứng dụng bằng `Provider`.
* **Routing**: Thiết lập các route được đặt tên (`/home`, `/login`) và `onGenerateRoute` để xử lý các route động (`/create-username`).
* **Màn hình gốc**: `AuthGate` được đặt làm màn hình khởi đầu để quản lý luồng điều hướng.
