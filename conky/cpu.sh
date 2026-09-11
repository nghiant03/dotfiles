#!/bin/bash
# cpu.sh - per-core CPU usage grid for conky, right-aligned.
#
# Core count is detected from /proc/stat and utilization is computed
# directly from two samples (like gpu.sh does for GPUs), so the values
# are known up front and can be padded to fixed-width fields. Rendered
# in a monospace font, the padded fields form aligned columns and
# ${alignr} makes the whole block flush right - no pixel positions.
#
# NOTE: the monospace ${font} must come BEFORE ${alignr}. If the font
# change sits inside the text that follows ${alignr}, conky measures
# its width with the wrong font and the block lands short of the edge.
#
# The output is conky markup, meant for ${execpi 1 .../cpu.sh} (execp
# parses the output as conky text).
#
# Usage: cpu.sh [columns per row]

set -u
COLS="${1:-4}"

read_stats() {
  # total = user+nice+system+idle+iowait+irq+softirq, plus idle, per core
  grep '^cpu[0-9]' /proc/stat | awk '{print $2+$3+$4+$5+$6+$7+$8, $5}'
}

prev_total=()
prev_idle=()
while read -r total idle; do
  prev_total+=("$total")
  prev_idle+=("$idle")
done < <(read_stats)

sleep 0.2

pct=()
i=0
while read -r total idle; do
  dt=$((total - prev_total[i]))
  di=$((idle - prev_idle[i]))
  [ "$dt" -gt 0 ] && pct+=($(((100 * (dt - di) + dt / 2) / dt))) || pct+=(0)
  i=$((i + 1))
done < <(read_stats)

cores=$i
[ "$cores" -eq 0 ] && exit 0

for ((first = 0; first < cores; first += COLS)); do
  last=$((first + COLS - 1))
  [ "$last" -ge "$cores" ] && last=$((cores - 1))
  printf '${font :size=9}%02d - %02d:${font monospace:size=9}${alignr}${color2}' \
    $((first + 1)) $((last + 1))
  for ((n = first; n <= last; n++)); do
    printf '%3d%%' "${pct[n]}"          # right-aligned 4-char field, e.g. "  5%"
    [ "$n" -lt "$last" ] && printf '  ' # column gap
  done
  printf '${color}${font}\n'
done
