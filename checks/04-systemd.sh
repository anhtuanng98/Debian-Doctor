# Dịch vụ systemd bị lỗi.
run_check() {
    local out="$1"; local log="$out/04-systemd.log" state failed
    state="$(systemctl is-system-running 2>/dev/null)"
    failed="$(systemctl --failed --no-legend --plain 2>/dev/null | wc -l)"
    {
        echo "## Trạng thái hệ thống: $state"
        echo; echo "## Đơn vị lỗi"; systemctl --failed --no-pager || true
        echo; echo "## Đơn vị đang chờ/khởi động lại liên tục"
        systemctl list-units --state=activating,auto-restart --no-pager --no-legend || true
    } > "$log" 2>&1

    if (( failed > 0 )); then record systemd FAIL "$failed đơn vị bị lỗi"
    elif [[ "$state" != "running" ]]; then record systemd WARN "Hệ thống: $state"
    else record systemd OK "Không có dịch vụ lỗi"; fi
}
