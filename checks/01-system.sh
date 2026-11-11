# Thông tin máy, dung lượng, mount chỉ đọc, cần khởi động lại.
run_check() {
    local out="$1"; local log="$out/01-system.log"; local pct
    {
        echo "## OS / kernel"; (. /etc/os-release && echo "$PRETTY_NAME"); uname -a
        echo; echo "## Uptime"; uptime
        echo; echo "## Dung lượng đĩa"; df -hT -x tmpfs -x devtmpfs -x squashfs
        echo; echo "## Inode"; df -i -x tmpfs -x devtmpfs -x squashfs
        echo; echo "## Mount chỉ đọc"; findmnt -rno TARGET,OPTIONS | grep -E '(^| )ro(,|$)' || echo "không có"
        echo; echo "## Cần khởi động lại?"
        if [[ -f /var/run/reboot-required ]]; then cat /var/run/reboot-required; cat /var/run/reboot-required.pkgs 2>/dev/null
        else echo "không"; fi
    } > "$log" 2>&1

    local full=0 bad_inode=0 root_ro=0
    while read -r pct; do
        (( ${pct%\%} >= 95 )) && full=1
    done < <(df --output=pcent -x tmpfs -x devtmpfs -x squashfs | tail -n +2)
    while read -r pct; do
        [[ "$pct" == "-" ]] && continue
        (( ${pct%\%} >= 95 )) && bad_inode=1
    done < <(df --output=ipcent -x tmpfs -x devtmpfs -x squashfs | tail -n +2)
    findmnt -rno OPTIONS / | tr ',' '\n' | grep -qx ro && root_ro=1

    if (( full )); then record system FAIL "Có phân vùng dùng ≥95% dung lượng"
    elif (( root_ro )); then record system FAIL "Phân vùng gốc / đang chỉ đọc (có thể do lỗi đĩa)"
    elif (( bad_inode )); then record system WARN "Có phân vùng dùng ≥95% inode"
    else record system OK "Dung lượng và mount gốc bình thường"; fi
}
