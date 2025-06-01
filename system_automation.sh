#!/bin/bash
#===============================================================================
# System Automation Script with Interactive Menu
# Automation, monitoring, and optimization tools for Red Hat Linux
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

# Global variables
BACKUP_DIR="/backup"
LOG_DIR="/var/log/automation"

# Create necessary directories
[ ! -d "$BACKUP_DIR" ] && mkdir -p "$BACKUP_DIR"
[ ! -d "$LOG_DIR" ] && mkdir -p "$LOG_DIR"

# Output formatting functions
print_header() {
    clear
    echo -e "${PURPLE}${BOLD}╔═══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}${BOLD}║${NC}${WHITE}${BOLD}                        SYSTEM AUTOMATION SUITE v2.0                           ${NC}${PURPLE}${BOLD}║${NC}"
    echo -e "${PURPLE}${BOLD}╚═══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo -e "${GREEN}Current Time: $(date '+%Y-%m-%d %H:%M:%S')${NC}\n"
}

print_section() {
    echo -e "\n${YELLOW}${BOLD}▶ $1${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ $1${NC}"
}

pause_screen() {
    echo -e "\n${CYAN}Press any key to continue...${NC}"
    read -n 1 -s
}

confirm_action() {
    echo -ne "${YELLOW}Are you sure you want to proceed? (y/N): ${NC}"
    read -r response
    [[ "$response" =~ ^[Yy]$ ]]
}

# 1. Backup System Configurations
backup_configs() {
    print_header
    print_section "BACKUP SYSTEM CONFIGURATIONS"
    
    timestamp=$(date +%Y%m%d_%H%M%S)
    backup_path="$BACKUP_DIR/system_backup_$timestamp"
    
    echo -e "${CYAN}Creating backup directory: $backup_path${NC}"
    mkdir -p "$backup_path"
    
    # Backup important directories
    configs=(
        "/etc"
        "/root/.bashrc"
        "/root/.bash_profile"
        "/var/spool/cron"
        "/etc/systemd/system"
    )
    
    for config in "${configs[@]}"; do
        if [ -e "$config" ]; then
            echo -ne "Backing up $config... "
            tar -czf "$backup_path/$(basename $config)_backup.tar.gz" "$config" 2>/dev/null
            if [ $? -eq 0 ]; then
                print_success "Done"
            else
                print_error "Failed"
            fi
        fi
    done
    
    # Create backup summary
    echo -e "\n${GREEN}Backup Summary:${NC}"
    du -sh "$backup_path"
    ls -lh "$backup_path"
    
    # Compress entire backup
    echo -ne "\nCompressing final backup... "
    tar -czf "$backup_path.tar.gz" -C "$BACKUP_DIR" "system_backup_$timestamp"
    if [ $? -eq 0 ]; then
        print_success "Done"
        rm -rf "$backup_path"
        echo -e "${GREEN}Backup saved to: $backup_path.tar.gz${NC}"
    fi
    
    pause_screen
}

# 2. User Management
user_management() {
    print_header
    print_section "USER MANAGEMENT"
    
    echo -e "${WHITE}Select operation:${NC}"
    echo -e "${CYAN}1)${NC} Create multiple users"
    echo -e "${CYAN}2)${NC} Delete inactive users"
    echo -e "${CYAN}3)${NC} Reset user passwords"
    echo -e "${CYAN}4)${NC} Lock/Unlock users"
    echo -e "${CYAN}5)${NC} Set password expiry policies"
    echo -e "${CYAN}6)${NC} Return to main menu"
    
    echo -ne "${GREEN}Select option: ${NC}"
    read -r user_choice
    
    case $user_choice in
        1) # Create users
            echo -e "\n${CYAN}Enter usernames (space-separated): ${NC}"
            read -r usernames
            for username in $usernames; do
                if useradd -m "$username" 2>/dev/null; then
                    password=$(openssl rand -base64 12)
                    echo "$username:$password" | chpasswd
                    print_success "User $username created with password: $password"
                else
                    print_error "Failed to create user $username"
                fi
            done
            ;;
        2) # Delete inactive users
            echo -e "\n${CYAN}Users inactive for more than 90 days:${NC}"
            lastlog -b 90 | tail -n +2 | awk '{print $1}'
            if confirm_action; then
                lastlog -b 90 | tail -n +2 | awk '{print $1}' | while read user; do
                    userdel -r "$user" 2>/dev/null && print_success "Deleted $user"
                done
            fi
            ;;
        3) # Reset passwords
            echo -e "\n${CYAN}Enter username to reset password: ${NC}"
            read -r username
            if id "$username" &>/dev/null; then
                password=$(openssl rand -base64 12)
                echo "$username:$password" | chpasswd
                chage -d 0 "$username"
                print_success "Password reset for $username: $password (must change on next login)"
            else
                print_error "User not found"
            fi
            ;;
        4) # Lock/Unlock users
            echo -e "\n${CYAN}Enter username: ${NC}"
            read -r username
            echo -e "${CYAN}Lock (l) or Unlock (u)?: ${NC}"
            read -r action
            if [[ "$action" == "l" ]]; then
                usermod -L "$username" && print_success "User $username locked"
            elif [[ "$action" == "u" ]]; then
                usermod -U "$username" && print_success "User $username unlocked"
            fi
            ;;
        5) # Password policies
            echo -e "\n${CYAN}Setting password policies for all users...${NC}"
            getent passwd | awk -F: '$3 >= 1000 {print $1}' | while read user; do
                chage -M 90 -m 7 -W 14 "$user"
                print_success "Password policy set for $user"
            done
            ;;
    esac
    
    pause_screen
}

# 3. Log Rotation and Cleanup
log_rotation() {
    print_header
    print_section "LOG ROTATION AND CLEANUP"
    
    echo -e "${CYAN}Current log disk usage:${NC}"
    du -sh /var/log/* | sort -hr | head -10
    
    if confirm_action; then
        # Compress old logs
        echo -e "\n${CYAN}Compressing old logs...${NC}"
        find /var/log -name "*.log" -type f -mtime +7 -exec gzip -9 {} \; 2>/dev/null
        
        # Delete very old compressed logs
        echo -e "${CYAN}Removing logs older than 90 days...${NC}"
        find /var/log -name "*.gz" -type f -mtime +90 -delete
        
        # Truncate active large logs
        echo -e "${CYAN}Truncating large active logs...${NC}"
        for log in /var/log/{messages,secure,maillog,cron}; do
            if [ -f "$log" ] && [ $(stat -c%s "$log") -gt 104857600 ]; then
                echo -ne "Truncating $(basename $log)... "
                tail -n 10000 "$log" > "$log.tmp"
                mv "$log.tmp" "$log"
                print_success "Done"
            fi
        done
        
        # Clean journal logs
        echo -e "\n${CYAN}Cleaning systemd journal...${NC}"
        journalctl --vacuum-time=30d
        
        print_success "\nLog cleanup completed!"
    fi
    
    pause_screen
}

# 4. System Updates
system_updates() {
    print_header
    print_section "SYSTEM UPDATE MANAGEMENT"
    
    echo -e "${CYAN}Checking for updates...${NC}"
    update_count=$(yum check-update 2>/dev/null | tail -n +3 | grep -v "^$" | wc -l)
    
    echo -e "${GREEN}Available updates: $update_count${NC}"
    
    if [ $update_count -gt 0 ]; then
        echo -e "\n${WHITE}Update options:${NC}"
        echo -e "${CYAN}1)${NC} Show available updates"
        echo -e "${CYAN}2)${NC} Update security patches only"
        echo -e "${CYAN}3)${NC} Update all packages"
        echo -e "${CYAN}4)${NC} Update specific package"
        echo -e "${CYAN}5)${NC} Schedule automatic updates"
        echo -e "${CYAN}6)${NC} Return"
        
        echo -ne "${GREEN}Select option: ${NC}"
        read -r update_choice
        
        case $update_choice in
            1) yum check-update ;;
            2) yum update --security -y ;;
            3) yum update -y ;;
            4) 
                echo -ne "${CYAN}Enter package name: ${NC}"
                read -r package
                yum update "$package" -y
                ;;
            5)
                echo "0 3 * * 0 root /usr/bin/yum update -y >> /var/log/auto-update.log 2>&1" >> /etc/crontab
                print_success "Automatic updates scheduled for Sunday 3 AM"
                ;;
        esac
    else
        print_info "System is up to date!"
    fi
    
    pause_screen
}

# 5. Disk Space Management
disk_management() {
    print_header
    print_section "DISK SPACE MANAGEMENT"
    
    echo -e "${CYAN}Disk usage analysis:${NC}"
    df -h | awk '$5+0 > 70 {print $0}' | grep -v "Use%"
    
    echo -e "\n${WHITE}Cleanup options:${NC}"
    echo -e "${CYAN}1)${NC} Clean package cache"
    echo -e "${CYAN}2)${NC} Remove old kernels"
    echo -e "${CYAN}3)${NC} Clean temporary files"
    echo -e "${CYAN}4)${NC} Find and remove large files"
    echo -e "${CYAN}5)${NC} Clean docker/container data"
    echo -e "${CYAN}6)${NC} Analyze disk usage by directory"
    
    echo -ne "${GREEN}Select option: ${NC}"
    read -r disk_choice
    
    case $disk_choice in
        1)
            echo -e "\n${CYAN}Cleaning package cache...${NC}"
            yum clean all
            print_success "Package cache cleaned"
            ;;
        2)
            echo -e "\n${CYAN}Current kernels:${NC}"
            rpm -qa kernel
            if confirm_action; then
                package-cleanup --oldkernels --count=2 -y
            fi
            ;;
        3)
            echo -e "\n${CYAN}Cleaning temporary files...${NC}"
            find /tmp -type f -atime +7 -delete
            find /var/tmp -type f -atime +30 -delete
            print_success "Temporary files cleaned"
            ;;
        4)
            echo -e "\n${CYAN}Files larger than 100MB:${NC}"
            find / -xdev -type f -size +100M 2>/dev/null | head -20
            ;;
        5)
            if command -v docker &>/dev/null; then
                echo -e "\n${CYAN}Cleaning Docker data...${NC}"
                docker system prune -af
            fi
            ;;
        6)
            echo -e "\n${CYAN}Top 20 directories by size:${NC}"
            du -hx / 2>/dev/null | sort -hr | head -20
            ;;
    esac
    
    pause_screen
}

# 6. SSL Certificate Management
ssl_management() {
    print_header
    print_section "SSL CERTIFICATE MANAGEMENT"
    
    echo -e "${CYAN}Checking SSL certificates...${NC}\n"
    
    cert_dirs=(
        "/etc/pki/tls/certs"
        "/etc/ssl/certs"
        "/etc/httpd/conf.d/ssl"
        "/etc/nginx/ssl"
    )
    
    for dir in "${cert_dirs[@]}"; do
        if [ -d "$dir" ]; then
            echo -e "${GREEN}Checking $dir:${NC}"
            find "$dir" -name "*.crt" -o -name "*.pem" 2>/dev/null | while read cert; do
                if [ -f "$cert" ]; then
                    expiry=$(openssl x509 -enddate -noout -in "$cert" 2>/dev/null | cut -d= -f2)
                    if [ -n "$expiry" ]; then
                        days_left=$(( ($(date -d "$expiry" +%s) - $(date +%s)) / 86400 ))
                        if [ $days_left -lt 30 ]; then
                            print_error "$(basename $cert) expires in $days_left days"
                        else
                            print_info "$(basename $cert) expires in $days_left days"
                        fi
                    fi
                fi
            done
        fi
    done
    
    echo -e "\n${WHITE}Certificate options:${NC}"
    echo -e "${CYAN}1)${NC} Generate self-signed certificate"
    echo -e "${CYAN}2)${NC} Backup all certificates"
    echo -e "${CYAN}3)${NC} Check certificate details"
    echo -e "${CYAN}4)${NC} Return"
    
    echo -ne "${GREEN}Select option: ${NC}"
    read -r cert_choice
    
    case $cert_choice in
        1)
            echo -ne "${CYAN}Enter domain name: ${NC}"
            read -r domain
            openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
                -keyout "/tmp/$domain.key" -out "/tmp/$domain.crt" \
                -subj "/C=US/ST=State/L=City/O=Organization/CN=$domain"
            print_success "Certificate generated in /tmp/"
            ;;
        2)
            tar -czf "$BACKUP_DIR/ssl_backup_$(date +%Y%m%d).tar.gz" \
                /etc/pki/tls/certs /etc/ssl/certs 2>/dev/null
            print_success "Certificates backed up"
            ;;
        3)
            echo -ne "${CYAN}Enter certificate path: ${NC}"
            read -r cert_path
            if [ -f "$cert_path" ]; then
                openssl x509 -text -noout -in "$cert_path" | less
            fi
            ;;
    esac
    
    pause_screen
}

# 7. Firewall Rules Management
firewall_management() {
    print_header
    print_section "FIREWALL RULES MANAGEMENT"
    
    if command -v firewall-cmd &>/dev/null; then
        echo -e "${CYAN}Current firewall status:${NC}"
        firewall-cmd --state
        echo -e "\n${CYAN}Active zones:${NC}"
        firewall-cmd --get-active-zones
        
        echo -e "\n${WHITE}Firewall options:${NC}"
        echo -e "${CYAN}1)${NC} List all rules"
        echo -e "${CYAN}2)${NC} Add service"
        echo -e "${CYAN}3)${NC} Add port"
        echo -e "${CYAN}4)${NC} Remove service/port"
        echo -e "${CYAN}5)${NC} Backup rules"
        echo -e "${CYAN}6)${NC} Restore rules"
        echo -e "${CYAN}7)${NC} Enable/Disable firewall"
        
        echo -ne "${GREEN}Select option: ${NC}"
        read -r fw_choice
        
        case $fw_choice in
            1) firewall-cmd --list-all ;;
            2)
                echo -ne "${CYAN}Enter service name (e.g., http, https, ssh): ${NC}"
                read -r service
                firewall-cmd --permanent --add-service="$service"
                firewall-cmd --reload
                ;;
            3)
                echo -ne "${CYAN}Enter port/protocol (e.g., 8080/tcp): ${NC}"
                read -r port
                firewall-cmd --permanent --add-port="$port"
                firewall-cmd --reload
                ;;
            4)
                echo -e "${CYAN}Current services:${NC}"
                firewall-cmd --list-services
                echo -ne "${CYAN}Enter service or port to remove: ${NC}"
                read -r item
                firewall-cmd --permanent --remove-service="$item" 2>/dev/null || \
                firewall-cmd --permanent --remove-port="$item"
                firewall-cmd --reload
                ;;
            5)
                firewall-cmd --runtime-to-permanent
                cp -r /etc/firewalld "$BACKUP_DIR/firewalld_backup_$(date +%Y%m%d)"
                print_success "Firewall rules backed up"
                ;;
            6)
                echo -e "${CYAN}Available backups:${NC}"
                ls -d $BACKUP_DIR/firewalld_backup_* 2>/dev/null
                ;;
            7)
                if systemctl is-active firewalld >/dev/null; then
                    systemctl stop firewalld
                    print_info "Firewall stopped"
                else
                    systemctl start firewalld
                    print_success "Firewall started"
                fi
                ;;
        esac
    else
        echo -e "${CYAN}Using iptables:${NC}"
        iptables -L -n -v
        echo -e "\n${CYAN}Saving current rules...${NC}"
        iptables-save > "$BACKUP_DIR/iptables_$(date +%Y%m%d).rules"
    fi
    
    pause_screen
}

# 8. Service Monitoring
service_monitoring() {
    print_header
    print_section "SERVICE MONITORING AND MANAGEMENT"
    
    critical_services=(
        "sshd"
        "firewalld"
        "NetworkManager"
        "crond"
        "rsyslog"
    )
    
    echo -e "${CYAN}Critical Services Status:${NC}\n"
    for service in "${critical_services[@]}"; do
        if systemctl is-active "$service" &>/dev/null; then
            print_success "$service is running"
        else
            print_error "$service is not running"
            echo -ne "  Start $service? (y/N): "
            read -r response
            if [[ "$response" =~ ^[Yy]$ ]]; then
                systemctl start "$service"
            fi
        fi
    done
    
    echo -e "\n${WHITE}Service options:${NC}"
    echo -e "${CYAN}1)${NC} Enable service auto-restart"
    echo -e "${CYAN}2)${NC} Create service monitor script"
    echo -e "${CYAN}3)${NC} View service logs"
    echo -e "${CYAN}4)${NC} Restart all failed services"
    echo -e "${CYAN}5)${NC} Service dependency check"
    
    echo -ne "${GREEN}Select option: ${NC}"
    read -r svc_choice
    
    case $svc_choice in
        1)
            echo -ne "${CYAN}Enter service name: ${NC}"
            read -r service
            mkdir -p /etc/systemd/system/"$service".service.d
            cat > /etc/systemd/system/"$service".service.d/restart.conf <<EOF
[Service]
Restart=always
RestartSec=5
EOF
            systemctl daemon-reload
            print_success "Auto-restart enabled for $service"
            ;;
        2)
            cat > /usr/local/bin/service_monitor.sh <<'EOF'
#!/bin/bash
SERVICES="sshd firewalld NetworkManager crond"
for service in $SERVICES; do
    if ! systemctl is-active $service &>/dev/null; then
        systemctl start $service
        echo "$(date): Restarted $service" >> /var/log/service_monitor.log
    fi
done
EOF
            chmod +x /usr/local/bin/service_monitor.sh
            echo "*/5 * * * * root /usr/local/bin/service_monitor.sh" >> /etc/crontab
            print_success "Service monitor created"
            ;;
        3)
            echo -ne "${CYAN}Enter service name: ${NC}"
            read -r service
            journalctl -u "$service" -n 50
            ;;
        4)
            systemctl list-units --failed --no-pager | grep service | awk '{print $2}' | \
            while read service; do
                systemctl restart "$service"
                print_info "Attempted restart of $service"
            done
            ;;
        5)
            echo -ne "${CYAN}Enter service name: ${NC}"
            read -r service
            systemctl list-dependencies "$service"
            ;;
    esac
    
    pause_screen
}

# 9. Cleanup and Optimization
system_cleanup() {
    print_header
    print_section "SYSTEM CLEANUP AND OPTIMIZATION"
    
    echo -e "${CYAN}Starting comprehensive system cleanup...${NC}\n"
    
    # Memory cleanup
    echo -e "${GREEN}1. Clearing memory cache...${NC}"
    sync
    echo 3 > /proc/sys/vm/drop_caches
    
    # Package cleanup
    echo -e "${GREEN}2. Cleaning package manager...${NC}"
    yum clean all
    
    # Temp files
    echo -e "${GREEN}3. Removing temporary files...${NC}"
    find /tmp -type f -atime +7 -delete 2>/dev/null
    find /var/tmp -type f -atime +30 -delete 2>/dev/null
    
    # Old logs
    echo -e "${GREEN}4. Compressing old logs...${NC}"
    find /var/log -name "*.log" -mtime +7 -exec gzip {} \; 2>/dev/null
    
    # Core dumps
    echo -e "${GREEN}5. Removing core dumps...${NC}"
    find / -name "core.*" -type f -delete 2>/dev/null
    
    # Orphaned packages
    echo -e "${GREEN}6. Checking for orphaned packages...${NC}"
    package-cleanup --leaves
    
    # Duplicate packages
    echo -e "${GREEN}7. Checking for duplicate packages...${NC}"
    package-cleanup --dupes
    
    # Empty directories
    echo -e "${GREEN}8. Removing empty directories in /tmp...${NC}"
    find /tmp -type d -empty -delete 2>/dev/null
    
    # Browser caches (if any)
    echo -e "${GREEN}9. Cleaning user caches...${NC}"
    find /home -name ".cache" -type d -exec rm -rf {} \; 2>/dev/null
    
    # Mail queue
    echo -e "${GREEN}10. Checking mail queue...${NC}"
    mailq | tail -5
    
    print_success "\nSystem cleanup completed!"
    
    # Show space saved
    echo -e "\n${CYAN}Disk usage after cleanup:${NC}"
    df -h | grep -v tmpfs
    
    pause_screen
}

# 10. Performance Tuning
performance_tuning() {
    print_header
    print_section "PERFORMANCE TUNING"
    
    echo -e "${WHITE}Performance optimization options:${NC}"
    echo -e "${CYAN}1)${NC} Optimize kernel parameters"
    echo -e "${CYAN}2)${NC} Configure swappiness"
    echo -e "${CYAN}3)${NC} Set CPU governor"
    echo -e "${CYAN}4)${NC} Optimize network settings"
    echo -e "${CYAN}5)${NC} Configure I/O scheduler"
    echo -e "${CYAN}6)${NC} System limits optimization"
    
    echo -ne "${GREEN}Select option: ${NC}"
    read -r perf_choice
    
    case $perf_choice in
        1)
            echo -e "\n${CYAN}Applying kernel optimizations...${NC}"
            cat >> /etc/sysctl.conf <<EOF
# Performance Tuning
vm.swappiness = 10
vm.dirty_ratio = 15
vm.dirty_background_ratio = 5
kernel.sched_migration_cost_ns = 5000000
EOF
            sysctl -p
            print_success "Kernel parameters optimized"
            ;;
        2)
            current_swap=$(cat /proc/sys/vm/swappiness)
            echo -e "\n${CYAN}Current swappiness: $current_swap${NC}"
            echo -ne "Enter new value (0-100): "
            read -r new_swap
            echo "vm.swappiness = $new_swap" >> /etc/sysctl.conf
            sysctl vm.swappiness=$new_swap
            ;;
        3)
            echo -e "\n${CYAN}Available CPU governors:${NC}"
            cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors 2>/dev/null
            echo -ne "Select governor: "
            read -r governor
            for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
                echo "$governor" > "$cpu" 2>/dev/null
            done
            ;;
        4)
            echo -e "\n${CYAN}Optimizing network settings...${NC}"
            cat >> /etc/sysctl.conf <<EOF
# Network Optimization
net.core.rmem_max = 134217728
net.core.wmem_max = 134217728
net.ipv4.tcp_rmem = 4096 87380 134217728
net.ipv4.tcp_wmem = 4096 65536 134217728
net.core.netdev_max_backlog = 5000
EOF
            sysctl -p
            ;;
        5)
            echo -e "\n${CYAN}Current I/O schedulers:${NC}"
            for disk in /sys/block/sd*/queue/scheduler; do
                [ -f "$disk" ] && echo "$(dirname $disk | xargs basename): $(cat $disk)"
            done
            ;;
        6)
            echo -e "\n${CYAN}Setting system limits...${NC}"
            cat >> /etc/security/limits.conf <<EOF
# Performance Limits
* soft nofile 65535
* hard nofile 65535
* soft nproc 32768
* hard nproc 32768
EOF
            print_success "System limits updated"
            ;;
    esac
    
    pause_screen
}

# 11. Database Maintenance (MySQL/PostgreSQL)
database_maintenance() {
    print_header
    print_section "DATABASE MAINTENANCE"
    
    echo -e "${WHITE}Select database type:${NC}"
    echo -e "${CYAN}1)${NC} MySQL/MariaDB"
    echo -e "${CYAN}2)${NC} PostgreSQL"
    echo -e "${CYAN}3)${NC} Return"
    
    echo -ne "${GREEN}Select option: ${NC}"
    read -r db_choice
    
    case $db_choice in
        1)
            if command -v mysql &>/dev/null; then
                echo -e "\n${CYAN}MySQL/MariaDB maintenance options:${NC}"
                echo -e "${CYAN}1)${NC} Backup all databases"
                echo -e "${CYAN}2)${NC} Optimize tables"
                echo -e "${CYAN}3)${NC} Check table integrity"
                echo -e "${CYAN}4)${NC} Show database sizes"
                
                echo -ne "${GREEN}Select option: ${NC}"
                read -r mysql_choice
                
                case $mysql_choice in
                    1)
                        mysqldump --all-databases > "$BACKUP_DIR/mysql_backup_$(date +%Y%m%d).sql"
                        print_success "Database backup completed"
                        ;;
                    2)
                        mysqlcheck -o --all-databases
                        ;;
                    3)
                        mysqlcheck -c --all-databases
                        ;;
                    4)
                        mysql -e "SELECT table_schema AS 'Database', 
                                 ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'Size (MB)' 
                                 FROM information_schema.TABLES 
                                 GROUP BY table_schema;"
                        ;;
                esac
            else
                print_error "MySQL/MariaDB not installed"
            fi
            ;;
        2)
            if command -v psql &>/dev/null; then
                echo -e "\n${CYAN}PostgreSQL maintenance:${NC}"
                sudo -u postgres vacuumdb --all --analyze
                print_success "PostgreSQL vacuum completed"
            else
                print_error "PostgreSQL not installed"
            fi
            ;;
    esac
    
    pause_screen
}

# 12. Automated Reports
generate_reports() {
    print_header
    print_section "AUTOMATED SYSTEM REPORTS"
    
    report_dir="$LOG_DIR/reports"
    mkdir -p "$report_dir"
    
    echo -e "${WHITE}Report options:${NC}"
    echo -e "${CYAN}1)${NC} Daily system summary"
    echo -e "${CYAN}2)${NC} Security audit report"
    echo -e "${CYAN}3)${NC} Performance report"
    echo -e "${CYAN}4)${NC} User activity report"
    echo -e "${CYAN}5)${NC} Schedule automatic reports"
    echo -e "${CYAN}6)${NC} Email report configuration"
    
    echo -ne "${GREEN}Select option: ${NC}"
    read -r report_choice
    
    case $report_choice in
        1)
            report_file="$report_dir/daily_summary_$(date +%Y%m%d).txt"
            {
                echo "DAILY SYSTEM SUMMARY - $(date)"
                echo "================================"
                echo
                echo "System Uptime:"
                uptime
                echo
                echo "Disk Usage:"
                df -h | grep -v tmpfs
                echo
                echo "Memory Usage:"
                free -h
                echo
                echo "Top Processes:"
                ps aux --sort=-%cpu | head -10
                echo
                echo "Failed Services:"
                systemctl --failed --no-pager
                echo
                echo "Recent Errors:"
                journalctl -p err --since "24 hours ago" --no-pager | head -20
            } > "$report_file"
            
            print_success "Report saved to: $report_file"
            cat "$report_file" | less
            ;;
        2)
            report_file="$report_dir/security_audit_$(date +%Y%m%d).txt"
            {
                echo "SECURITY AUDIT REPORT - $(date)"
                echo "================================"
                echo
                echo "Failed Login Attempts:"
                grep "Failed password" /var/log/secure | tail -20
                echo
                echo "SSH Connections:"
                grep "Accepted" /var/log/secure | tail -20
                echo
                echo "Sudo Commands:"
                grep sudo /var/log/secure | tail -20
                echo
                echo "Open Ports:"
                ss -tulpn
                echo
                echo "Firewall Rules:"
                firewall-cmd --list-all 2>/dev/null || iptables -L
            } > "$report_file"
            
            print_success "Security report saved"
            ;;
        3)
            report_file="$report_dir/performance_$(date +%Y%m%d).txt"
            {
                echo "PERFORMANCE REPORT - $(date)"
                echo "=========================="
                echo
                sar -u 1 5
                echo
                sar -r 1 5
                echo
                iostat -x 1 5
            } > "$report_file" 2>/dev/null
            
            print_success "Performance report saved"
            ;;
        4)
            report_file="$report_dir/user_activity_$(date +%Y%m%d).txt"
            {
                echo "USER ACTIVITY REPORT - $(date)"
                echo "=============================="
                echo
                echo "Currently Logged Users:"
                w
                echo
                echo "Last 50 Logins:"
                last -50
                echo
                echo "User Resource Usage:"
                ps aux | awk '{arr[$1]+=$3} END {for (i in arr) {print i,arr[i]"%"}}' | sort -k2 -nr
            } > "$report_file"
            
            print_success "User activity report saved"
            ;;
        5)
            cat > /etc/cron.daily/system_report <<'EOF'
#!/bin/bash
/path/to/this/script.sh --generate-daily-report
EOF
            chmod +x /etc/cron.daily/system_report
            print_success "Daily reports scheduled"
            ;;
        6)
            echo -ne "${CYAN}Enter email address for reports: ${NC}"
            read -r email
            echo "MAILTO=$email" >> /etc/crontab
            print_success "Email configured for reports"
            ;;
    esac
    
    pause_screen
}

# 13. Container Management
container_management() {
    print_header
    print_section "CONTAINER MANAGEMENT"
    
    if command -v docker &>/dev/null; then
        echo -e "${CYAN}Docker Status:${NC}"
        systemctl status docker --no-pager | head -10
        
        echo -e "\n${WHITE}Container options:${NC}"
        echo -e "${CYAN}1)${NC} List all containers"
        echo -e "${CYAN}2)${NC} Clean unused containers/images"
        echo -e "${CYAN}3)${NC} Container resource usage"
        echo -e "${CYAN}4)${NC} Backup container data"
        echo -e "${CYAN}5)${NC} Update all images"
        
        echo -ne "${GREEN}Select option: ${NC}"
        read -r container_choice
        
        case $container_choice in
            1)
                docker ps -a
                ;;
            2)
                docker system prune -af
                docker volume prune -f
                ;;
            3)
                docker stats --no-stream
                ;;
            4)
                docker ps -q | while read container; do
                    name=$(docker inspect -f '{{.Name}}' $container | sed 's/\///')
                    docker export $container | gzip > "$BACKUP_DIR/docker_${name}_$(date +%Y%m%d).tar.gz"
                done
                ;;
            5)
                docker images | awk 'NR>1 {print $1":"$2}' | while read image; do
                    docker pull "$image"
                done
                ;;
        esac
    else
        if command -v podman &>/dev/null; then
            echo -e "${CYAN}Using Podman...${NC}"
            podman ps -a
        else
            print_info "No container runtime found"
        fi
    fi
    
    pause_screen
}

# 14. Network Monitoring
network_monitoring() {
    print_header
    print_section "NETWORK MONITORING"
    
    echo -e "${WHITE}Network monitoring options:${NC}"
    echo -e "${CYAN}1)${NC} Real-time bandwidth usage"
    echo -e "${CYAN}2)${NC} Connection statistics"
    echo -e "${CYAN}3)${NC} Port scanning"
    echo -e "${CYAN}4)${NC} DNS performance test"
    echo -e "${CYAN}5)${NC} Network interface statistics"
    
    echo -ne "${GREEN}Select option: ${NC}"
    read -r net_choice
    
    case $net_choice in
        1)
            if command -v iftop &>/dev/null; then
                iftop -t -s 10
            else
                echo -e "${CYAN}Network traffic (10 second sample):${NC}"
                for i in {1..10}; do
                    rx1=$(cat /sys/class/net/[e]*/statistics/rx_bytes | awk '{s+=$1} END {print s}')
                    tx1=$(cat /sys/class/net/[e]*/statistics/tx_bytes | awk '{s+=$1} END {print s}')
                    sleep 1
                    rx2=$(cat /sys/class/net/[e]*/statistics/rx_bytes | awk '{s+=$1} END {print s}')
                    tx2=$(cat /sys/class/net/[e]*/statistics/tx_bytes | awk '{s+=$1} END {print s}')
                    echo "RX: $((($rx2-$rx1)/1024)) KB/s | TX: $((($tx2-$tx1)/1024)) KB/s"
                done
            fi
            ;;
        2)
            echo -e "${CYAN}Connection statistics:${NC}"
            ss -s
            echo -e "\n${CYAN}Top connections by state:${NC}"
            ss -tan | awk 'NR>1 {++state[$1]} END {for(i in state) print i": "state[i]}'
            ;;
        3)
            echo -ne "${CYAN}Enter IP to scan: ${NC}"
            read -r target_ip
            echo -e "\n${CYAN}Open ports on $target_ip:${NC}"
            for port in 22 80 443 3306 5432 8080; do
                timeout 1 bash -c "echo >/dev/tcp/$target_ip/$port" 2>/dev/null && echo "Port $port: OPEN"
            done
            ;;
        4)
            echo -e "${CYAN}DNS resolution test:${NC}"
            for dns in 8.8.8.8 1.1.1.1; do
                echo -ne "Testing $dns: "
                time nslookup google.com $dns >/dev/null 2>&1
            done
            ;;
        5)
            echo -e "${CYAN}Network interface statistics:${NC}"
            ip -s link show
            ;;
    esac
    
    pause_screen
}

# 15. Emergency Recovery
emergency_recovery() {
    print_header
    print_section "EMERGENCY RECOVERY OPTIONS"
    
    echo -e "${RED}${BOLD}WARNING: These options should be used carefully!${NC}\n"
    
    echo -e "${WHITE}Recovery options:${NC}"
    echo -e "${CYAN}1)${NC} Reset root password"
    echo -e "${CYAN}2)${NC} Restore system from backup"
    echo -e "${CYAN}3)${NC} Fix broken packages"
    echo -e "${CYAN}4)${NC} Rebuild RPM database"
    echo -e "${CYAN}5)${NC} Reset network configuration"
    echo -e "${CYAN}6)${NC} Clear all iptables rules"
    echo -e "${CYAN}7)${NC} Generate system rescue report"
    
    echo -ne "${GREEN}Select option: ${NC}"
    read -r recovery_choice
    
    case $recovery_choice in
        1)
            if confirm_action; then
                new_pass=$(openssl rand -base64 12)
                echo "root:$new_pass" | chpasswd
                print_success "Root password changed to: $new_pass"
            fi
            ;;
        2)
            echo -e "${CYAN}Available backups:${NC}"
            ls -lh $BACKUP_DIR/*.tar.gz 2>/dev/null | tail -10
            echo -ne "${CYAN}Enter backup file path: ${NC}"
            read -r backup_file
            if [ -f "$backup_file" ]; then
                tar -xzf "$backup_file" -C /
                print_success "Restore completed"
            fi
            ;;
        3)
            rpm --rebuilddb
            yum check
            package-cleanup --problems
            ;;
        4)
            rm -f /var/lib/rpm/__db*
            rpm --rebuilddb
            print_success "RPM database rebuilt"
            ;;
        5)
            if confirm_action; then
                systemctl stop NetworkManager
                rm -f /etc/sysconfig/network-scripts/ifcfg-*
                systemctl start NetworkManager
                nmcli device status
            fi
            ;;
        6)
            if confirm_action; then
                iptables -F
                iptables -X
                iptables -P INPUT ACCEPT
                iptables -P FORWARD ACCEPT
                iptables -P OUTPUT ACCEPT
                print_success "All iptables rules cleared"
            fi
            ;;
        7)
            rescue_report="$LOG_DIR/rescue_report_$(date +%Y%m%d_%H%M%S).txt"
            {
                echo "SYSTEM RESCUE REPORT"
                echo "===================="
                echo
                echo "System Information:"
                uname -a
                echo
                echo "Boot Messages:"
                dmesg | tail -50
                echo
                echo "Failed Services:"
                systemctl --failed
                echo
                echo "Disk Status:"
                df -h
                echo
                echo "Memory Status:"
                free -h
                echo
                echo "Network Status:"
                ip addr show
                echo
                echo "Recent Logs:"
                journalctl -xe --no-pager | tail -100
            } > "$rescue_report"
            
            print_success "Rescue report saved to: $rescue_report"
            ;;
    esac
    
    pause_screen
}

# Main Menu
main_menu() {
    while true; do
        print_header
        echo -e "${WHITE}${BOLD}AUTOMATION MENU${NC}"
        echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${CYAN}1)${NC}  Backup System Configurations"
        echo -e "${CYAN}2)${NC}  User Management"
        echo -e "${CYAN}3)${NC}  Log Rotation and Cleanup"
        echo -e "${CYAN}4)${NC}  System Updates"
        echo -e "${CYAN}5)${NC}  Disk Space Management"
        echo -e "${CYAN}6)${NC}  SSL Certificate Management"
        echo -e "${CYAN}7)${NC}  Firewall Rules Management"
        echo -e "${CYAN}8)${NC}  Service Monitoring"
        echo -e "${CYAN}9)${NC}  System Cleanup and Optimization"
        echo -e "${CYAN}10)${NC} Performance Tuning"
        echo -e "${CYAN}11)${NC} Database Maintenance"
        echo -e "${CYAN}12)${NC} Generate Reports"
        echo -e "${CYAN}13)${NC} Container Management"
        echo -e "${CYAN}14)${NC} Network Monitoring"
        echo -e "${CYAN}15)${NC} Emergency Recovery"
        echo -e "${RED}0)${NC}  Exit"
        echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -ne "${GREEN}Select an option [0-15]: ${NC}"
        
        read -r choice
        
        case $choice in
            1) backup_configs ;;
            2) user_management ;;
            3) log_rotation ;;
            4) system_updates ;;
            5) disk_management ;;
            6) ssl_management ;;
            7) firewall_management ;;
            8) service_monitoring ;;
            9) system_cleanup ;;
            10) performance_tuning ;;
            11) database_maintenance ;;
            12) generate_reports ;;
            13) container_management ;;
            14) network_monitoring ;;
            15) emergency_recovery ;;
            0) 
                echo -e "${GREEN}Thank you for using System Automation Suite!${NC}"
                exit 0 
                ;;
            *) 
                echo -e "${RED}Invalid option. Please try again.${NC}"
                sleep 2 
                ;;
        esac
    done
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}This script must be run as root${NC}"
    echo -e "${YELLOW}Try: sudo $0${NC}"
    exit 1
fi

# Start the program
main_menu
