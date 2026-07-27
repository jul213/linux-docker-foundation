#!/bin/bash
# system-monitor.sh — Monitor de recursos con alertas

THRESHOLD_CPU=80
THRESHOLD_MEM=80
THRESHOLD_DISK=90

log_with_timestamp() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

check_cpu() {
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
    CPU_INT=${CPU_USAGE%.*}
    log_with_timestamp "CPU: ${CPU_USAGE}%"
    if [ "${CPU_INT:-0}" -ge "$THRESHOLD_CPU" ]; then
        log_with_timestamp "ALERTA: CPU supera ${THRESHOLD_CPU}%"
    fi
}

check_memory() {
    MEM_USAGE=$(free | grep Mem | awk '{printf("%.0f", $3/$2 * 100.0)}')
    log_with_timestamp "MEMORIA: ${MEM_USAGE}%"
    if [ "${MEM_USAGE:-0}" -ge "$THRESHOLD_MEM" ]; then
        log_with_timestamp "ALERTA: Memoria supera ${THRESHOLD_MEM}%"
    fi
}

check_disk() {
    DISK_USAGE=$(df -h / | tail -1 | awk '{print $5}' | sed 's/%//')
    log_with_timestamp "DISCO: ${DISK_USAGE}%"
    if [ "${DISK_USAGE:-0}" -ge "$THRESHOLD_DISK" ]; then
        log_with_timestamp "ALERTA: Disco supera ${THRESHOLD_DISK}%"
    fi
}

check_network() {
    INTERFACE=$(ip route | grep default | awk '{print $5}' | head -n1)
    RX=$(cat /sys/class/net/$INTERFACE/statistics/rx_bytes 2>/dev/null || echo 0)
    TX=$(cat /sys/class/net/$INTERFACE/statistics/tx_bytes 2>/dev/null || echo 0)
    log_with_timestamp "RED: RX=${RX} bytes, TX=${TX} bytes"
}

main() {
    log_with_timestamp "=== INICIO MONITORIZACION ==="
    check_cpu
    check_memory
    check_disk
    check_network
    log_with_timestamp "=== FIN MONITORIZACION ==="
}

main
