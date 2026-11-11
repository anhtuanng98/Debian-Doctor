# Ổ đĩa ngoài (USB) trong fstab: các mục có thể làm treo hoặc không khởi động được.
# Ổ USB không có "nofail" sẽ khiến Debian dừng khi khởi động nếu ổ không được cắm.
run_check() {
    local out="$1"; local log="$out/08-mounts.log"
    local risky=0 usb_missing=0 failed_mounts docker_binds=0
    local line dev mnt opts

    {
        echo "## fstab (mục không phải tmpfs/proc/sys)"
        grep -vE '^\s*(#|$)' /etc/fstab | awk '$2 != "none"' || true
        echo; echo "## Mục fstab có khả năng làm treo khởi động (không có nofail)"
        while read -r dev mnt _ opts _; do
            [[ "$dev" == \#* || -z "$mnt" ]] && continue
            case "$mnt" in /|/boot|/boot/efi|swap|none) continue ;; esac
            if [[ "$opts" != *nofail* ]]; then
                echo "$dev -> $mnt  [$opts]"; risky=$((risky+1))
            fi
        done < /etc/fstab
        echo; echo "## Ổ USB/rời đang kết nối"
        lsblk -o NAME,SIZE,TRAN,MOUNTPOINTS,RM 2>/dev/null | grep -E 'usb|1$' || echo "không có"
        echo; echo "## Đơn vị mount systemd bị lỗi"
        failed_mounts="$(systemctl --failed --no-legend --type=mount 2>/dev/null | wc -l)"
        systemctl --failed --no-pager --type=mount 2>/dev/null || true
        echo; echo "## Container Docker có bind mount nằm ngoài / (ổ đĩa ngoài)"
        if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
            docker ps -a --format '{{.Names}}' | while read -r c; do
                docker inspect -f '{{.Name}}: {{range .Mounts}}{{if eq .Type "bind"}}{{.Source}} {{end}}{{end}}' "$c" 2>/dev/null
            done | grep -E ': .*/(media|mnt|srv|data|run/media)/' || echo "không có"
        else echo "docker không chạy hoặc chưa cài"; fi
    } > "$log" 2>&1

    docker_binds="$(sed -n '/Container Docker/,$p' "$log" | grep -c ': ' || true)"
    if (( risky > 0 )) || (( failed_mounts > 0 )); then
        record mounts FAIL "$risky mục fstab không có nofail, $failed_mounts mount lỗi; có thể treo khi khởi động"
    elif (( docker_binds > 0 )); then
        record mounts WARN "Container Docker bind-mount vào ổ ngoài; nếu ổ mất sẽ ghi vào / (xem log)"
    else record mounts OK "fstab an toàn với ổ ngoài"; fi
}
