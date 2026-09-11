#!/usr/bin/env bash
# gpu.sh - GPU status helper for conky.
# Detects iGPU / dGPU / eGPU on a laptop and exposes single-line metrics
# for conky's ${execi}. The discrete/eGPU is only polled (nvidia-smi /
# sysfs) when its PCI runtime PM status is "active"; a suspended or
# unbound GPU is never touched, so polling can never wake it up.

set -u

CACHE_DIR="${GPU_CACHE_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/conky-gpu}"
DETECT_TTL=30      # seconds the detection cache is valid
METRIC_TTL=1       # seconds the dGPU/eGPU metrics cache is valid
SMI_TIMEOUT=3      # max seconds to wait for nvidia-smi

mkdir -p "$CACHE_DIR" 2>/dev/null

usage() {
    cat <<'EOF'
Usage: gpu.sh [COMMAND] [FIELD]
  (none) | status   print a full GPU status summary
  detect            force re-detection of GPU roles, then print summary
  igpu FIELD        name | util | freq | freq_max | temp
  dgpu FIELD        state | name | util | temp | vram | power
  egpu FIELD        state | name | util | temp | vram | power

state is one of: active | idle | sleeping | off | absent
  active   in use by a client (metrics are polled)
  idle     awake but no clients hold it; left alone so it can sleep
  sleeping runtime-suspended; never polled, so it stays asleep
Metrics print the state word instead of numbers whenever polling the
GPU would wake it (idle/sleeping) or is impossible (off/absent).
EOF
}

is_laptop() {
    local t
    t=$(cat /sys/class/dmi/id/chassis_type 2>/dev/null) || return 1
    case $t in 8|9|10|11|14) return 0 ;; *) return 1 ;; esac
}

# True if the PCI device sits behind a Thunderbolt/USB4 controller.
tb_ancestor() {
    local d
    d=$(readlink -f "$1" 2>/dev/null) || return 1
    while [ "$d" != "/sys" ] && [ "$d" != "/" ]; do
        [ -d "$d/thunderbolt" ] && return 0
        d=${d%/*}
    done
    return 1
}

# Short human-readable GPU name from lspci output.
pci_short_name() {
    local raw inner
    raw=$(lspci -s "$1" 2>/dev/null | sed -n 's/^[0-9a-f:.]* [^:]*: //p')
    [ -n "$raw" ] || { echo "GPU $1"; return; }
    raw=${raw//\"/}
    raw=$(printf '%s' "$raw" \
        | sed -e 's/ *(rev[^)]*) *$//' \
              -e 's/^NVIDIA Corporation *//' \
              -e 's/^Intel Corporation *//' \
              -e 's/^Advanced Micro Devices, Inc\. *//' \
              -e 's/^ATI Technologies Inc *//')
    inner=$(printf '%s' "$raw" | sed -n 's/.*\[\([^]]*\)\].*/\1/p')
    [ -n "$inner" ] && raw=$inner
    printf '%s' "$raw" \
        | sed -e 's/ *\/ *Mobile.*$//' \
              -e 's/ *\/ *Laptop.*$//' \
              -e 's/ Max-Q.*//' \
              -e 's/ Mobile.*//' \
              -e 's/ Laptop.*//' \
              -e 's/ *Integrated Graphics Controller.*//'
}

run_detect() {
    local dev addr class vendor bv driver card role name laptop
    local i_addr='' i_card='' i_name='' i_drv=''
    local d_addr='' d_card='' d_name='' d_drv=''
    local e_addr='' e_card='' e_name='' e_drv=''

    if is_laptop; then laptop=1; else laptop=0; fi

    for dev in /sys/bus/pci/devices/*; do
        class=$(cat "$dev/class" 2>/dev/null) || continue
        case $class in 0x0300*|0x0302*) ;; *) continue ;; esac
        addr=${dev##*/}
        vendor=$(cat "$dev/vendor" 2>/dev/null)
        driver=$(basename "$(readlink "$dev/driver" 2>/dev/null)" 2>/dev/null)
        bv=$(cat "$dev/boot_vga" 2>/dev/null)
        card=$(ls "$dev/drm" 2>/dev/null | grep -m1 -o '^card[0-9]*$')
        role=''
        if tb_ancestor "$dev"; then role=egpu
        elif [ "$vendor" = "0x8086" ]; then role=igpu
        elif [ "$vendor" = "0x1002" ] && [ "$bv" = "1" ] && [ "$laptop" = 1 ]; then role=igpu
        elif [ "$vendor" = "0x1002" ]; then role=dgpu
        elif [ "$vendor" = "0x10de" ]; then role=dgpu
        else
            case $driver in
                i915) role=igpu ;;
                amdgpu|nvidia|nouveau) role=dgpu ;;
            esac
        fi
        [ -n "$role" ] || continue
        name=$(pci_short_name "$addr")
        case $role in
            igpu) [ -z "$i_addr" ] && { i_addr=$addr; i_card=$card; i_name=$name; i_drv=$driver; } ;;
            dgpu) [ -z "$d_addr" ] && { d_addr=$addr; d_card=$card; d_name=$name; d_drv=$driver; } ;;
            egpu) [ -z "$e_addr" ] && { e_addr=$addr; e_card=$card; e_name=$name; e_drv=$driver; } ;;
        esac
    done

    printf 'DETECTED_AT=%s\n' "$(date +%s)" > "$CACHE_DIR/detect.new"
    printf 'IGPU_ADDR="%s"\nIGPU_CARD="%s"\nIGPU_NAME="%s"\nIGPU_DRIVER="%s"\n' \
        "$i_addr" "$i_card" "$i_name" "$i_drv" >> "$CACHE_DIR/detect.new"
    printf 'DGPU_ADDR="%s"\nDGPU_CARD="%s"\nDGPU_NAME="%s"\nDGPU_DRIVER="%s"\n' \
        "$d_addr" "$d_card" "$d_name" "$d_drv" >> "$CACHE_DIR/detect.new"
    printf 'EGPU_ADDR="%s"\nEGPU_CARD="%s"\nEGPU_NAME="%s"\nEGPU_DRIVER="%s"\n' \
        "$e_addr" "$e_card" "$e_name" "$e_drv" >> "$CACHE_DIR/detect.new"
    mv -f "$CACHE_DIR/detect.new" "$CACHE_DIR/detect"
}

detect_fresh() {
    local ts a now
    [ -s "$CACHE_DIR/detect" ] || return 1
    ts=$(sed -n 's/^DETECTED_AT=//p' "$CACHE_DIR/detect")
    [ -n "$ts" ] || return 1
    now=$(date +%s)
    [ $((now - ts)) -le $DETECT_TTL ] || return 1
    . "$CACHE_DIR/detect"
    for a in "$IGPU_ADDR" "$DGPU_ADDR" "$EGPU_ADDR"; do
        if [ -n "$a" ] && [ ! -e "/sys/bus/pci/devices/$a" ]; then
            return 1
        fi
    done
    return 0
}

get_detect() {
    if detect_fresh; then return 0; fi
    (
        flock -x 9
        if ! detect_fresh; then
            run_detect
        fi
    ) 9>"$CACHE_DIR/detect.lock"
    . "$CACHE_DIR/detect"
}

# True if any process holds one of the GPU's /dev/nvidia* nodes open.
# Only RM clients keep the nvidia GPU awake: an open DRM node
# (/dev/dri/cardX, e.g. held by the Wayland compositor) does NOT
# block runtime suspend, so it must not count as a client.
nvidia_has_clients() {  # $1=addr
    local addr=$1 key cache ts now res
    key=$(printf '%s' "$addr" | tr -d ':.')
    cache="$CACHE_DIR/clients.$key"
    now=$(date +%s)
    if [ -s "$cache" ]; then
        ts=$(sed -n 's/^TS=//p' "$cache")
        res=$(sed -n 's/^RES=//p' "$cache")
        if [ -n "$ts" ] && [ -n "$res" ] && [ $((now - ts)) -le $METRIC_TTL ]; then
            [ "$res" = 1 ]
            return
        fi
    fi
    (
        flock -x 9
        res=$(sed -n 's/^RES=//p' "$cache" 2>/dev/null)
        ts=$(sed -n 's/^TS=//p' "$cache" 2>/dev/null)
        if [ -z "$res" ] || [ -z "$ts" ] || [ $(( $(date +%s) - ts )) -gt $METRIC_TTL ]; then
            local n hit=0
            shopt -s nullglob
            local -a paths=()
            for n in /dev/nvidia*; do
                paths+=("$n")
            done
            shopt -u nullglob
            if [ ${#paths[@]} -gt 0 ]; then
                if command -v fuser >/dev/null 2>&1; then
                    fuser -s "${paths[@]}" 2>/dev/null && hit=1
                else
                    for n in /proc/[0-9]*/fd/*; do
                        n=$(readlink "$n" 2>/dev/null) || continue
                        case $n in /dev/nvidia*) hit=1; break ;; esac
                    done
                fi
            fi
            printf 'TS=%s\nRES=%s\n' "$(date +%s)" "$hit" > "$cache.new"
            mv -f "$cache.new" "$cache"
            exit $((1 - hit))
        fi
        exit $(( res == 1 ? 0 : 1 ))
    ) 9>"$cache.lock"
}

# Power state of a discrete/eGPU without waking it: sysfs reads only.
gpu_state() {
    local addr=${1:-} drv=${2:-} st
    [ -n "$addr" ] || { echo absent; return; }
    [ -e "/sys/bus/pci/devices/$addr" ] || { echo absent; return; }
    case $drv in
        nvidia|amdgpu|nouveau) ;;
        *) echo off; return ;;
    esac
    st=$(cat "/sys/bus/pci/devices/$addr/power/runtime_status" 2>/dev/null)
    case $st in
        suspended|suspending|resuming) echo sleeping; return ;;
    esac
    if [ "$drv" = nvidia ] && ! nvidia_has_clients "$addr"; then
        echo idle
        return
    fi
    echo active
}

metrics_fresh() {
    local cache=$1 ts now
    [ -s "$cache" ] || return 1
    ts=$(sed -n 's/^TS=//p' "$cache")
    [ -n "$ts" ] || return 1
    now=$(date +%s)
    [ $((now - ts)) -le $METRIC_TTL ]
}

# One combined query per refresh; multiple conky execi calls in the same
# cycle reuse the cached result instead of re-invoking nvidia-smi.
refresh_metrics() {  # $1=role(dgpu|egpu) $2=addr $3=driver
    local role=$1 addr=$2 drv=$3 cache="$CACHE_DIR/metrics.$1"
    if metrics_fresh "$cache"; then return 0; fi
    (
        flock -x 9
        if ! metrics_fresh "$cache"; then
            local dev="/sys/bus/pci/devices/$addr" out v
            local util=- temp=- vram=- power=-
            case $drv in
            nvidia)
                out=$(timeout "$SMI_TIMEOUT" nvidia-smi -i "$addr" \
                      --query-gpu=utilization.gpu,temperature.gpu,memory.used,power.draw \
                      --format=csv,noheader,nounits 2>/dev/null | head -n1)
                if [ -n "$out" ]; then
                    util=$(awk -F',' '{gsub(/ /,"",$1); print $1}' <<<"$out")
                    temp=$(awk -F',' '{gsub(/ /,"",$2); print $2}' <<<"$out")
                    vram=$(awk -F',' '{gsub(/ /,"",$3); print $3}' <<<"$out")
                    power=$(awk -F',' '{gsub(/ /,"",$4); print $4}' <<<"$out")
                fi
                ;;
            amdgpu)
                util=$(cat "$dev/gpu_busy_percent" 2>/dev/null) || util=''
                v=$(cat "$dev"/hwmon*/temp1_input 2>/dev/null | head -n1) && temp=$((v/1000))
                v=$(cat "$dev/mem_info_vram_used" 2>/dev/null) && vram=$((v/1048576))
                v=$(cat "$dev"/hwmon*/power1_average 2>/dev/null | head -n1) && power=$((v/1000000))
                ;;
            esac
            case "$util"  in ''|*[!0-9]*) util=- ;; esac
            case "$temp"  in ''|*[!0-9.]*) temp=- ;; esac
            case "$vram"  in ''|*[!0-9.]*) vram=- ;; esac
            case "$power" in ''|*[!0-9.]*) power=- ;; esac
            printf 'TS=%s\nUTIL=%s\nTEMP=%s\nVRAM=%s\nPOWER=%s\n' \
                "$(date +%s)" "$util" "$temp" "$vram" "$power" > "$cache.new"
            mv -f "$cache.new" "$cache"
        fi
    ) 9>"$cache.lock"
}

role_metric() {  # $1=DGPU|EGPU  $2=field(util|temp|vram|power)
    local role=$1 field=${2^^} addr drv state cache v
    get_detect
    case $role in
        DGPU) addr=$DGPU_ADDR; drv=$DGPU_DRIVER ;;
        EGPU) addr=$EGPU_ADDR; drv=$EGPU_DRIVER ;;
    esac
    state=$(gpu_state "$addr" "$drv")
    case $state in
        absent)   echo "-"; return ;;
        off)      echo "off"; return ;;
        idle)     echo "idle"; return ;;
        sleeping) echo "sleeping"; return ;;
    esac
    case $drv in
        nvidia|amdgpu) ;;
        *) echo "-"; return ;;
    esac
    cache="$CACHE_DIR/metrics.${role,,}"
    refresh_metrics "${role,,}" "$addr" "$drv"
    v=$(sed -n "s/^$field=//p" "$cache" 2>/dev/null)
    case "${v:-}" in
        ''|*[!0-9.]*) echo "-"; return ;;
    esac
    case $field in
        UTIL)  echo "$v%" ;;
        TEMP)  echo "$v°C" ;;
        VRAM)  echo "${v}MiB" ;;
        POWER) echo "$(awk -v x="$v" 'BEGIN{printf "%.1f", x}')W" ;;
        *)     echo "-" ;;
    esac
}

igpu_metric() {  # $1=field
    local f=${1:-name} dev drm v
    get_detect
    if [ -z "$IGPU_ADDR" ]; then
        case $f in name) echo "none" ;; *) echo "-" ;; esac
        return
    fi
    dev="/sys/bus/pci/devices/$IGPU_ADDR"
    drm="/sys/class/drm/${IGPU_CARD:-}"
    case $f in
    name) echo "${IGPU_NAME:-unknown}" ;;
    util)
        v=$(cat "$dev/gpu_busy_percent" 2>/dev/null)
        case "$v" in ''|*[!0-9]*) echo "-" ;; *) echo "$v%" ;; esac
        ;;
    freq)
        v=$(cat "$drm/gt_cur_freq_mhz" 2>/dev/null)
        if [ -n "$v" ]; then echo "${v}MHz"; return; fi
        v=$(cat "$dev/freq1_input" 2>/dev/null | head -n1)
        case "$v" in ''|*[!0-9]*) echo "-" ;; *) echo "$((v/1000000))MHz" ;; esac
        ;;
    freq_max)
        v=$(cat "$drm/gt_max_freq_mhz" 2>/dev/null)
        if [ -n "$v" ]; then echo "${v}MHz"; return; fi
        echo "-"
        ;;
    temp)
        v=$(cat "$dev"/hwmon*/temp1_input 2>/dev/null | head -n1)
        case "$v" in ''|*[!0-9]*) echo "-" ;; *) echo "$((v/1000))°C" ;; esac
        ;;
    *) echo "-" ;;
    esac
}

discrete_cmd() {  # $1=DGPU|EGPU $2=field
    local field=${2:-state}
    case $field in
    state)
        get_detect
        case $1 in
            DGPU) gpu_state "$DGPU_ADDR" "$DGPU_DRIVER" ;;
            EGPU) gpu_state "$EGPU_ADDR" "$EGPU_DRIVER" ;;
        esac
        ;;
    name)
        get_detect
        case $1 in
            DGPU) echo "${DGPU_NAME:-none}" ;;
            EGPU) echo "${EGPU_NAME:-none}" ;;
        esac
        ;;
    util|temp|vram|power)
        role_metric "$1" "$field"
        ;;
    *)
        usage >&2
        exit 1
        ;;
    esac
}

print_status() {
    local s
    get_detect
    echo "iGPU : ${IGPU_NAME:-none}  [addr=${IGPU_ADDR:-n/a} card=${IGPU_CARD:-n/a} driver=${IGPU_DRIVER:-n/a}]"
    echo "       freq=$(igpu_metric freq)  temp=$(igpu_metric temp)"
    s=$(gpu_state "$DGPU_ADDR" "$DGPU_DRIVER")
    echo "dGPU : ${DGPU_NAME:-none}  [addr=${DGPU_ADDR:-n/a} card=${DGPU_CARD:-n/a} driver=${DGPU_DRIVER:-n/a}]  state=$s"
    if [ "$s" = active ]; then
        echo "       util=$(role_metric DGPU util) temp=$(role_metric DGPU temp) vram=$(role_metric DGPU vram) power=$(role_metric DGPU power)"
    fi
    s=$(gpu_state "$EGPU_ADDR" "$EGPU_DRIVER")
    echo "eGPU : ${EGPU_NAME:-none}  [addr=${EGPU_ADDR:-n/a} driver=${EGPU_DRIVER:-n/a}]  state=$s"
}

case ${1:-status} in
    status) print_status ;;
    detect)
        (
            flock -x 9
            run_detect
        ) 9>"$CACHE_DIR/detect.lock"
        print_status
        ;;
    igpu)  igpu_metric "${2:-name}" ;;
    dgpu)  discrete_cmd DGPU "${2:-state}" ;;
    egpu)  discrete_cmd EGPU "${2:-state}" ;;
    help|-h|--help) usage ;;
    *) usage >&2; exit 1 ;;
esac
