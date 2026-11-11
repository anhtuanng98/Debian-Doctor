# Trạng thái gói dpkg: lỗi cài đặt, thiếu file, gói dở dang.
run_check() {
    local out="$1"; local log="$out/02-dpkg.log"
    {
        echo "## dpkg --audit (gói lỗi/dở dang)"; dpkg --audit || true
        echo; echo "## dpkg -C (kiểm tra tổng thể)"; dpkg -C || true
        echo; echo "## Gói ở trạng thái không bình thường"
        dpkg -l | awk 'NR>5 && $1 !~ /^ii|^rc/ {print}' || true
        echo; echo "## Gói bị hỏng (thiếu file cấu hình)"
        dpkg -V 2>/dev/null | head -n 200 || true
    } > "$log" 2>&1

    if [[ -s "$log" ]] && grep -q '^## dpkg --audit' "$log" && [[ -z "$(dpkg --audit 2>/dev/null)" ]] \
       && [[ -z "$(dpkg -l | awk 'NR>5 && $1 !~ /^ii|^rc/')" ]]; then
        record dpkg OK "Không có gói lỗi"
    elif [[ -n "$(dpkg --audit 2>/dev/null)" ]]; then
        record dpkg FAIL "dpkg --audit báo gói lỗi, xem log"
    else
        record dpkg WARN "Có gói ở trạng thái không bình thường, xem log"
    fi
}
