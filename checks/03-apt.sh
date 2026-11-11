# Phụ thuộc hỏng và nguồn apt (chỉ mô phỏng, không cài gì).
run_check() {
    local out="$1"; local log="$out/03-apt.log" sim
    {
        echo "## Nguồn apt"; grep -rhv '^\s*#' /etc/apt/sources.list /etc/apt/sources.list.d/ 2>/dev/null | grep -v '^\s*$' || echo "(trống)"
        echo; echo "## apt-get check"; apt-get check 2>&1 || true
        echo; echo "## Mô phỏng sửa phụ thuộc (không thay đổi hệ thống)"
        apt-get -s -f install 2>&1 || true
        echo; echo "## Gói có thể gỡ (autoremove, mô phỏng)"
        apt-get -s autoremove 2>&1 | grep -E '^Remv' | head -n 100 || true
    } > "$log" 2>&1

    sim="$(apt-get -s -f install 2>&1)"
    if ! apt-get check >/dev/null 2>&1; then record apt FAIL "apt-get check lỗi, xem log"
    elif grep -qiE 'unmet|broken|E:' <<<"$sim"; then record apt FAIL "Có phụ thuộc hỏng, xem log"
    elif grep -qiE 'obsolete|deprecated|Signed-By|NO_PUBKEY|W:' "$log"; then record apt WARN "Có cảnh báo nguồn/khóa apt"
    else record apt OK "apt không có lỗi phụ thuộc"; fi
}
