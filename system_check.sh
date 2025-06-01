#!/bin/bash
#===============================================================================
# System Check Script with Interactive Menu
# Comprehensive system analysis tool for Red Hat Linux
#===============================================================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'
BOLD='\033[1m'

# Output formatting functions
print_header() {
    clear
    echo -e "${BLUE}${BOLD}╔═══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}${BOLD}║${NC}${CYAN}${BOLD}                          SYSTEM CHECK UTILITY v2.0                            ${NC}${BLUE}${BOLD}║${NC}"
    echo -e "${BLUE}${BOLD}╚═══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo -e "${GREEN}Current Time: $(date '+%Y-%m-%d %H:%M:%S')${NC}\n"
}

print_section() {
    echo -e "\n${YELLOW}${BOLD}▶ $1${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

pause_screen() {
    echo -e "\n${CYAN}Press any key to continue...${NC}"
    read -n 1 -s
}

# 1. System Information
system_info() {
    print_header
    print_section "SYSTEM INFORMATION"
    
    echo -e "${GREEN}OS Release:${NC}"
    cat /etc/redhat-release
    
    echo -e "\n${GREEN}Kernel:${NC}"
    uname -r
    
    echo -e "\n${GREEN}Architecture:${NC}"
    uname -m
    
    echo -e "\n${GREEN}Hostname:${NC}"
    hostname -f
    
    echo -e "\n${GREEN}System Uptime:${NC}"
    uptime -p
    
    echo -e "\n${GREEN}Current Users:${NC}"
    who
    
    echo -e "\n${GREEN}System Load:${NC}"
    cat /proc/loadavg
    
    pause_screen
}

# 2. Hardware Information
hardware_info() {
    print_header
    print_section "HARDWARE INFORMATION"
    
    echo -e "${GREEN}CPU Information:${NC}"
    lscpu | grep -E "Model name:|CPU\(s\):|Thread|Core|Socket|MHz|Cache"
    
    echo -e "\n${GREEN}Memory Information:${NC}"
    free -h
    echo -e "\n${GREEN}Memory Slots:${NC}"
    dmidecode -t memory 2>/dev/null | grep -E "Size:|Type:|Speed:" | head -10
    
    echo -e "\n${GREEN}Disk Information:${NC}"
    lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,FSTYPE
    
    echo -e "\n${GREEN}PCI Devices:${NC}"
    lspci | grep -E "VGA|Network|RAID|SATA" | nl
    
    pause_screen
}

# 3. Network Configuration
network_info() {
    print_header
    print_section "NETWORK CONFIGURATION"
    
    echo -e "${GREEN}Network Interfaces:${NC}"
    ip -c -br addr show
    
    echo -e "\n${GREEN}Default Gateway:${NC}"
    ip route | grep default
    
    echo -e "\n${GREEN}DNS Servers:${NC}"
    grep nameserver /etc/resolv.conf
    
    echo -e "\n${GREEN}Active Connections:${NC}"
    ss -tun | head -20
    
    echo -e "\n${GREEN}Firewall Status:${NC}"
    if command -v firewall-cmd &> /dev/null; then
        firewall-cmd --state
        firewall-cmd --list-all
    else
        iptables -L -n | head -20
    fi
    
    pause_screen
}

# 4. Disk Usage Analysis
disk_usage() {
    print_header
    print_section "DISK USAGE ANALYSIS"
    
    echo -e "${GREEN}Filesystem Usage:${NC}"
    df -hT | grep -v tmpfs
    
    echo -e "\n${GREEN}Disk I/O Statistics:${NC}"
    iostat -x 1 2 | tail -n +4
    
    echo -e "\n${GREEN}Top 10 Largest Directories:${NC}"
    du -sh /* 2>/dev/null | sort -hr | head -10
    
    echo -e "\n${GREEN}Inode Usage:${NC}"
    df -i | grep -v tmpfs | awk '{if(NR==1 || $5+0 > 50) print}'
    
    pause_screen
}

# 5. Security Audit
security_audit() {
    print_header
    print_section "SECURITY AUDIT"
    
    echo -e "${GREEN}SELinux Status:${NC}"
    sestatus | head -5
    
    echo -e "\n${GREEN}Failed Login Attempts:${NC}"
    lastb | head -10 2>/dev/null || echo "No failed logins"
    
    echo -e "\n${GREEN}Open Ports:${NC}"
    ss -tulpn | grep LISTEN
    
    echo -e "\n${GREEN}SUID Files:${NC}"
    find /usr/bin /usr/sbin -perm -4000 2>/dev/null | head -10
    
    echo -e "\n${GREEN}Password Policy:${NC}"
    grep -E "^PASS_" /etc/login.defs | grep -v "^#"
    
    pause_screen
}

# 6. Service Status
service_status() {
    print_header
    print_section "SERVICE STATUS"
    
    echo -e "${GREEN}Failed Services:${NC}"
    systemctl --failed --no-pager
    
    echo -e "\n${GREEN}Top Active Services by CPU:${NC}"
    systemd-cgtop -n 1 --cpu=percentage | head -15
    
    echo -e "\n${GREEN}Boot Time Analysis:${NC}"
    systemd-analyze
    
    echo -e "\n${GREEN}Critical Service Status:${NC}"
    for service in sshd firewalld NetworkManager crond; do
        status=$(systemctl is-active $service 2>/dev/null)
        if [ "$status" = "active" ]; then
            echo -e "$service: ${GREEN}● Active${NC}"
        else
            echo -e "$service: ${RED}● Inactive${NC}"
        fi
    done
    
    pause_screen
}

# 7. User and Group Audit
user_audit() {
    print_header
    print_section "USER AND GROUP AUDIT"
    
    echo -e "${GREEN}Users with Login Shell:${NC}"
    getent passwd | awk -F: '$7 !~ /nologin|false/ {print $1 " (UID: " $3 ")"}' | column -t
    
    echo -e "\n${GREEN}Sudo Users:${NC}"
    getent group wheel sudo 2>/dev/null | cut -d: -f4
    
    echo -e "\n${GREEN}Recent User Activity:${NC}"
    last -10
    
    echo -e "\n${GREEN}User Resource Limits:${NC}"
    ulimit -a | head -10
    
    echo -e "\n${GREEN}Expired Passwords:${NC}"
    awk -F: '$2 ~ /\$/ {print $1}' /etc/shadow | while read user; do
        chage -l $user 2>/dev/null | grep -E "Password expires|Account expires" | sed "s/^/$user: /"
    done | head -10
    
    pause_screen
}

# 8. Package Management
package_info() {
    print_header
    print_section "PACKAGE MANAGEMENT"
    
    echo -e "${GREEN}Package Statistics:${NC}"
    echo "Total packages: $(rpm -qa | wc -l)"
    echo "Kernel packages: $(rpm -qa kernel* | wc -l)"
    
    echo -e "\n${GREEN}Recently Installed Packages:${NC}"
    rpm -qa --last | head -10
    
    echo -e "\n${GREEN}Package Updates Available:${NC}"
    yum check-update 2>/dev/null | tail -n +3 | head -10
    
    echo -e "\n${GREEN}Broken Dependencies:${NC}"
    rpm -Va --nofiles --nodigest 2>/dev/null | head -10 || echo "No issues found"
    
    echo -e "\n${GREEN}Repository Status:${NC}"
    yum repolist all | grep -E "enabled|disabled" | head -10
    
    pause_screen
}

# 9. Performance Analysis
performance_check() {
    print_header
    print_section "PERFORMANCE ANALYSIS"
    
    echo -e "${GREEN}CPU Usage by Process:${NC}"
    ps aux --sort=-%cpu | head -10 | awk '{printf "%-20s %5s %5s %s\n", $11, $3, $4, $2}'
    
    echo -e "\n${GREEN}Memory Usage by Process:${NC}"
    ps aux --sort=-%mem | head -10 | awk '{printf "%-20s %5s %5s %s\n", $11, $4, $3, $2}'
    
    echo -e "\n${GREEN}System Performance Summary:${NC}"
    vmstat 1 5
    
    echo -e "\n${GREEN}CPU Core Usage:${NC}"
    mpstat -P ALL 1 1 2>/dev/null | tail -n +4 || echo "mpstat not available"
    
    pause_screen
}

# 10. Log Analysis
log_analysis() {
    print_header
    print_section "SYSTEM LOG ANALYSIS"
    
    echo -e "${GREEN}Recent System Errors:${NC}"
    journalctl -p err --since "1 hour ago" --no-pager | head -15
    
    echo -e "\n${GREEN}Authentication Logs:${NC}"
    grep -i "authentication\|login" /var/log/secure 2>/dev/null | tail -10
    
    echo -e "\n${GREEN}Kernel Messages:${NC}"
    dmesg -T | grep -E "error|fail|warn" | tail -10
    
    echo -e "\n${GREEN}Log File Sizes:${NC}"
    find /var/log -type f -size +10M -exec ls -lh {} \; 2>/dev/null | head -10
    
    pause_screen
}

# 11. System Health Score
health_score() {
    print_header
    print_section "SYSTEM HEALTH SCORE"
    
    score=100
    issues=""
    
    # Check CPU load
    load=$(cat /proc/loadavg | awk '{print $1}')
    cpu_count=$(nproc)
    if (( $(echo "$load > $cpu_count" | bc -l) )); then
        score=$((score - 10))
        issues="${issues}\n${RED}● High CPU load${NC}"
    fi
    
    # Check memory
    mem_free=$(free | awk '/^Mem:/ {print int($4/$2 * 100)}')
    if [ $mem_free -lt 20 ]; then
        score=$((score - 15))
        issues="${issues}\n${RED}● Low memory (${mem_free}% free)${NC}"
    fi
    
    # Check disk space
    while read -r usage mount; do
        if [ $usage -gt 85 ]; then
            score=$((score - 10))
            issues="${issues}\n${RED}● High disk usage on $mount (${usage}%)${NC}"
        fi
    done < <(df -h | awk 'NR>1 && $5 ~ /%/ {sub(/%/, "", $5); print $5, $6}')
    
    # Check failed services
    failed_count=$(systemctl --failed --no-pager | grep -c "failed")
    if [ $failed_count -gt 0 ]; then
        score=$((score - 5))
        issues="${issues}\n${RED}● $failed_count failed services${NC}"
    fi
    
    # Display score
    echo -e "${GREEN}Overall System Health Score:${NC} "
    if [ $score -ge 90 ]; then
        echo -e "${GREEN}${BOLD}$score/100 - EXCELLENT${NC}"
    elif [ $score -ge 70 ]; then
        echo -e "${YELLOW}${BOLD}$score/100 - GOOD${NC}"
    elif [ $score -ge 50 ]; then
        echo -e "${YELLOW}${BOLD}$score/100 - FAIR${NC}"
    else
        echo -e "${RED}${BOLD}$score/100 - POOR${NC}"
    fi
    
    if [ -n "$issues" ]; then
        echo -e "\n${YELLOW}Issues Found:${NC}"
        echo -e "$issues"
    fi
    
    pause_screen
}

# 12. Backup Status
backup_status() {
    print_header
    print_section "BACKUP STATUS CHECK"
    
    echo -e "${GREEN}Common Backup Locations:${NC}"
    for dir in /backup /var/backup /root/backup /home/backup; do
        if [ -d "$dir" ]; then
            echo -e "\n$dir:"
            ls -lh "$dir" 2>/dev/null | head -5
        fi
    done
    
    echo -e "\n${GREEN}Recent Archive Files:${NC}"
    find / -type f \( -name "*.tar.gz" -o -name "*.zip" -o -name "*.tar" \) -mtime -7 2>/dev/null | head -10
    
    echo -e "\n${GREEN}Cron Backup Jobs:${NC}"
    grep -i backup /etc/crontab /var/spool/cron/* 2>/dev/null | head -10
    
    pause_screen
}

# 13. Resource Trends
resource_trends() {
    print_header
    print_section "RESOURCE USAGE TRENDS"
    
    echo -e "${GREEN}CPU Usage History (1 min intervals):${NC}"
    sar -u 1 5 2>/dev/null || echo "sysstat not installed"
    
    echo -e "\n${GREEN}Memory Usage Trend:${NC}"
    for i in {1..5}; do
        mem=$(free | awk '/^Mem:/ {printf "%.1f", $3/$2 * 100}')
        echo "$(date '+%H:%M:%S'): ${mem}% used"
        sleep 1
    done
    
    echo -e "\n${GREEN}Network Traffic:${NC}"
    for iface in $(ip -br link show | awk '{print $1}' | grep -v lo); do
        rx1=$(cat /sys/class/net/$iface/statistics/rx_bytes 2>/dev/null || echo 0)
        tx1=$(cat /sys/class/net/$iface/statistics/tx_bytes 2>/dev/null || echo 0)
        sleep 1
        rx2=$(cat /sys/class/net/$iface/statistics/rx_bytes 2>/dev/null || echo 0)
        tx2=$(cat /sys/class/net/$iface/statistics/tx_bytes 2>/dev/null || echo 0)
        rx_rate=$((($rx2 - $rx1) / 1024))
        tx_rate=$((($tx2 - $tx1) / 1024))
        echo "$iface: RX: ${rx_rate} KB/s, TX: ${tx_rate} KB/s"
    done
    
    pause_screen
}

# 14. System Recommendations
system_recommendations() {
    print_header
    print_section "SYSTEM OPTIMIZATION RECOMMENDATIONS"
    
    recommendations=""
    
    # Check swap usage
    swap_used=$(free | awk '/^Swap:/ {if($2>0) print int($3/$2 * 100); else print 0}')
    if [ $swap_used -gt 50 ]; then
        recommendations="${recommendations}\n${YELLOW}● Consider adding more RAM (swap usage: ${swap_used}%)${NC}"
    fi
    
    # Check for old kernels
    kernel_count=$(rpm -qa kernel | wc -l)
    if [ $kernel_count -gt 3 ]; then
        recommendations="${recommendations}\n${YELLOW}● Remove old kernel versions (found: $kernel_count)${NC}"
    fi
    
    # Check tmp directory
    tmp_size=$(du -sh /tmp 2>/dev/null | awk '{print $1}')
    recommendations="${recommendations}\n${YELLOW}● Clean /tmp directory (current size: $tmp_size)${NC}"
    
    # Check for large log files
    large_logs=$(find /var/log -size +100M 2>/dev/null | wc -l)
    if [ $large_logs -gt 0 ]; then
        recommendations="${recommendations}\n${YELLOW}● Rotate large log files (found: $large_logs files >100MB)${NC}"
    fi
    
    # Check for zombie processes
    zombies=$(ps aux | grep -c " <defunct>")
    if [ $zombies -gt 0 ]; then
        recommendations="${recommendations}\n${YELLOW}● Clean up zombie processes (found: $zombies)${NC}"
    fi
    
    echo -e "${GREEN}System Optimization Recommendations:${NC}"
    echo -e "$recommendations"
    
    pause_screen
}

# 15. Generate Full Report
generate_report() {
    print_header
    print_section "GENERATING FULL SYSTEM REPORT"
    
    report_file="/tmp/system_report_$(date +%Y%m%d_%H%M%S).txt"
    
    {
        echo "SYSTEM HEALTH REPORT"
        echo "Generated: $(date)"
        echo "================================"
        echo
        echo "1. SYSTEM INFORMATION"
        uname -a
        cat /etc/redhat-release
        echo
        echo "2. HARDWARE SUMMARY"
        lscpu | grep -E "Model name:|CPU\(s\):"
        free -h | grep Mem:
        df -h | grep -v tmpfs | head -5
        echo
        echo "3. NETWORK CONFIGURATION"
        ip -br addr show
        echo
        echo "4. SERVICE STATUS"
        systemctl --failed --no-pager
        echo
        echo "5. SECURITY SUMMARY"
        getenforce
        ss -tulpn | grep LISTEN | wc -l
    } > "$report_file"
    
    echo -e "${GREEN}Report generated: $report_file${NC}"
    echo -e "\nReport preview:"
    head -20 "$report_file"
    
    pause_screen
}

# Main Menu
main_menu() {
    while true; do
        print_header
        echo -e "${WHITE}${BOLD}MAIN MENU${NC}"
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${CYAN}1)${NC}  System Information"
        echo -e "${CYAN}2)${NC}  Hardware Information"
        echo -e "${CYAN}3)${NC}  Network Configuration"
        echo -e "${CYAN}4)${NC}  Disk Usage Analysis"
        echo -e "${CYAN}5)${NC}  Security Audit"
        echo -e "${CYAN}6)${NC}  Service Status"
        echo -e "${CYAN}7)${NC}  User and Group Audit"
        echo -e "${CYAN}8)${NC}  Package Management"
        echo -e "${CYAN}9)${NC}  Performance Analysis"
        echo -e "${CYAN}10)${NC} Log Analysis"
        echo -e "${CYAN}11)${NC} System Health Score"
        echo -e "${CYAN}12)${NC} Backup Status"
        echo -e "${CYAN}13)${NC} Resource Trends"
        echo -e "${CYAN}14)${NC} System Recommendations"
        echo -e "${CYAN}15)${NC} Generate Full Report"
        echo -e "${RED}0)${NC}  Exit"
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -ne "${GREEN}Select an option [0-15]: ${NC}"
        
        read -r choice
        
        case $choice in
            1) system_info ;;
            2) hardware_info ;;
            3) network_info ;;
            4) disk_usage ;;
            5) security_audit ;;
            6) service_status ;;
            7) user_audit ;;
            8) package_info ;;
            9) performance_check ;;
            10) log_analysis ;;
            11) health_score ;;
            12) backup_status ;;
            13) resource_trends ;;
            14) system_recommendations ;;
            15) generate_report ;;
            0) echo -e "${GREEN}Exiting...${NC}"; exit 0 ;;
            *) echo -e "${RED}Invalid option. Please try again.${NC}"; sleep 2 ;;
        esac
    done
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}This script must be run as root${NC}"
    exit 1
fi

# Start the program
main_menu
