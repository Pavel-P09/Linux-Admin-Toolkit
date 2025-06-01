# 🐧 Linux Admin Toolkit

> 🚀 **A comprehensive collection of interactive shell scripts that makes Linux system administration simple, efficient, and enjoyable!**

## 🌟 Overview

**Linux Admin Toolkit** is a powerful suite of interactive bash scripts designed to simplify system administration tasks on Red Hat-based Linux distributions. Whether you're a seasoned sysadmin or just starting out, these tools provide an intuitive menu-driven interface for complex administrative tasks.

### Why Linux Admin Toolkit?

- 🎯 **No more memorizing commands** - Everything is menu-driven
- 🛡️ **Built-in safety checks** - Confirmation prompts for critical operations
- 📊 **Beautiful visual output** - Color-coded results and Unicode formatting
- 🔧 **All-in-one solution** - From system checks to automation
- 📈 **Real-time monitoring** - Live system statistics and trends

## ✨ Features

### 🔍 System Check Script
- Comprehensive system analysis with 15 different check modules
- Real-time performance monitoring
- Security audit capabilities
- Automated health scoring system
- Detailed reporting functionality

### 🤖 System Automation Script
- 15 powerful automation modules
- One-click system optimization
- Automated backup solutions
- Service monitoring and recovery
- Emergency recovery options

## 📋 Requirements

- **Operating System**: Red Hat Enterprise Linux, CentOS, Fedora, Rocky Linux, AlmaLinux
- **Privileges**: Root access required
- **Shell**: Bash 4.0+
- **Dependencies**: Standard Linux utilities (automatically checked)

## 🚀 Installation

```bash
# Clone the repository
git clone https://github.com/Pavel-P09/Linux-Admin-Toolkit.git

# Navigate to the directory
cd linux-admin-toolkit

# Make scripts executable
chmod +x system_check.sh system_automation.sh

# Run system check
sudo ./system_check.sh

# Run automation suite
sudo ./system_automation.sh
```

## 💻 Usage

Both scripts feature an intuitive numbered menu system. Simply run the script and choose an option:

```bash
# For system analysis
sudo ./system_check.sh

# For automation tasks
sudo ./system_automation.sh
```

## 📊 Script 1: System Check

The **System Check** script provides comprehensive system analysis through 15 specialized modules:

### 1️⃣ **System Information** 
- 🖥️ OS version and kernel details
- 🏗️ System architecture
- 🌐 Hostname and domain info
- ⏱️ Uptime and system load
- 👥 Active users monitoring

### 2️⃣ **Hardware Information**
- 🔧 CPU specifications (cores, threads, cache)
- 💾 Memory configuration and slots
- 💿 Storage devices and partitions
- 🎮 PCI devices (GPU, network cards)

### 3️⃣ **Network Configuration**
- 🌐 Interface status with IP addresses
- 🛣️ Routing tables
- 📡 DNS configuration
- 🔌 Active connections
- 🛡️ Firewall status

### 4️⃣ **Disk Usage Analysis**
- 📊 Filesystem usage with types
- ⚡ Real-time I/O statistics
- 📁 Largest directories finder
- 🗂️ Inode usage monitoring

### 5️⃣ **Security Audit**
- 🔒 SELinux status check
- 🚫 Failed login attempts
- 🔓 Open ports analysis
- ⚠️ SUID files detection
- 🔑 Password policy review

### 6️⃣ **Service Status**
- ❌ Failed services detection
- 📈 CPU usage by service
- ⏱️ Boot time analysis
- ✅ Critical services monitoring

### 7️⃣ **User and Group Audit**
- 👤 Users with shell access
- 🔐 Sudo privileges audit
- 📅 Login history
- 📊 Resource limits
- 🔑 Password expiration check

### 8️⃣ **Package Management**
- 📦 Installed packages count
- 🆕 Recently installed packages
- 🔄 Available updates
- 🔧 Broken dependencies check
- 📚 Repository status

### 9️⃣ **Performance Analysis**
- 🎯 Top CPU consumers
- 💭 Top memory consumers
- 📊 Virtual memory statistics
- 🔥 Per-core CPU usage

### 🔟 **Log Analysis**
- 🚨 Recent system errors
- 🔐 Authentication logs
- 💻 Kernel messages
- 📏 Log file sizes

### 1️⃣1️⃣ **System Health Score**
- 🏆 Automated scoring (0-100)
- 🎨 Color-coded health status
- 📋 Issue identification
- 💡 Health recommendations

### 1️⃣2️⃣ **Backup Status**
- 💾 Backup location scanning
- 📅 Recent archives listing
- ⏰ Scheduled backup jobs

### 1️⃣3️⃣ **Resource Trends**
- 📈 CPU usage history
- 💾 Memory usage trends
- 🌐 Network traffic monitoring

### 1️⃣4️⃣ **System Recommendations**
- 🧠 Intelligent system analysis
- 💡 Optimization suggestions
- ⚠️ Problem identification
- 🔧 Actionable advice

### 1️⃣5️⃣ **Generate Full Report**
- 📄 Comprehensive system report
- 💾 Timestamped saving
- 👁️ Report preview

## 🔧 Script 2: System Automation

The **System Automation** script provides powerful automation capabilities through 15 specialized modules:

### 1️⃣ **Backup System Configurations**
- 🗄️ Automated config backups
- 📦 Compressed archives
- 🕐 Timestamped organization
- 📋 Backup summaries

### 2️⃣ **User Management**
- 👥 Bulk user creation
- 🔑 Automated password generation
- 🗑️ Inactive user cleanup
- 🔒 Account locking/unlocking
- 📅 Password policy enforcement

### 3️⃣ **Log Rotation and Cleanup**
- 🔄 Automatic log compression
- 🗑️ Old log deletion
- ✂️ Large log truncation
- 🧹 Journal cleanup

### 4️⃣ **System Updates**
- 🔍 Update availability check
- 🛡️ Security-only updates
- 📦 Full system updates
- 🎯 Specific package updates
- ⏰ Scheduled auto-updates

### 5️⃣ **Disk Space Management**
- 🧹 Package cache cleanup
- 🌰 Old kernel removal
- 🗑️ Temporary file cleanup
- 🔍 Large file finder
- 🐳 Docker cleanup

### 6️⃣ **SSL Certificate Management**
- 📜 Certificate expiry monitoring
- ⚠️ Expiration warnings
- 🔐 Self-signed cert generation
- 💾 Certificate backups
- 🔍 Certificate details viewer

### 7️⃣ **Firewall Rules Management**
- 🛡️ Rule listing and editing
- ➕ Service/port addition
- ➖ Rule removal
- 💾 Configuration backup
- 🔄 Rule restoration

### 8️⃣ **Service Monitoring**
- 🔍 Critical service checks
- 🔄 Auto-restart configuration
- 📝 Monitor script creation
- 📊 Service logs viewer
- 🔧 Failed service recovery

### 9️⃣ **System Cleanup and Optimization**
- 🧹 10-step cleanup process
- 💾 Memory cache clearing
- 📦 Package cleanup
- 🗑️ Orphaned package removal
- 📧 Mail queue check

### 🔟 **Performance Tuning**
- ⚙️ Kernel parameter optimization
- 💾 Swappiness configuration
- 🔥 CPU governor settings
- 🌐 Network optimization
- 💿 I/O scheduler tuning

### 1️⃣1️⃣ **Database Maintenance**
- 🗄️ MySQL/MariaDB support
- 🐘 PostgreSQL support
- 💾 Automated backups
- 🔧 Table optimization
- 📊 Size analysis

### 1️⃣2️⃣ **Generate Reports**
- 📊 Daily system summaries
- 🔒 Security audit reports
- 🎯 Performance reports
- 👥 User activity reports
- 📧 Email integration

### 1️⃣3️⃣ **Container Management**
- 🐳 Docker support
- 🦭 Podman support
- 🧹 Resource cleanup
- 📊 Container statistics
- 🔄 Image updates

### 1️⃣4️⃣ **Network Monitoring**
- 📊 Bandwidth monitoring
- 🔌 Connection statistics
- 🔍 Port scanning
- 🌐 DNS performance
- 📈 Interface statistics

### 1️⃣5️⃣ **Emergency Recovery**
- 🔑 Root password reset
- 💾 System restoration
- 🔧 Package repair
- 🗄️ RPM database rebuild
- 🌐 Network reset

## 📸 Screenshots

### Main Menu
```
╔═══════════════════════════════════════════════════════════════════════════════╗
║                          SYSTEM CHECK UTILITY v2.0                            ║
╚═══════════════════════════════════════════════════════════════════════════════╝
Current Time: 2024-01-15 10:30:45

MAIN MENU
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1)  System Information
2)  Hardware Information
3)  Network Configuration
[...]
Select an option [0-15]: 
```

### System Health Score
```
▶ SYSTEM HEALTH SCORE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Overall System Health Score: 
85/100 - GOOD

Issues Found:
● High disk usage on /var (87%)
● 2 failed services
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

<p align="center">Made with ❤️ by System Administrators for System Administrators</p>
<p align="center">
  <a href="#-linux-admin-toolkit">Back to top ⬆️</a>
</p>
