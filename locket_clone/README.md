# Luồng xác thực
### Login: 
UI gọi AuthController.login(email, password).
AuthRepository.login() → AuthApi.login() → nhận AT (body) + RT (cookie).
Lưu AT (secure storage) → gọi /auth/account → cập nhật user → điều hướng /home.

### Register:
RegisterScreen nhập email/password → chuyển CreateUsernameScreen.
CreateUsernameScreen nhập Full Name → gọi registerThenLogin():
AuthApi.register() → thành công thực hiện AuthRepository.login() như trên → /home.

### Khi AT hết hạn:
Nếu API trả 401: RefreshInterceptor gọi /auth/refresh (cookie RT) → lưu AT mới → retry request gốc.

### Logout:
AuthApi.logout() → server revoke RT + clear cookie,
Xoá AT (secure storage) → về /login.

# Cấu trúc dự án
### core/ Hạ tầng chung
config/app_env.dart -> Khai báo cấu hình môi trường
storage/secure_storage.dart -> Bao bọc flutter_secure_storage để lưu/đọc/xoá Access Token
network/dio_client.dart -> Khởi tạo Dio
network/interceptors/auth_interceptor.dart -> Đọc Access Token từ SecureStorage và gắn vào header Authorization cho tất cả request.
network/interceptors/refresh_interceptor.dart -> Tự động refresh khi 401

### services/auth/ – Tầng nghiệp vụ xác thực
data/models/user_dto.dart -> Model UserDTO
data/models/res_login_dto.dart -> Model phản hồi login/refresh
data/datasources/auth_api.dart -> Giao tiếp với REST API
domain/auth_repository.dart -> Đóng gói nghiệp vụ
application/auth_controller.dart -> ChangeNotifier quản lý state xác thực cho UI

### screens/ – Giao diện người dùng
auth/auth_gate.dart -> Cổng xác thực
auth/login/login_screen.dart -> Form đăng nhập (email/password)
auth/register/register_screen.dart -> Form đăng ký (email/password)
auth/register/create_username_screen.dart -> Nhận email/password từ bước trước, nhập Full Name + Username
home/home_screen.dart -> Màn hình chính

### main.dart
Khởi tạo (SecureStorage, DioClient, AuthApi, AuthRepository, AuthController),
Cấp phát AuthController bằng Provider,
Thiết lập named routes (/home, /login, /register) và onGenerateRoute cho /create-username,
Màn hình gốc: AuthGate.