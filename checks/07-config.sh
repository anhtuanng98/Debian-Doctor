# Cấu hình hệ thống: fstab, thời gian, cập nhật tự động.
run_check() {
    local out="$1"; local log="$out/07-config.log" sync
    {
        echo "## findmnt --verify (fstab)"; findmnt --verify --verbose 2>&1 || true
        echo; echo "## Đồng bộ thời gian"; timedatectl status 2>&1 || true
        echo; echo "## Cập nhật tự động"; systemctl is-enabled unattended-upgrades 2>&1 || true
        echo; echo "## Gói giữ phiên bản (hold)"; apt-mark showhold 2>&1 || true
    } > "$log" 2>&1
    sync="$(timedatectl show -p NTPSynchronized --value 2>/dev/null)"
    if ! findmnt --verify >/dev/null 2>&1; then record config WARN "fstab có lỗi hoặc cảnh báo, xem log"
    elif [[ "$sync" == "no" ]]; then record config WARN "Thời gian chưa đồng bộ NTP"
    else record config OK "fstab ổn; thời gian: ${sync:-không xác định}"; fi
}
