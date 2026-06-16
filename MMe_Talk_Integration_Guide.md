# Hướng dẫn Tích hợp Đa kênh cho MMe Talk

Tài liệu này hướng dẫn cách cấu hình các kết nối từ bên thứ ba (Facebook, Google, TikTok) vào máy chủ MMe Talk. Việc cài đặt này được thực hiện một lần duy nhất tại trang **Super Admin**.

---

## 🌟 Lợi ích: Khách hàng (User) của bạn sẽ được gì?

Khi bạn thiết lập thành công các tích hợp này ở cấp độ hệ thống, những công ty/khách hàng thuê phần mềm MMe Talk của bạn sẽ nhận được các đặc quyền sau:

1. **Với Facebook, Instagram & TikTok (Kênh CSKH Tích hợp):**
   - **Gom tất cả về một mối:** Khách của họ không cần phải cho nhân viên trực fanpage mật khẩu Facebook hay TikTok nữa. Chủ shop chỉ cần bấm nút "Kết nối" trên MMe Talk.
   - Khi có người bình luận, nhắn tin trên Fanpage hoặc TikTok Shop, tin nhắn sẽ tự động "đổ" về màn hình làm việc của MMe Talk. Nhân viên gõ trả lời trên MMe Talk, khách sẽ nhận được tin nhắn trên ứng dụng Facebook/TikTok của họ.
   - Tính bảo mật cực cao, tránh thất thoát dữ liệu và dễ dàng thống kê hiệu suất nhân viên.

2. **Với Google OAuth (Trải nghiệm Đăng nhập):**
   - Nhân viên của công ty không cần phải đau đầu nhớ tên đăng nhập hay mật khẩu.
   - Chỉ cần 1 Click chuột vào nút **"Đăng nhập bằng Google"**, hệ thống sẽ tự động xác thực và cho phép họ vào làm việc ngay lập tức. An toàn, chống hack và cực kỳ chuyên nghiệp.

---

## 1. Tích hợp Facebook & Instagram

Để tích hợp, bạn cần tạo một Ứng dụng trung gian trên Facebook.

**Bước 1: Tạo App Facebook**
1. Truy cập [Facebook Developers](https://developers.facebook.com/) và đăng nhập.
2. Bấm **My Apps** -> **Create App**.
3. Chọn loại ứng dụng là **Business (Doanh nghiệp)**. Đặt tên (VD: MMe Talk Hub).

**Bước 2: Lấy thông số (ID & Secret)**
1. Vào **App Settings -> Basic**.
2. Copy **App ID** và **App Secret** dán vào ô tương ứng trong MMe Talk.

**Bước 3: Đặt Token Nhận dạng (Verify Token)**
- **Facebook / Instagram Verify Token:** Tự nghĩ ra một đoạn mật khẩu bất kỳ (VD: `mmetalk_secret_2026`) và dán vào 2 ô này trên MMe Talk. Cất mật khẩu này để dùng cho bước sau.

**Bước 4: Trỏ Webhook nhận tin nhắn**
1. Trong màn hình Facebook Developers, chọn **Messenger -> Set up**.
2. Cuộn xuống phần **Webhooks**, bấm **Add Callback URL**.
3. **Callback URL:** Điền `https://talk.mme.vn/webhooks/facebook`
4. **Verify Token:** Điền đoạn mật khẩu `mmetalk_secret_2026` ở Bước 3.
5. Đăng ký các sự kiện (Subscriptions): `messages`, `messaging_postbacks`, `messaging_optins`, `message_deliveries`.

**Bước 5: Cấu hình phụ**
- **API Version:** Nhập `v18.0` (Hoặc version hiển thị trên màn hình FB Developer).
- **Enable human agent:** Đánh dấu `True` để bypass giới hạn trả lời tin nhắn 24h của Facebook.

---

## 2. Tích hợp Đăng nhập bằng Google (Google OAuth)

Để hiển thị nút đăng nhập Google, bạn cần tạo thông tin xác thực trên Google Cloud.

**Bước 1: Tạo dự án trên Google Cloud**
1. Truy cập [Google Cloud Console](https://console.cloud.google.com/).
2. Tạo một Project mới (VD: MMe Talk SSO).

**Bước 2: Tạo màn hình Đồng ý (OAuth consent screen)**
1. Tìm menu **APIs & Services** -> Chọn **OAuth consent screen**.
2. Chọn loại **External**, điền Tên hệ thống (MMe Talk), Email hỗ trợ và Lưu lại.

**Bước 3: Lấy Client ID & Secret**
1. Chuyển sang menu **Credentials** -> Bấm **Create Credentials** -> Chọn **OAuth client ID**.
2. Application type: Chọn **Web application**.
3. **Authorized redirect URIs (Cực kỳ quan trọng):** Thêm đường dẫn này vào:
   `https://talk.mme.vn/omniauth/google_oauth2/callback`
4. Bấm Tạo. Bảng thông báo sẽ hiện ra cung cấp **Client ID** và **Client Secret**. Bạn hãy Copy 2 thông số này dán vào màn hình MMe Talk.

**Bước 4: Hoàn thiện trên MMe Talk**
- **Google OAuth Redirect URI:** Dán link `https://talk.mme.vn/omniauth/google_oauth2/callback` vào đây.
- **Enable Google OAuth login:** Đánh dấu `True`.

---

## 3. Tích hợp TikTok

Tương tự như Facebook, để nhận tin nhắn từ TikTok Shop/Tiktok Account, bạn phải tạo ứng dụng trên cổng lập trình viên của TikTok.

**Bước 1: Đăng ký TikTok cho Nhà phát triển**
1. Truy cập [TikTok Developer Portal](https://developers.tiktok.com/) và đăng nhập.
2. Tạo một Ứng dụng mới (Create App).

**Bước 2: Lấy thông số (ID & Secret)**
1. Khi tạo ứng dụng xong, TikTok sẽ cung cấp cho bạn **Client Key** (đóng vai trò là App ID) và **Client Secret**.
2. Copy chúng và dán vào ô **TikTok App ID** và **TikTok App Secret** trên MMe Talk.

**Bước 3: Cấu hình Webhook & API Version**
- **API Version:** Hiện tại điền `v1.3` (Hoặc version mới nhất mà TikTok đang cung cấp trên trang chủ của họ, ví dụ `v2`).
- Ở giao diện TikTok Developer, bạn cũng cần thêm URL Webhook là `https://talk.mme.vn/webhooks/tiktok` để máy chủ TikTok biết chỗ mà ném tin nhắn về khi có khách hàng chat.

---
*Lưu ý: Mọi thay đổi trong phần Super Admin đôi khi yêu cầu máy chủ phải được khởi động lại để áp dụng. Trên Dokploy, bạn chỉ việc bấm nút "Restart" của Container `mmetalk-web`.*
