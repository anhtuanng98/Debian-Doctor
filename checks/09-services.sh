# Dịch vụ của máy chủ: Docker (OwnCloud, Home Assistant), Homebridge, CUPS.
run_check() {
    local out="$1"; local log="$out/09-services.log" bad=0 svc st
    local services="docker cups homebridge"
    {
        for svc in $services; do
            st="$(systemctl is-active "$svc" 2>/dev/null)"
            echo "$svc: ${st:-không cài}"
            [[ "$st" == "failed" ]] && bad=$((bad+1))
        done
        echo; echo "## Container Docker không ở trạng thái running hoặc unhealthy"
        if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
            docker ps -a --format '{{.Names}}\t{{.Status}}' | grep -vE '\tUp .*\(healthy\)|\tUp [^(]*$' || echo "tất cả đều chạy"
        else echo "docker không chạy"; fi
    } > "$log" 2>&1

    if grep -v '^##' "$log" | grep -qE ': failed|exited|Restarting|unhealthy|Dead'; then
        record services WARN "Có dịch vụ hoặc container lỗi/dừng, xem log"
    else record services OK "Các dịch vụ đang chạy"; fi
}
