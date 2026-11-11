# debian-doctor

Công cụ quét lỗi hệ thống Debian. Chỉ đọc, không thay đổi cấu hình hay gỡ/cài gói.

## Cách dùng

```bash
sudo ./debian-doctor.sh
```

Kết quả nằm ở `reports/<thời-gian>/`:
- `summary.md`: bảng tổng hợp OK / CẢNH BÁO / LỖI
- `0N-*.log`: chi tiết từng bước

## Các bước kiểm tra

| Bước | Nội dung |
|---|---|
| 01-system | OS, dung lượng, inode, mount chỉ đọc, cờ cần khởi động lại |
| 02-dpkg | Gói lỗi, gói dở dang, file bị thay đổi |
| 03-apt | Nguồn apt, phụ thuộc hỏng (mô phỏng), gói có thể gỡ |
| 04-systemd | Đơn vị systemd bị lỗi |
| 05-journal | Lỗi mức err trong nhật ký lần khởi động này |
| 06-kernel | Lỗi kernel, I/O và hệ thống tệp |
| 07-config | fstab, đồng bộ thời gian, cập nhật tự động, gói hold |
| 08-mounts | Mục fstab có thể làm treo khởi động (ổ USB không có `nofail`), mount lỗi, container Docker bind-mount vào ổ ngoài |
| 09-services | Docker, CUPS, Homebridge, container OwnCloud/Home Assistant |

## Thêm kiểm tra

Tạo file `checks/NN-ten.sh` có hàm `run_check "$out"`. Dùng `record <tên> <OK|WARN|FAIL> "<ghi chú>"` để ghi kết quả. File được chạy theo thứ tự tên.

## Sửa lỗi

Script không tự sửa. Sau khi quét, gửi `summary.md` và các log liên quan để xác định nguyên nhân và cách sửa.

## Lưu ý về ổ USB rời

Nếu máy khởi động treo khi ổ USB không được cắm, nguyên nhân thường là một dòng trong `/etc/fstab` thiếu tùy chọn `nofail`. Ví dụ đúng:

```
UUID=xxxx  /mnt/usb  ext4  defaults,nofail,x-systemd.device-timeout=10s  0  2
```

- `nofail`: Debian vẫn khởi động nếu ổ không có.
- `x-systemd.device-timeout=10s`: chỉ chờ tối đa 10 giây.

Lấy UUID bằng `lsblk -f`. Nên dùng UUID thay vì `/dev/sdX`, vì tên thiết bị có thể đổi khi cắm lại.

Container Docker bind-mount vào thư mục của ổ ngoài là rủi ro khác: nếu ổ mất, Docker vẫn tạo thư mục rỗng trên ổ hệ thống và ghi dữ liệu vào đó. Bước 08 sẽ cảnh báo trường hợp này.

Bước 08 không sửa fstab. Hãy sửa thủ công sau khi đọc kết quả.

## Cài trên Debian 13 (trixie)

```bash
sudo apt update
sudo apt install -y git util-linux systemd
git clone git@github.com:anhtuanng98/debian-doctor.git   # hoặc https://github.com/anhtuanng98/debian-doctor.git
cd debian-doctor
chmod +x debian-doctor.sh checks/*.sh
sudo ./debian-doctor.sh
```

Docker, CUPS và Homebridge là tùy chọn. Bước nào không tìm thấy công cụ sẽ ghi "không cài" và không gây lỗi.

Để chạy lại định kỳ, có thể thêm vào crontab của root (`sudo crontab -e`):

```
0 6 * * 1 /home/<user>/debian-doctor/debian-doctor.sh >/dev/null 2>&1
```
