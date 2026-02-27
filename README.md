Geek_Toolbox
Lightweight Android Partition Backup &amp; Restore Tool | Full Compatibility with Traditional / AB / VAB / AVB Devices

A ROOT-exclusive tool written purely in Shell, developed with AI assistance. It supports safe backup, restoration, and verification of boot partitions and EFS/modem partitions, automatically adapts to device partition types, features an interactive menu operation, requires no complex commands, is lightweight without redundancy, and is fully compatible with the sh environment for direct execution.

## 🌟 Core Features
- **Full Device Compatibility**: Automatically detects and is compatible with traditional single-partition/AB slot/VAB/AVB devices, no manual distinction required.
- **Physical-Level Extraction**: Optimized super partition mounting logic for VAB/AVB devices, bypasses mapper read-only restrictions, and directly extracts physical images.
- **Safe and Reliable**: Automatically performs file size verification + SHA1 checksum generation after backup, with supporting operation logs to avoid backup damage or loss.
- **Extremely Simple Operation**: Visual interactive menu with numeric selection for functions, allowing even beginners to get started quickly.
- **Auto-Cleanup**: Automatically unmounts mounted directories, restores SELinux status, and releases loop devices upon exit, leaving no device residues.
- **High-Risk Protection**: Dual manual confirmation is required for partition restoration to fundamentally avoid accidental overwriting of important partitions.
- **Low Dependencies**: Runs in a pure sh environment, relying only on Android's native basic commands, no additional software installation required.

## 📋 Supported Functions
- **Boot Partition Backup**: One-click backup of boot/init_boot/vendor_boot/recovery; AB/VAB devices automatically match the current slot.
- **EFS/Modem Backup**: Complete backup of modem-related partitions such as modemst1/modemst2/fsg/fsc/persist/modem; AB devices additionally back up slot modems.
- **Partition Restoration**: Write local backup images to specified device partitions (exclusive high-risk operation process).
- **Backup Verification**: Detect the integrity of the SHA1 verification file in the backup directory and verify backup validity.

## 🚀 Prerequisites
- The device has obtained ROOT permission (Magisk/KernelSU/other ROOT solutions are all acceptable).
- Recommended Terminal: MT Manager Terminal (best compatibility), also supports Adb Shell and Termux (additional storage mounting required).
- Free storage space in the backup directory ≥ 500MB.
- Device comes with basic commands: losetup / blockdev (the script will automatically detect).

## 📦 Quick Usage
### Step 1: Obtain the Script
Save the script as GeekToolbox.sh and upload it to any directory on the device (recommended: /sdcard/).

### Step 2: Add Execution Permissions
Execute the command in the terminal to grant executable permissions to the script:
```
chmod +x /sdcard/GeekToolbox.sh
```

### Step 3: Run the Script
Execute directly to automatically enter the interactive menu, and operate according to the prompts:
```
su
sh /sdcard/GeekToolbox.sh
```

### Step 4: Function Selection
Enter a number to select the corresponding function and press Enter to execute:
1 : Boot Partition Backup (recommended for first-time use)
2 : EFS/Modem Backup (important device modem partitions, recommended to be done)
3 : Partition Restoration (high-risk operation, only use when partitions are damaged)
4 : Verify Backup (verify if the backup file is complete)
0 : Exit the Script

## 📂 Backup Directory Description
- Default Directory: /sdcard/GeekToolbox/; the backup path can be customized during operation.
- File Structure:
  - Boot partition images: Directly stored in the root directory of the backup (e.g., boot_a.img / init_boot.img)
  - EFS/modem images: Stored in the backup directory/EFS/ subdirectory
  - Verification file: sha1sums.txt (SHA1 checksum of all valid backup images)
  - Device & Operation Log: backup_timestamp.log (includes device model, Android version, backup operation records)

## 📱 Automatic Device Detection
After the script runs, it will automatically detect the device partition type. Example terminal output:
```
Detecting device partition type...
Slot: _a / _b (A/B device) | none (Traditional device)
A/B: 1 (A/B slot device) | 0 (Traditional device)
VAB: 1 (VAB/AVB device) | 0 (Non-VAB device)
```

## ⚠️ Important Notes
### Partition Restoration (High-Risk Operation)
- Before restoration, be sure to confirm that the backup image completely matches the target device/partition; cross-device/cross-partition restoration will cause the device to brick.
- Enter the target partition name accurately (e.g., boot_b for AB devices, boot for traditional devices).
- Dual confirmation by entering YES is required for restoration; do not enter randomly.
- The device must be restarted after restoration, otherwise the modifications will not take effect.

### General Notes
- The script will temporarily turn off SELinux during operation and automatically restore it upon exit; no manual operation is required.
- VAB/AVB devices will prioritize the physical-level extraction method, and successful extraction will be clearly marked.
- After backup is completed, it is recommended to copy the backup files to a computer/cloud storage to prevent loss due to device storage damage.
- If a permission error is prompted, check if the terminal has been granted ROOT permission, or switch to MT Manager Terminal and try again.
- If a partition mounting problem occurs during operation, the script will automatically degrade to a compatible extraction method.

## ❓ Frequently Asked Questions
Q1: Prompt "Must be ROOT" when running?
A: Confirm that the terminal has obtained ROOT permission; some terminals require manual clicking of "Grant ROOT". It is recommended to switch to MT Manager Terminal and try again.

Q2: Prompt "Mount failed or no files" on VAB devices?
A: Check if the device is a real VAB/AVB device, restart the device and run again, ensuring that the super partition is not occupied by other programs.

Q3: No image files found after backup?
A: Check if the free storage space in the backup directory is ≥ 500MB, or view the log file in the backup directory to troubleshoot the specific reason.

Q4: Prompt "Partition does not exist" when restoring the partition?
A: Confirm that the entered partition name is correct; AB devices need to have a slot suffix (e.g., boot_a). The partition name can be verified through the device partition list.

Q5: SHA1 verification file is empty?
A: The checksum is only generated when the backup image file size ＞ 1024 bytes. An empty verification file is a normal phenomenon; you can directly check the image file size.

## 📄 License
This project is open-source based on the MIT License, allowing free modification, distribution, and use, supporting commercial/non-commercial use. Please retain the original project information after modification.

## 🚨 Disclaimer
This tool is only used for partition backup and restoration of legally owned personal devices. Do not use it for commercial purposes or illegal device operations.
Before use, please ensure that you have legal ownership of the device; do not use it on others' devices without authorization.
The project author shall not be liable for device bricking, data loss, etc., caused by misoperation, cross-device restoration, device hardware/system problems, etc.
Running this script means you have carefully read and agreed to all terms of this disclaimer.

---

## Adaptation Description

Compatible with Android 10+, tested with Magisk 26+/KernelSU 0.9+

| Architecture | Status | Tested Device |
|-------------|--------|---------------|
| VAB (Android 12+) | ✅ Verified | OnePlus Ace 2 Pro |
| A/B | ❓ Theoretically supported, unverified | - |
| Legacy | ✅ Verified | MI8 |

If you test on A/B or legacy devices, please report success/failure in [GitHub Issues](../../issues).

## Development Description

The shell script code of this tool is developed and compiled with the assistance of AI, and released after manual debugging and actual measurement verification.

[中文说明 | Chinese README](README_CN.md)
