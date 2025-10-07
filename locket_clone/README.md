# Luồng hoạt động - RestAPI

### Login: 
Backend trả accessToken trong body + set cookie refresh_token (httpOnly).
→ FE lưu AT vào SecureStorage.
→ Cookie RT do CookieManager (mobile/desktop) hoặc trình duyệt (web) giữ.
Mọi request bảo vệ (vd: /auth/account) được AuthInterceptor tự gắn Authorization: Bearer <AT>.

### Khi AT hết hạn:
Server trả 401.
RefreshInterceptor chặn 401 → gọi POST /auth/refresh (gửi RT cookie tự động) → nhận AT mới, lưu lại → retry request cũ.

### Dev qua HTTP:
Nếu backend set Secure cho cookie RT, nhiều client sẽ không gửi cookie trên HTTP (đúng chuẩn).
→ Tốt nhất dev bằng HTTPS hoặc tắt Secure chỉ trong môi trường dev.