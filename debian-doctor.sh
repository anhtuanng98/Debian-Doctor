#!/usr/bin/env bash
# debian-doctor: quét lỗi hệ thống Debian (chỉ đọc, không thay đổi gì).
# Kết quả ghi vào reports/<thời-gian>/ gồm summary.md và từng file kiểm tra.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAMP="$(date +%Y%m%d-%H%M%S)"
OUT="${DOCTOR_OUT:-$ROOT/reports/$STAMP}"
mkdir -p "$OUT"

# shellcheck source=checks/lib.sh
. "$ROOT/checks/lib.sh"

if [[ $EUID -ne 0 ]]; then
    echo "Gợi ý: chạy bằng sudo để có đủ quyền đọc log và dpkg." >&2
fi

for check in "$ROOT"/checks/[0-9]*.sh; do
    name="$(basename "$check" .sh)"
    echo "==> $name"
    # shellcheck source=/dev/null
    . "$check"
    OUT_DIR="$OUT"; touch "$OUT/status.tsv"; run_check "$OUT"
done

write_summary "$OUT"
echo
echo "Xong. Báo cáo: $OUT/summary.md"
