#!/system/bin/sh

set -u
export LC_ALL=C

# § 颜色/样式
RED='\033[0;31m';    GREEN='\033[0;32m';   YELLOW='\033[0;33m'
BLUE='\033[0;34m';   CYAN='\033[0;36m';   PURPLE='\033[0;35m'
BOLD='\033[1m';      NC='\033[0m';         DIM='\033[2m'
LRED='\033[1;31m';   LGREEN='\033[1;32m'; LYELLOW='\033[1;33m'
LBLUE='\033[1;34m';  LCYAN='\033[1;36m';  LPURPLE='\033[1;35m'
WHITE='\033[1;37m'

# § 语言系统
LANG_FILE="/sdcard/GeekTool/lang_setting"
CURRENT_LANG="zh"

detect_system_language() {
    local sys_lang=""
    sys_lang=$(getprop persist.sys.locale 2>/dev/null | cut -d'-' -f1)
    [ -z "$sys_lang" ] && sys_lang=$(getprop ro.product.locale 2>/dev/null | cut -d'-' -f1)
    [ -z "$sys_lang" ] && sys_lang=$(getprop persist.sys.language 2>/dev/null)
    sys_lang=$(printf '%s' "$sys_lang" | tr '[:upper:]' '[:lower:]')
    case "$sys_lang" in
        zh*|cn*) CURRENT_LANG="zh" ;;
        en*|us*|uk*|gb*|au*) CURRENT_LANG="en" ;;
    esac
}

if [ -f "$LANG_FILE" ]; then
    CURRENT_LANG=$(grep -v '^#' "$LANG_FILE" 2>/dev/null | head -1)
    [ "$CURRENT_LANG" != "en" ] && [ "$CURRENT_LANG" != "zh" ] && CURRENT_LANG="zh"
else
    detect_system_language
fi

# 中文语言包
msg_zh() {
    case "$1" in
        "err_root")              echo "必须 ROOT 权限" ;;
        "press_enter")           echo "按回车返回主菜单" ;;
        "invalid_opt")           echo "无效选项" ;;
        "cancel")                echo "已取消" ;;
        "yes_confirm")           echo "输入 YES 确认" ;;
        "selinux_msg")           echo "SELinux Enforcing，已临时切换 Permissive" ;;
        "clean_selinux")         echo "SELinux 已恢复 Enforcing" ;;
        "clean_error")           echo "脚本异常退出 (错误码: %s)，已执行清理" ;;
        "bs_choice")             echo "选择 dd 块大小:" ;;
        "bs_1m")                 echo "1M  (推荐 · 速度快)" ;;
        "bs_4k")                 echo "4096 (最稳 · 速度慢)" ;;
        "bs_selected")           echo "块大小: $DD_BS" ;;
        "battery_low")           echo "电量低于 20%% (当前 %s%%)，可能导致意外关机！" ;;
        "battery_continue")      echo "仍要继续？" ;;
        "battery_ok")            echo "电量: %s%%" ;;
        "battery_skip")          echo "无法读取电量，跳过检查" ;;
        "mounted_warn")          echo "分区 %s 已被系统挂载，恢复可能损坏文件系统！" ;;
        "mounted_suggest")       echo "建议在 Recovery 模式下操作" ;;
        "mounted_force")         echo "输入 YES 强制继续（极不推荐）" ;;
        "path_choice")           echo "备份路径（回车默认: %s）: " ;;
        "path_create_fail")      echo "目录创建失败" ;;
        "path_space_unknown")    echo "无法检测可用空间，请确认 >500MB" ;;
        "path_space_low")        echo "空间不足(<500MB)，可用: %sMB" ;;
        "path_space_ok")         echo "可用空间: %sMB" ;;
        "path_compress")         echo "启用 gzip 压缩？(y/n, 默认n): " ;;
        "path_compress_on")      echo "已启用压缩 (.img.gz)" ;;
        "path_incremental")      echo "启用增量模式（跳过内容相同的分区）？(y/n, 默认n): " ;;
        "path_incremental_on")   echo "已启用增量模式" ;;
        "backup_start")          echo "备份: %s" ;;
        "backup_source")         echo "源: %s  大小: %s MB" ;;
        "backup_temp")           echo "写入临时镜像..." ;;
        "backup_dd_fail")        echo "dd 写入临时文件失败" ;;
        "backup_compressing")    echo "压缩中 (gzip)..." ;;
        "backup_compress_fail")  echo "压缩失败" ;;
        "backup_compress_done")  echo "压缩完成: %s" ;;
        "backup_dd_fail2")       echo "dd 命令失败" ;;
        "backup_done")           echo "备份完成: %s" ;;
        "backup_target_missing") echo "目标文件未生成" ;;
        "backup_checksum")       echo "校验码: %s..." ;;
        "backup_success_log")    echo "备份成功: %s (%s)" ;;
        "backup_fail_log")       echo "备份失败: %s 不存在 (%s)" ;;
        "backup_skip")           echo "%s 无变化，跳过" ;;
        "backup_changed")        echo "%s 内容已变化，重新备份" ;;
        "backup_check")          echo "检查 %s 内容变化..." ;;
        "part_not_exist")        echo "源分区不存在: %s" ;;
        "part_size_zero")        echo "无法获取分区大小，可能为空设备" ;;
        "progress_done")         echo "完成！" ;;
        "title")                 echo "Geek Toolbox v10.1" ;;
        "sys_info")              echo "系统信息" ;;
        "cpu")                   echo "CPU:" ;;
        "ram")                   echo "内存:" ;;
        "battery")               echo "电池:" ;;
        "slot")                  echo "当前槽位:" ;;
        "android")               echo "Android:" ;;
        "selinux")               echo "SELinux:" ;;
        "partition_type")        echo "分区类型:" ;;
        "main_menu")             echo "主菜单" ;;
        "menu_1")                echo "启动分区备份 (Boot/DTBO/VBMeta…)" ;;
        "menu_2")                echo "EFS / 基带备份" ;;
        "menu_3")                echo "Metadata 备份" ;;
        "menu_4")                echo "一键全选备份 (1+2+3)" ;;
        "menu_5")                echo "增量备份（基于已有目录）" ;;
        "menu_6")                echo "分区恢复（高危）" ;;
        "menu_7")                echo "校验备份完整性" ;;
        "menu_8")                echo "OTA Payload 在机提取  " ;;
        "menu_9")                echo "多云同步上传           " ;;
        "menu_a")                echo "自定义分区备份         " ;;
        "menu_b")                echo "备份目录管理           " ;;
        "menu_s")                echo "设置（语言 / dd块大小）" ;;
        "menu_0")                echo "退出" ;;
        "menu_prompt")           echo "请选择: " ;;
        "boot_title")            echo "启动分区备份" ;;
        "boot_success")          echo "成功: %s   失败: %s" ;;
        "efs_title")             echo "EFS/基带备份" ;;
        "efs_choice")            echo "备份方式:" ;;
        "efs_opt1")              echo "1) 单独备份每个分区（默认）" ;;
        "efs_opt2")              echo "2) 合并打包为 EFS.tar.gz" ;;
        "efs_temp")              echo "备份 %s 到临时目录..." ;;
        "efs_fail")              echo "备份 %s 失败" ;;
        "efs_packing")           echo "打包为 EFS.tar.gz..." ;;
        "efs_pack_done")         echo "打包完成: EFS.tar.gz" ;;
        "efs_pack_fail")         echo "打包失败" ;;
        "efs_pack_success")      echo "EFS 合并备份完成: %s 个分区" ;;
        "efs_single_success")    echo "EFS 单独备份完成: %s 个分区" ;;
        "metadata_title")        echo "Metadata 备份" ;;
        "metadata_not_found")    echo "未找到 metadata 分区" ;;
        "super_empty_not_found") echo "未找到 super_empty 分区" ;;
        "metadata_done")         echo "Metadata 备份完成: %s 个分区" ;;
        "all_done")              echo "全选备份完成" ;;
        "inc_title")             echo "增量备份" ;;
        "inc_base_dir")          echo "基准备份目录路径: " ;;
        "inc_dir_not_exist")     echo "目录不存在" ;;
        "inc_detect_gz")         echo "检测到 .gz 文件，启用压缩模式" ;;
        "inc_mode")              echo "增量模式：仅备份变动分区" ;;
        "inc_check")             echo "检查 %s..." ;;
        "inc_skip")              echo "%s 无变化，跳过" ;;
        "inc_changed")           echo "%s 已变化，备份中..." ;;
        "inc_done")              echo "增量备份完成" ;;
        "restore_title")         echo "分区恢复（高危）" ;;
        "restore_img_path")      echo "镜像文件路径 (.img 或 .img.gz): " ;;
        "restore_file_not_exist") echo "文件不存在" ;;
        "restore_part_name")     echo "目标分区名 (例: boot_a): " ;;
        "restore_part_not_exist") echo "分区不存在" ;;
        "restore_target")        echo "目标分区: %s" ;;
        "restore_part_size")     echo "分区大小: %s MB" ;;
        "restore_size_unknown")  echo "无法获取解压后大小，请自行确认空间" ;;
        "restore_size_exceed")   echo "镜像大小超过分区，无法写入" ;;
        "restore_size_small")    echo "镜像小于分区，仅写入前 %s MB" ;;
        "restore_calc_sha1")     echo "计算分区当前 SHA1..." ;;
        "restore_same_content")  echo "镜像与分区内容完全一致！" ;;
        "restore_force")         echo "是否强制覆盖？" ;;
        "restore_diff")          echo "内容不同，可以恢复" ;;
        "restore_sha1_skip")     echo "无法计算 SHA1，跳过内容比较" ;;
        "restore_backup")        echo "备份原分区至:" ;;
        "restore_backup_fail")   echo "原分区备份失败，是否继续？" ;;
        "restore_continue")      echo "继续？" ;;
        "restore_final_confirm") echo "最终确认：写入 %s → %s" ;;
        "restore_writing")       echo "写入中..." ;;
        "restore_success")       echo "写入成功！原备份位于:" ;;
        "restore_reboot")        echo "请立即重启设备" ;;
        "restore_fail")          echo "写入失败！尝试回滚..." ;;
        "restore_rollback_ok")   echo "已回滚到原分区" ;;
        "restore_rollback_fail") echo "回滚失败，请手动恢复: %s" ;;
        "verify_title")          echo "校验备份完整性" ;;
        "verify_dir")            echo "备份目录路径: " ;;
        "verify_dir_not_exist")  echo "目录不存在" ;;
        "verify_file_missing")   echo "未找到 sha1sums.txt" ;;
        "verify_total")          echo "共 %s 个文件，开始校验..." ;;
        "verify_checking")       echo "[%s/%s] %s ... " ;;
        "verify_lost")           echo "丢失" ;;
        "verify_ok")             echo "OK" ;;
        "verify_bad")            echo "损坏" ;;
        "verify_result")         echo "通过: %s   失败: %s" ;;
        "verify_all_ok")         echo "全部校验通过 ✓" ;;
        "verify_rebackup")       echo "建议重新备份" ;;
        "ota_title")             echo "OTA Payload 在机提取" ;;
        "ota_intro")             echo "从 payload.bin 直接提取分区镜像（无需电脑）" ;;
        "ota_path")              echo "payload.bin 路径: " ;;
        "ota_not_exist")         echo "文件不存在" ;;
        "ota_outdir")            echo "输出目录 (回车默认: %s): " ;;
        "ota_reading_manifest")  echo "解析 payload 清单..." ;;
        "ota_manifest_fail")     echo "清单解析失败，文件可能不完整或格式不支持" ;;
        "ota_partitions")        echo "清单中包含以下分区:" ;;
        "ota_select")            echo "提取哪些分区？(回车=全部, 或空格分隔名称): " ;;
        "ota_extracting")        echo "提取 %s..." ;;
        "ota_extract_ok")        echo "提取完成: %s → %s" ;;
        "ota_extract_fail")      echo "提取失败: %s" ;;
        "ota_done")              echo "Payload 提取完成，文件位于: %s" ;;
        "ota_tool_hint")         echo "提示: 安装 payload_dumper 可提升速度" ;;
        "ota_no_brotli")         echo "分区 %s 使用 Brotli 压缩，需要 brotli 工具解压" ;;
        "ota_lz4_decomp")        echo "使用 lz4 解压 %s..." ;;
        "ota_zip_hint")          echo "如果 payload.bin 在 zip 包内，请先手动解压" ;;
        "webdav_title")          echo "云备份 / WebDAV 上传" ;;
        "webdav_intro")          echo "将备份文件上传至 WebDAV 服务（Nextcloud / 坚果云等）" ;;
        "webdav_url")            echo "WebDAV 服务器地址 (例: https://dav.example.com/dav/): " ;;
        "webdav_user")           echo "用户名: " ;;
        "webdav_pass")           echo "密码 (输入不显示): " ;;
        "webdav_remote_dir")     echo "远端目录 (回车默认: /GeekTool/): " ;;
        "webdav_src_dir")        echo "本地备份目录: " ;;
        "webdav_test")           echo "测试连接..." ;;
        "webdav_test_ok")        echo "连接成功 ✓" ;;
        "webdav_test_fail")      echo "连接失败，请检查地址/账号/网络" ;;
        "webdav_mkdir")          echo "创建远端目录 %s..." ;;
        "webdav_uploading")      echo "上传 [%s/%s] %s..." ;;
        "webdav_upload_ok")      echo "上传成功: %s" ;;
        "webdav_upload_fail")    echo "上传失败: %s (已重试3次)" ;;
        "webdav_done")           echo "云备份完成: 成功 %s  失败 %s" ;;
        "webdav_no_curl")        echo "未找到 curl，WebDAV 上传需要 curl" ;;
        "webdav_save_cfg")       echo "保存配置以便下次使用？(y/n): " ;;
        "webdav_cfg_saved")      echo "配置已保存至 %s" ;;
        "webdav_cfg_load")       echo "检测到已保存配置，是否使用？(y/n): " ;;
        "webdav_resume")         echo "检测到同名远端文件，是否跳过（断点续传）？(y/n, 默认y): " ;;
        "webdav_tls_ask")        echo "TLS证书: 1=严格验证(推荐)  2=跳过验证(自签名证书): " ;;
        "webdav_tls_insecure_warn") echo "警告：已跳过TLS证书验证，连接不安全" ;;
        "webdav_tls_hint")       echo "如使用自签名证书，重新运行并选择跳过验证" ;;
        "mgr_title")             echo "备份目录管理" ;;
        "mgr_dir")               echo "备份目录路径: " ;;
        "mgr_no_backups")        echo "未找到备份文件" ;;
        "mgr_list_title")        echo "备份文件列表" ;;
        "mgr_total")             echo "共 %s 个文件，总计 %s MB" ;;
        "mgr_keep_ask")          echo "保留最新几份完整备份集？(数字，0=不清理): " ;;
        "mgr_keep_invalid")      echo "无效数字" ;;
        "mgr_nothing_to_del")    echo "无需清理" ;;
        "mgr_del_confirm")       echo "将删除 %s 个旧备份集（约 %s MB），确认？(YES): " ;;
        "mgr_deleting")          echo "删除: %s" ;;
        "mgr_done")              echo "清理完成，释放约 %s MB" ;;
        "custom_title")          echo "自定义分区备份" ;;
        "custom_hint")           echo "输入分区名（不含_a/_b后缀），多个用空格分隔" ;;
        "custom_prompt")         echo "分区名: " ;;
        "custom_not_found")      echo "未找到分区: %s（跳过）" ;;
        "engine_title")          echo "备份引擎选择" ;;
        "engine_current")        echo "当前引擎: %s" ;;
        "engine_dd")             echo "1) dd        — 通用，所有设备兼容（默认）" ;;
        "engine_sparse")         echo "2) simg2img  — 稀疏镜像，跳过全零块，节省空间（需要 simg2img）" ;;
        "engine_pigz")           echo "3) dd+pigz   — 多线程 gzip 压缩，速度快（需要 pigz）" ;;
        "engine_pbzip2")         echo "4) dd+pbzip2 — 多线程 bzip2 压缩，压缩率更高（需要 pbzip2）" ;;
        "engine_split")          echo "5) dd+split  — 分片输出，规避 FAT32 4GB 限制" ;;
        "engine_not_found")      echo "所选引擎 %s 未安装，已回退到 dd" ;;
        "engine_saved")          echo "引擎已设为: %s" ;;
        "engine_threads")        echo "并行线程数 (1-8，默认4): " ;;
        "engine_split_size")     echo "分片大小 (MB，默认2048): " ;;
        "engine_sparse_hint")    echo "稀疏模式：跳过全零块，适合 system/vendor 等已挂载分区" ;;
        "engine_writing")        echo "写入中 [%s 引擎]..." ;;
        "cloud_title")           echo "多云同步上传" ;;
        "cloud_backend_ask")     echo "选择云后端:" ;;
        "cloud_backend_webdav")  echo "1) WebDAV (Nextcloud / 坚果云 / 通用)" ;;
        "cloud_backend_rclone")  echo "2) rclone (Google Drive / S3 / OSS / 50+ 云)" ;;
        "cloud_backend_ftp")     echo "3) FTP / SFTP" ;;
        "cloud_rclone_missing")  echo "未检测到 rclone，请先安装: pkg install rclone 或从 rclone.org 下载" ;;
        "cloud_rclone_no_remote") echo "未找到 rclone 远端配置，请先运行: rclone config" ;;
        "cloud_rclone_remote")   echo "选择 rclone 远端 (输入名称): " ;;
        "cloud_rclone_path")     echo "远端路径 (默认 /GeekTool/): " ;;
        "cloud_ftp_host")        echo "FTP/SFTP 主机: " ;;
        "cloud_ftp_port")        echo "端口 (FTP=21 / SFTP=22): " ;;
        "cloud_ftp_user")        echo "用户名: " ;;
        "cloud_ftp_pass")        echo "密码: " ;;
        "cloud_ftp_proto")       echo "协议 (1=FTP  2=SFTP): " ;;
        "cloud_ftp_remote")      echo "远端路径: " ;;
        "cloud_uploading")       echo "上传中 [%s]: %s" ;;
        "cloud_done")            echo "云同步完成: 成功 %s / 失败 %s" ;;
        "settings_title")        echo "设置" ;;
        "lang_current")          echo "当前语言: 中文" ;;
        "lang_choice")           echo "选择语言 / Select language:" ;;
        "lang_zh")               echo "1) 中文" ;;
        "lang_en")               echo "2) English" ;;
        "lang_saved")            echo "语言已保存" ;;
        "bs_setting")            echo "dd 块大小设置" ;;
        "summary_title")         echo "本次操作摘要" ;;
        "summary_files")         echo "备份文件数: %s" ;;
        "summary_size")          echo "总大小: %s MB" ;;
        "summary_time")          echo "耗时: %s 秒" ;;
        "summary_dir")           echo "保存位置: %s" ;;
    esac
}

# 英文语言包
msg_en() {
    case "$1" in
        "err_root")              echo "Root permission required" ;;
        "press_enter")           echo "Press Enter to return to menu" ;;
        "invalid_opt")           echo "Invalid option" ;;
        "cancel")                echo "Cancelled" ;;
        "yes_confirm")           echo "Type YES to confirm" ;;
        "selinux_msg")           echo "SELinux Enforcing detected, switching to Permissive" ;;
        "clean_selinux")         echo "SELinux restored to Enforcing" ;;
        "clean_error")           echo "Script exited abnormally (code: %s), cleanup done" ;;
        "bs_choice")             echo "Select dd block size:" ;;
        "bs_1m")                 echo "1M  (Recommended · Fast)" ;;
        "bs_4k")                 echo "4096 (Stable · Slow)" ;;
        "bs_selected")           echo "Block size: $DD_BS" ;;
        "battery_low")           echo "Battery below 20%% (current %s%%), risk of shutdown!" ;;
        "battery_continue")      echo "Continue anyway?" ;;
        "battery_ok")            echo "Battery: %s%%" ;;
        "battery_skip")          echo "Cannot read battery info, skipping" ;;
        "mounted_warn")          echo "Partition %s is mounted, restoring may corrupt filesystem!" ;;
        "mounted_suggest")       echo "Recommended: reboot to Recovery mode" ;;
        "mounted_force")         echo "Type YES to force (highly unrecommended)" ;;
        "path_choice")           echo "Backup path (Enter for default: %s): " ;;
        "path_create_fail")      echo "Failed to create directory" ;;
        "path_space_unknown")    echo "Cannot check space, ensure >500MB available" ;;
        "path_space_low")        echo "Insufficient space (<500MB), available: %sMB" ;;
        "path_space_ok")         echo "Available space: %sMB" ;;
        "path_compress")         echo "Enable gzip compression? (y/n, default n): " ;;
        "path_compress_on")      echo "Compression enabled (.img.gz)" ;;
        "path_incremental")      echo "Enable incremental mode (skip unchanged)? (y/n, default n): " ;;
        "path_incremental_on")   echo "Incremental mode enabled" ;;
        "backup_start")          echo "Backup: %s" ;;
        "backup_source")         echo "Source: %s  Size: %s MB" ;;
        "backup_temp")           echo "Writing temporary image..." ;;
        "backup_dd_fail")        echo "dd to temp file failed" ;;
        "backup_compressing")    echo "Compressing (gzip)..." ;;
        "backup_compress_fail")  echo "Compression failed" ;;
        "backup_compress_done")  echo "Compression done: %s" ;;
        "backup_dd_fail2")       echo "dd command failed" ;;
        "backup_done")           echo "Backup complete: %s" ;;
        "backup_target_missing") echo "Target file not created" ;;
        "backup_checksum")       echo "Checksum: %s..." ;;
        "backup_success_log")    echo "Backup OK: %s (%s)" ;;
        "backup_fail_log")       echo "Backup failed: %s not found (%s)" ;;
        "backup_skip")           echo "%s unchanged, skipping" ;;
        "backup_changed")        echo "%s changed, re-backing up" ;;
        "backup_check")          echo "Checking %s for changes..." ;;
        "part_not_exist")        echo "Source partition not found: %s" ;;
        "part_size_zero")        echo "Cannot get partition size" ;;
        "progress_done")         echo "Done!" ;;
        "title")                 echo "Geek Toolbox v10.1" ;;
        "sys_info")              echo "System Info" ;;
        "cpu")                   echo "CPU:" ;;
        "ram")                   echo "RAM:" ;;
        "battery")               echo "Battery:" ;;
        "slot")                  echo "Current Slot:" ;;
        "android")               echo "Android:" ;;
        "selinux")               echo "SELinux:" ;;
        "partition_type")        echo "Partition:" ;;
        "main_menu")             echo "Main Menu" ;;
        "menu_1")                echo "Boot Partitions Backup (Boot/DTBO/VBMeta…)" ;;
        "menu_2")                echo "EFS / Modem Backup" ;;
        "menu_3")                echo "Metadata Backup" ;;
        "menu_4")                echo "One-Click Full Backup (1+2+3)" ;;
        "menu_5")                echo "Incremental Backup" ;;
        "menu_6")                echo "Partition Restore (High Risk)" ;;
        "menu_7")                echo "Verify Backup Integrity" ;;
        "menu_8")                echo "OTA Payload On-Device Extract  " ;;
        "menu_9")                echo "Multi-Cloud Sync Upload        " ;;
        "menu_a")                echo "Custom Partition Backup        " ;;
        "menu_b")                echo "Backup Directory Manager       " ;;
        "menu_s")                echo "Settings (Language / Block Size)" ;;
        "menu_0")                echo "Exit" ;;
        "menu_prompt")           echo "Select: " ;;
        "boot_title")            echo "Boot Partitions Backup" ;;
        "boot_success")          echo "Success: %s   Failed: %s" ;;
        "efs_title")             echo "EFS/Modem Backup" ;;
        "efs_choice")            echo "Backup method:" ;;
        "efs_opt1")              echo "1) Backup each partition separately (default)" ;;
        "efs_opt2")              echo "2) Package as EFS.tar.gz" ;;
        "efs_temp")              echo "Backing up %s to temp dir..." ;;
        "efs_fail")              echo "Backup %s failed" ;;
        "efs_packing")           echo "Packaging as EFS.tar.gz..." ;;
        "efs_pack_done")         echo "Package complete: EFS.tar.gz" ;;
        "efs_pack_fail")         echo "Packaging failed" ;;
        "efs_pack_success")      echo "EFS package backup complete: %s partitions" ;;
        "efs_single_success")    echo "EFS separate backup complete: %s partitions" ;;
        "metadata_title")        echo "Metadata Backup" ;;
        "metadata_not_found")    echo "metadata partition not found" ;;
        "super_empty_not_found") echo "super_empty partition not found" ;;
        "metadata_done")         echo "Metadata backup complete: %s partitions" ;;
        "all_done")              echo "One-Click Full Backup Complete" ;;
        "inc_title")             echo "Incremental Backup" ;;
        "inc_base_dir")          echo "Base backup directory path: " ;;
        "inc_dir_not_exist")     echo "Directory does not exist" ;;
        "inc_detect_gz")         echo "Detected .gz files, enabling compression mode" ;;
        "inc_mode")              echo "Incremental mode: only backup changed partitions" ;;
        "inc_check")             echo "Checking %s..." ;;
        "inc_skip")              echo "%s unchanged, skipping" ;;
        "inc_changed")           echo "%s changed, backing up..." ;;
        "inc_done")              echo "Incremental backup complete" ;;
        "restore_title")         echo "Partition Restore (High Risk)" ;;
        "restore_img_path")      echo "Image path (.img or .img.gz): " ;;
        "restore_file_not_exist") echo "File does not exist" ;;
        "restore_part_name")     echo "Target partition name (e.g. boot_a): " ;;
        "restore_part_not_exist") echo "Partition not found" ;;
        "restore_target")        echo "Target: %s" ;;
        "restore_part_size")     echo "Partition size: %s MB" ;;
        "restore_size_unknown")  echo "Cannot get uncompressed size, confirm space manually" ;;
        "restore_size_exceed")   echo "Image exceeds partition size, cannot write" ;;
        "restore_size_small")    echo "Image smaller than partition, writing first %s MB only" ;;
        "restore_calc_sha1")     echo "Calculating current partition SHA1..." ;;
        "restore_same_content")  echo "Image is identical to current partition!" ;;
        "restore_force")         echo "Force overwrite?" ;;
        "restore_diff")          echo "Content differs, proceed with restore" ;;
        "restore_sha1_skip")     echo "Cannot calculate SHA1, skipping comparison" ;;
        "restore_backup")        echo "Backing up original partition to:" ;;
        "restore_backup_fail")   echo "Original partition backup failed, continue?" ;;
        "restore_continue")      echo "Continue?" ;;
        "restore_final_confirm") echo "Final confirmation: Write %s → %s" ;;
        "restore_writing")       echo "Writing..." ;;
        "restore_success")       echo "Write successful! Backup at:" ;;
        "restore_reboot")        echo "Please reboot immediately" ;;
        "restore_fail")          echo "Write failed! Attempting rollback..." ;;
        "restore_rollback_ok")   echo "Rolled back to original partition" ;;
        "restore_rollback_fail") echo "Rollback failed, restore manually: %s" ;;
        "verify_title")          echo "Verify Backup Integrity" ;;
        "verify_dir")            echo "Backup directory: " ;;
        "verify_dir_not_exist")  echo "Directory not found" ;;
        "verify_file_missing")   echo "sha1sums.txt not found" ;;
        "verify_total")          echo "Total %s files, starting verification..." ;;
        "verify_checking")       echo "[%s/%s] %s ... " ;;
        "verify_lost")           echo "MISSING" ;;
        "verify_ok")             echo "OK" ;;
        "verify_bad")            echo "CORRUPT" ;;
        "verify_result")         echo "Passed: %s   Failed: %s" ;;
        "verify_all_ok")         echo "All checks passed ✓" ;;
        "verify_rebackup")       echo "Recommend re-backup" ;;
        "ota_title")             echo "OTA Payload On-Device Extract" ;;
        "ota_intro")             echo "Extract partition images from payload.bin without a PC" ;;
        "ota_path")              echo "Path to payload.bin: " ;;
        "ota_not_exist")         echo "File not found" ;;
        "ota_outdir")            echo "Output directory (Enter for default: %s): " ;;
        "ota_reading_manifest")  echo "Parsing payload manifest..." ;;
        "ota_manifest_fail")     echo "Manifest parse failed. File may be incomplete or unsupported." ;;
        "ota_partitions")        echo "Partitions in manifest:" ;;
        "ota_select")            echo "Which partitions to extract? (Enter=all, or space-separated names): " ;;
        "ota_extracting")        echo "Extracting %s..." ;;
        "ota_extract_ok")        echo "Extracted: %s → %s" ;;
        "ota_extract_fail")      echo "Extraction failed: %s" ;;
        "ota_done")              echo "Payload extraction complete. Files at: %s" ;;
        "ota_tool_hint")         echo "Tip: install payload_dumper for faster extraction" ;;
        "ota_no_brotli")         echo "Partition %s uses Brotli compression, brotli tool required" ;;
        "ota_lz4_decomp")        echo "Decompressing %s with lz4..." ;;
        "ota_zip_hint")          echo "If payload.bin is inside a zip, extract it first" ;;
        "webdav_title")          echo "Cloud Backup / WebDAV Upload" ;;
        "webdav_intro")          echo "Upload backups to WebDAV server (Nextcloud, etc.)" ;;
        "webdav_url")            echo "WebDAV server URL (e.g. https://dav.example.com/dav/): " ;;
        "webdav_user")           echo "Username: " ;;
        "webdav_pass")           echo "Password (hidden): " ;;
        "webdav_remote_dir")     echo "Remote directory (Enter for default: /GeekTool/): " ;;
        "webdav_src_dir")        echo "Local backup directory: " ;;
        "webdav_test")           echo "Testing connection..." ;;
        "webdav_test_ok")        echo "Connection successful ✓" ;;
        "webdav_test_fail")      echo "Connection failed. Check URL/credentials/network." ;;
        "webdav_mkdir")          echo "Creating remote directory %s..." ;;
        "webdav_uploading")      echo "Uploading [%s/%s] %s..." ;;
        "webdav_upload_ok")      echo "Uploaded: %s" ;;
        "webdav_upload_fail")    echo "Upload failed: %s (retried 3x)" ;;
        "webdav_done")           echo "Cloud backup done: success %s  failed %s" ;;
        "webdav_no_curl")        echo "curl not found. WebDAV upload requires curl." ;;
        "webdav_save_cfg")       echo "Save config for next time? (y/n): " ;;
        "webdav_cfg_saved")      echo "Config saved to %s" ;;
        "webdav_cfg_load")       echo "Saved config found. Use it? (y/n): " ;;
        "webdav_resume")         echo "Remote file exists. Skip (resume)? (y/n, default y): " ;;
        "webdav_tls_ask")        echo "TLS cert: 1=Verify (recommended)  2=Skip (self-signed): " ;;
        "webdav_tls_insecure_warn") echo "Warning: TLS cert verification disabled, connection insecure" ;;
        "webdav_tls_hint")       echo "If using self-signed cert, re-run and choose skip verification" ;;
        "mgr_title")             echo "Backup Directory Manager" ;;
        "mgr_dir")               echo "Backup directory path: " ;;
        "mgr_no_backups")        echo "No backup files found" ;;
        "mgr_list_title")        echo "Backup File List" ;;
        "mgr_total")             echo "Total %s files, %s MB" ;;
        "mgr_keep_ask")          echo "How many backup sets to keep? (number, 0=no cleanup): " ;;
        "mgr_keep_invalid")      echo "Invalid number" ;;
        "mgr_nothing_to_del")    echo "Nothing to clean up" ;;
        "mgr_del_confirm")       echo "Will delete %s old backup sets (~%s MB). Confirm? (YES): " ;;
        "mgr_deleting")          echo "Deleting: %s" ;;
        "mgr_done")              echo "Cleanup done, freed ~%s MB" ;;
        "custom_title")          echo "Custom Partition Backup" ;;
        "custom_hint")           echo "Enter partition names (without _a/_b suffix), space-separated" ;;
        "custom_prompt")         echo "Partition names: " ;;
        "custom_not_found")      echo "Partition not found: %s (skipping)" ;;
        "engine_title")          echo "Backup Engine Selection" ;;
        "engine_current")        echo "Current engine: %s" ;;
        "engine_dd")             echo "1) dd        — Universal, works on all devices (default)" ;;
        "engine_sparse")         echo "2) simg2img  — Sparse image, skip zero blocks, saves space (needs simg2img)" ;;
        "engine_pigz")           echo "3) dd+pigz   — Multi-thread gzip compression, fast (needs pigz)" ;;
        "engine_pbzip2")         echo "4) dd+pbzip2 — Multi-thread bzip2, higher ratio (needs pbzip2)" ;;
        "engine_split")          echo "5) dd+split  — Split output, bypass FAT32 4GB limit" ;;
        "engine_not_found")      echo "Engine %s not installed, falling back to dd" ;;
        "engine_saved")          echo "Engine set to: %s" ;;
        "engine_threads")        echo "Parallel threads (1-8, default 4): " ;;
        "engine_split_size")     echo "Split size in MB (default 2048): " ;;
        "engine_sparse_hint")    echo "Sparse mode: skips zero blocks, best for system/vendor partitions" ;;
        "engine_writing")        echo "Writing [%s engine]..." ;;
        "cloud_title")           echo "Multi-Cloud Sync Upload" ;;
        "cloud_backend_ask")     echo "Select cloud backend:" ;;
        "cloud_backend_webdav")  echo "1) WebDAV (Nextcloud / any WebDAV server)" ;;
        "cloud_backend_rclone")  echo "2) rclone (Google Drive / S3 / OSS / 50+ clouds)" ;;
        "cloud_backend_ftp")     echo "3) FTP / SFTP" ;;
        "cloud_rclone_missing")  echo "rclone not found. Install: pkg install rclone  or  rclone.org" ;;
        "cloud_rclone_no_remote") echo "No rclone remotes configured. Run: rclone config" ;;
        "cloud_rclone_remote")   echo "Select rclone remote (enter name): " ;;
        "cloud_rclone_path")     echo "Remote path (default /GeekTool/): " ;;
        "cloud_ftp_host")        echo "FTP/SFTP host: " ;;
        "cloud_ftp_port")        echo "Port (FTP=21 / SFTP=22): " ;;
        "cloud_ftp_user")        echo "Username: " ;;
        "cloud_ftp_pass")        echo "Password: " ;;
        "cloud_ftp_proto")       echo "Protocol (1=FTP  2=SFTP): " ;;
        "cloud_ftp_remote")      echo "Remote path: " ;;
        "cloud_uploading")       echo "Uploading [%s]: %s" ;;
        "cloud_done")            echo "Cloud sync done: success %s / failed %s" ;;
        "settings_title")        echo "Settings" ;;
        "lang_current")          echo "Current language: English" ;;
        "lang_choice")           echo "请选择语言 / Select language:" ;;
        "lang_zh")               echo "1) 中文" ;;
        "lang_en")               echo "2) English" ;;
        "lang_saved")            echo "Language saved" ;;
        "bs_setting")            echo "dd Block Size Setting" ;;
        "summary_title")         echo "Operation Summary" ;;
        "summary_files")         echo "Files backed up: %s" ;;
        "summary_size")          echo "Total size: %s MB" ;;
        "summary_time")          echo "Elapsed: %s seconds" ;;
        "summary_dir")           echo "Location: %s" ;;
    esac
}

# 消息输出封装
get_msg() {
    if [ "$CURRENT_LANG" = "en" ]; then msg_en "$1"; else msg_zh "$1"; fi
}

print_msg() {
    local key="$1"; shift
    local msg; msg=$(get_msg "$key")
    if [ $# -gt 0 ]; then printf "$msg" "$@"; else printf '%s' "$msg"; fi
}

# § 全局变量
DEFAULT_BACKUP="/sdcard/GeekTool"
WEBDAV_CFG="/sdcard/GeekTool/.webdav_cfg"
BASE_COMMON="/dev/block/by-name"
BASE_BOOTDEV="/dev/block/bootdevice/by-name"
BASE_MAPPER="/dev/block/mapper"
LOGFILE=""
SLOT=""
OTHER_SLOT=""
IS_AB=0
IS_DYNAMIC=0
BACKUP_DIR=""
SELINUX_WAS_ENFORCING=0
MNT_VAB="/mnt/vab_super"
USE_COMPRESS=0
PATH_SELECTED=0
INCREMENTAL_MODE=0
DD_BS="1M"
# 引擎: dd|sparse|pigz|pbzip2|split
BACKUP_ENGINE="dd"
ENGINE_THREADS=4
ENGINE_SPLIT_MB=2048
OP_START_TIME=0
OP_FILE_COUNT=0
OP_TOTAL_BYTES=0

# § 清理/退出

# 写入中的临时文件列表，中断时由 cleanup 删除
ACTIVE_TMP_FILES=""

# 注册临时文件
register_tmp() { ACTIVE_TMP_FILES="$ACTIVE_TMP_FILES $1"; }

# 注销临时文件
unregister_tmp() {
    local target="$1" new_list=""
    for f in $ACTIVE_TMP_FILES; do
        [ "$f" != "$target" ] && new_list="$new_list $f"
    done
    ACTIVE_TMP_FILES="$new_list"
}

cleanup() {
    local ec=${1:-$?}
    set +e

    # 清理中断产生的不完整文件
    for tmp in $ACTIVE_TMP_FILES; do
        if [ -f "$tmp" ] || [ -d "$tmp" ]; then
            rm -rf "$tmp" 2>/dev/null
            echo -e "\n${YELLOW}[!] Removed incomplete file: $(basename "$tmp")${NC}"
            log_msg "W" "Removed incomplete file on exit: $tmp"
        fi
    done

    sync
    umount "$MNT_VAB" 2>/dev/null || true
    rm -rf "$MNT_VAB" 2>/dev/null || true
    if [ "${SELINUX_WAS_ENFORCING:-0}" -eq 1 ]; then
        setenforce 1 2>/dev/null || true
        echo -e "\n${YELLOW}[!] $(print_msg "clean_selinux")${NC}"
    fi
    if [ $ec -ne 0 ] && [ $ec -ne 130 ] && [ $ec -ne 143 ]; then
        echo -e "\n${RED}[!] $(print_msg "clean_error" "$ec")${NC}"
    fi
    exit "$ec"
}
trap cleanup EXIT INT TERM

# § UI 组件
print_banner() {
    clear
    local title; title=$(print_msg "title")
    echo -e "${LCYAN}──────────────────────────${NC}"
    echo -e "  ${BOLD}${LGREEN}${title}${NC}"
    echo -e "${LCYAN}──────────────────────────${NC}"
}

# 分节标题
section() {
    local icon="$1" label="$2" color="${3:-$LCYAN}"
    echo -e "\n${color}── ${icon} ${label}${NC}"
}

# 操作摘要
print_summary() {
    local end_time; end_time=$(date +%s)
    local elapsed=$(( end_time - OP_START_TIME ))
    local total_mb=$(( OP_TOTAL_BYTES / 1024 / 1024 ))
    echo -e "\n${LPURPLE}── $(print_msg "summary_title") ──${NC}"
    echo -e "  ${CYAN}$(print_msg "summary_files" "$OP_FILE_COUNT")${NC}"
    echo -e "  ${CYAN}$(print_msg "summary_size"  "$total_mb")${NC}"
    echo -e "  ${CYAN}$(print_msg "summary_time"  "$elapsed")${NC}"
    echo -e "  ${CYAN}$(print_msg "summary_dir"   "$BACKUP_DIR")${NC}"
}

# § 工具函数
confirm() {
    echo -en "${YELLOW}$(print_msg "$1") (yes/no)${NC} "
    read -r ans
    [ "$ans" = "yes" ]
}

confirm_yes() {
    echo -en "${RED}[!] $(print_msg "$1") (YES)${NC} "
    read -r ans
    [ "$ans" = "YES" ]
}

log_msg() {
    local level="$1" msg="$2"
    local ts; ts=$(date '+%Y-%m-%d %H:%M:%S')
    [ -n "$LOGFILE" ] && echo "[$ts] [$level] $msg" >> "$LOGFILE"
    log -t "GeekToolbox" -p "$level" "$msg" 2>/dev/null || true
}

find_part() {
    local name="$1"
    for path in "$BASE_COMMON/$name" "$BASE_BOOTDEV/$name" "$BASE_MAPPER/$name"; do
        [ -e "$path" ] && echo "$path" && return
    done
    echo ""
}

get_part_size() {
    blockdev --getsize64 "$1" 2>/dev/null || echo 0
}

compute_sha1() {
    if [ "$1" = "-" ]; then
        sha1sum 2>/dev/null | awk '{print $1}'
    else
        sha1sum "$1" 2>/dev/null | awk '{print $1}'
    fi
}

check_battery() {
    local cap="/sys/class/power_supply/battery/capacity"
    if [ -f "$cap" ]; then
        local b; b=$(cat "$cap")
        if [ "$b" -lt 20 ]; then
            echo -e "${LRED}[!] $(print_msg "battery_low" "$b")${NC}"
            confirm "battery_continue" || return 1
        else
            echo -e "${GREEN}[✓] $(print_msg "battery_ok" "$b")${NC}"
        fi
    else
        echo -e "${YELLOW}[!] $(print_msg "battery_skip")${NC}"
    fi
    return 0
}

check_mounted() {
    local part="$1"
    local real_part; real_part=$(realpath "$part" 2>/dev/null || echo "$part")
    if grep -q "^$real_part " /proc/mounts 2>/dev/null; then
        echo -e "${LRED}[!] $(print_msg "mounted_warn" "$part")${NC}"
        echo -e "${YELLOW}$(print_msg "mounted_suggest")${NC}"
        confirm_yes "mounted_force" || return 1
    fi
    return 0
}

detect_device_type() {
    SLOT=$(getprop ro.boot.slot_suffix 2>/dev/null | tr -d '[:space:]')
    if [ -n "$SLOT" ] && [ -n "$(find_part "boot${SLOT}")" ]; then
        IS_AB=1
        [ "$SLOT" = "_a" ] && OTHER_SLOT="_b" || OTHER_SLOT="_a"
    else
        SLOT=""; OTHER_SLOT=""; IS_AB=0
    fi
    if [ -n "$(find_part super)" ]; then IS_DYNAMIC=1; else IS_DYNAMIC=0; fi
}

# § 多引擎备份系统

# 进度条（所有引擎共用）
_show_progress() {
    local pid=$1 dst=$2 total_size=$3 start=$4
    local use_proc_io=1
    sleep 0.1
    if ! awk '/^read_bytes/' /proc/$pid/io >/dev/null 2>&1; then
        use_proc_io=0
    fi
    while kill -0 $pid 2>/dev/null; do
        local read_bytes=0
        if [ "$use_proc_io" -eq 1 ]; then
            read_bytes=$(awk '/^read_bytes/{print $2}' /proc/$pid/io 2>/dev/null || echo 0)
        else
            read_bytes=$(wc -c < "$dst" 2>/dev/null || echo 0)
        fi
        local pct=$(( read_bytes * 100 / total_size ))
        [ $pct -gt 100 ] && pct=100
        local now; now=$(date +%s)
        local diff=$(( now - start )); [ $diff -eq 0 ] && diff=1
        local speed=$(( read_bytes / diff / 1024 / 1024 ))
        local filled=$(( pct / 4 ))
        local bar; bar=$(printf "%${filled}s" | tr ' ' '━')
        local space; space=$(printf "%$((25 - filled))s")
        printf "\r\033[K${LPURPLE}┠${LGREEN}%s${WHITE}%s${LPURPLE}┨ ${LBLUE}%d%%${NC} | ${LYELLOW}%d MB/s${NC}" \
            "$bar" "$space" "$pct" "$speed"
        usleep 200000 2>/dev/null || sleep 1
    done
    wait $pid
}

# 引擎1: dd
run_dd_with_progress() {
    local src="$1" dst="$2" bs="$3" total_size="$4"
    [ "$total_size" -le 0 ] && total_size=$(get_part_size "$src")
    [ "$total_size" -le 0 ] && total_size=1
    local dd_ret_file; dd_ret_file="${dst}.dd_ret.tmp"
    local start; start=$(date +%s)
    ( dd if="$src" of="$dst" bs="$bs" conv=fsync >/dev/null 2>&1; echo $? > "$dd_ret_file" ) &
    local pid=$!
    _show_progress "$pid" "$dst" "$total_size" "$start"
    local real_ret=1
    [ -f "$dd_ret_file" ] && { real_ret=$(cat "$dd_ret_file"); rm -f "$dd_ret_file"; }
    if [ "$real_ret" -eq 0 ]; then
        printf "\r\033[K${LGREEN}┗━━━━━━━━━━━━━━━━━━━━━━━━━┛ 100%% $(print_msg "progress_done")${NC}\n"
    else
        printf "\r\033[K${RED}[!] dd failed (exit %d)${NC}\n" "$real_ret"
    fi
    return "$real_ret"
}

# 引擎2: simg2img（非sparse自动降级为dd）
_run_sparse() {
    local src="$1" dst="$2" total_size="$3"
    if ! command -v simg2img >/dev/null 2>&1; then
        echo -e "\n${YELLOW}[!] $(print_msg "engine_not_found" "simg2img") → dd${NC}"
        run_dd_with_progress "$src" "$dst" "$DD_BS" "$total_size"
        return $?
    fi
    # 检测是否为 sparse image（magic 0xed26ff3a）
    local magic; magic=$(dd if="$src" bs=4 count=1 2>/dev/null | od -An -tx4 | tr -d ' \n')
    if [ "$magic" = "3aff26ed" ]; then
        echo -e "    ${DIM}$(print_msg "engine_sparse_hint")${NC}"
        local ret_file; ret_file="${dst}.sp_ret.tmp"
        local start; start=$(date +%s)
        ( simg2img "$src" "$dst" >/dev/null 2>&1; echo $? > "$ret_file" ) &
        local pid=$!
        _show_progress "$pid" "$dst" "$total_size" "$start"
        local real_ret=1
        [ -f "$ret_file" ] && { real_ret=$(cat "$ret_file"); rm -f "$ret_file"; }
        if [ "$real_ret" -eq 0 ]; then
            printf "\r\033[K${LGREEN}┗━━━━━━━━━━━━━━━━━━━━━━━━━┛ 100%% $(print_msg "progress_done") [sparse]${NC}\n"
        else
            printf "\r\033[K${YELLOW}[!] simg2img failed, fallback to dd${NC}\n"
            run_dd_with_progress "$src" "$dst" "$DD_BS" "$total_size"
            return $?
        fi
        return "$real_ret"
    else
        # 非 sparse，直接 dd
        run_dd_with_progress "$src" "$dst" "$DD_BS" "$total_size"
        return $?
    fi
}

# 引擎3: dd+pigz 多线程gzip
_run_pigz() {
    local src="$1" dst_gz="$2" total_size="$3"
    local threads="${ENGINE_THREADS:-4}"
    if ! command -v pigz >/dev/null 2>&1; then
        echo -e "\n${YELLOW}[!] $(print_msg "engine_not_found" "pigz") → gzip${NC}"
        local tmp="${dst_gz%.gz}.tmp"
        register_tmp "$tmp"
        if run_dd_with_progress "$src" "$tmp" "$DD_BS" "$total_size"; then
            sync
            gzip -c "$tmp" > "$dst_gz" && rm -f "$tmp"
            unregister_tmp "$tmp"
            return 0
        fi
        rm -f "$tmp"; unregister_tmp "$tmp"; return 1
    fi
    local ret_file; ret_file="${dst_gz}.pg_ret.tmp"
    local start; start=$(date +%s)
    # 管道两侧均检查：通过命名管道（fifo）分离 dd 和 pigz 的退出码
    # 原理：在子 shell 内用 { dd; echo dd_exit } | { pigz; echo pigz_exit }
    # 最简可靠做法：用临时 fifo，dd → fifo → pigz，各自独立检查
    local fifo; fifo="${dst_gz}.fifo.tmp"
    mkfifo "$fifo" 2>/dev/null || { fifo=""; }   # 若 mkfifo 不可用则降级
    if [ -n "$fifo" ]; then
        local dd_ret_f="${dst_gz}.dd_r.tmp" pigz_ret_f="${dst_gz}.pigz_r.tmp"
        ( dd if="$src" bs="$DD_BS" 2>/dev/null > "$fifo"; echo $? > "$dd_ret_f" ) &
        local dd_pid=$!
        ( pigz -p "$threads" -c < "$fifo" > "$dst_gz" 2>/dev/null; echo $? > "$pigz_ret_f" ) &
        local pigz_pid=$!
        local est_total=$(( total_size / 2 )); [ "$est_total" -le 0 ] && est_total=1
        _show_progress "$pigz_pid" "$dst_gz" "$est_total" "$start"
        wait "$dd_pid" 2>/dev/null; wait "$pigz_pid" 2>/dev/null
        rm -f "$fifo"
        local dd_ret=1 pigz_ret=1
        [ -f "$dd_ret_f" ]   && { dd_ret=$(cat "$dd_ret_f");   rm -f "$dd_ret_f"; }
        [ -f "$pigz_ret_f" ] && { pigz_ret=$(cat "$pigz_ret_f"); rm -f "$pigz_ret_f"; }
        local real_ret=0
        [ "$dd_ret"   -ne 0 ] && { printf "\r\033[K${RED}[!] pigz pipeline: dd failed (exit %d)${NC}\n"   "$dd_ret";   real_ret=1; }
        [ "$pigz_ret" -ne 0 ] && { printf "\r\033[K${RED}[!] pigz pipeline: pigz failed (exit %d)${NC}\n" "$pigz_ret"; real_ret=1; }
    else
        # fifo 不可用：降级为单管道，只能检查压缩侧
        ( dd if="$src" bs="$DD_BS" 2>/dev/null \
            | pigz -p "$threads" -c > "$dst_gz" 2>/dev/null
          echo $? > "$ret_file" ) &
        local pid=$!
        local est_total=$(( total_size / 2 )); [ "$est_total" -le 0 ] && est_total=1
        _show_progress "$pid" "$dst_gz" "$est_total" "$start"
        local real_ret=1
        [ -f "$ret_file" ] && { real_ret=$(cat "$ret_file"); rm -f "$ret_file"; }
    fi
    rm -f "$ret_file" 2>/dev/null
    if [ "$real_ret" -eq 0 ]; then
        printf "\r\033[K${LGREEN}┗━━━━━━━━━━━━━━━━━━━━━━━━━┛ 100%% $(print_msg "progress_done") [pigz×%d]${NC}\n" "$threads"
    fi
    return "$real_ret"
}

# 引擎4: dd+pbzip2 多线程bzip2
_run_pbzip2() {
    local src="$1" dst_bz="$2" total_size="$3"
    local threads="${ENGINE_THREADS:-4}"
    if ! command -v pbzip2 >/dev/null 2>&1; then
        echo -e "\n${YELLOW}[!] $(print_msg "engine_not_found" "pbzip2") → pigz/gzip${NC}"
        _run_pigz "$src" "${dst_bz%.bz2}.gz" "$total_size"
        return $?
    fi
    local ret_file; ret_file="${dst_bz}.pb_ret.tmp"
    local start; start=$(date +%s)
    local est_total=$(( total_size * 85 / 100 ))
    [ "$est_total" -le 0 ] && est_total=1
    # 同 pigz：用 fifo 分离两侧退出码
    local fifo; fifo="${dst_bz}.fifo.tmp"
    mkfifo "$fifo" 2>/dev/null || { fifo=""; }
    local real_ret=0
    if [ -n "$fifo" ]; then
        local dd_ret_f="${dst_bz}.dd_r.tmp" pb_ret_f="${dst_bz}.pb_r.tmp"
        ( dd if="$src" bs="$DD_BS" 2>/dev/null > "$fifo"; echo $? > "$dd_ret_f" ) &
        local dd_pid=$!
        ( pbzip2 -p"$threads" -c < "$fifo" > "$dst_bz" 2>/dev/null; echo $? > "$pb_ret_f" ) &
        local pb_pid=$!
        _show_progress "$pb_pid" "$dst_bz" "$est_total" "$start"
        wait "$dd_pid" 2>/dev/null; wait "$pb_pid" 2>/dev/null
        rm -f "$fifo"
        local dd_ret=1 pb_ret=1
        [ -f "$dd_ret_f" ] && { dd_ret=$(cat "$dd_ret_f"); rm -f "$dd_ret_f"; }
        [ -f "$pb_ret_f" ] && { pb_ret=$(cat "$pb_ret_f"); rm -f "$pb_ret_f"; }
        [ "$dd_ret" -ne 0 ] && { printf "\r\033[K${RED}[!] pbzip2 pipeline: dd failed (exit %d)${NC}\n"     "$dd_ret"; real_ret=1; }
        [ "$pb_ret" -ne 0 ] && { printf "\r\033[K${RED}[!] pbzip2 pipeline: pbzip2 failed (exit %d)${NC}\n" "$pb_ret"; real_ret=1; }
    else
        ( dd if="$src" bs="$DD_BS" 2>/dev/null \
            | pbzip2 -p"$threads" -c > "$dst_bz" 2>/dev/null
          echo $? > "$ret_file" ) &
        local pid=$!
        _show_progress "$pid" "$dst_bz" "$est_total" "$start"
        [ -f "$ret_file" ] && { real_ret=$(cat "$ret_file"); rm -f "$ret_file"; }
    fi
    rm -f "$ret_file" 2>/dev/null
    if [ "$real_ret" -eq 0 ]; then
        printf "\r\033[K${LGREEN}┗━━━━━━━━━━━━━━━━━━━━━━━━━┛ 100%% $(print_msg "progress_done") [pbzip2×%d]${NC}\n" "$threads"
    fi
    return "$real_ret"
}

# 引擎5: dd+split（规避FAT32 4GB限制，分片命名 .img.part_aa/ab...）
_run_split() {
    local src="$1" dst_base="$2" total_size="$3"
    local split_mb="${ENGINE_SPLIT_MB:-2048}"
    local split_bytes=$(( split_mb * 1024 * 1024 ))
    local split_prefix="${dst_base}.img.part_"
    local ret_file; ret_file="${dst_base}.sp2_ret.tmp"
    local start; start=$(date +%s)

    local counter_file; counter_file="${dst_base}.written.tmp"
    echo 0 > "$counter_file"
    ( dd if="$src" bs="$DD_BS" 2>/dev/null \
        | split -b "${split_mb}m" - "$split_prefix" 2>/dev/null
      echo $? > "$ret_file" ) &
    local pid=$!
    # 进度：累计各分片大小
    local start_t; start_t=$(date +%s)
    while kill -0 $pid 2>/dev/null; do
        local written=0
        for pf in "${split_prefix}"* ; do
            [ -f "$pf" ] && written=$(( written + $(wc -c < "$pf" 2>/dev/null || echo 0) ))
        done
        local pct=$(( written * 100 / total_size ))
        [ $pct -gt 100 ] && pct=100
        local now; now=$(date +%s); local diff=$(( now - start_t )); [ $diff -eq 0 ] && diff=1
        local speed=$(( written / diff / 1024 / 1024 ))
        local filled=$(( pct / 4 ))
        local bar; bar=$(printf "%${filled}s" | tr ' ' '━')
        local space; space=$(printf "%$((25 - filled))s")
        local nparts; nparts=$(ls "${split_prefix}"* 2>/dev/null | wc -l | tr -d ' ')
        printf "\r\033[K${LPURPLE}┠${LGREEN}%s${WHITE}%s${LPURPLE}┨ ${LBLUE}%d%%${NC} | ${LYELLOW}%d MB/s${NC} | %d parts" \
            "$bar" "$space" "$pct" "$speed" "$nparts"
        usleep 200000 2>/dev/null || sleep 1
    done
    wait $pid
    rm -f "$counter_file"
    local real_ret=1
    [ -f "$ret_file" ] && { real_ret=$(cat "$ret_file"); rm -f "$ret_file"; }
    local nparts; nparts=$(ls "${split_prefix}"* 2>/dev/null | wc -l | tr -d ' ')
    if [ "$real_ret" -eq 0 ]; then
        printf "\r\033[K${LGREEN}┗━━━━━━━━━━━━━━━━━━━━━━━━━┛ 100%% $(print_msg "progress_done") [%d parts × %sMB]${NC}\n" \
            "$nparts" "$split_mb"
    else
        printf "\r\033[K${RED}[!] split pipeline failed${NC}\n"
    fi
    return "$real_ret"
}

# 引擎调度入口：src dst size → 实际输出路径写入 BACKUP_OUT
BACKUP_OUT=""
run_backup_engine() {
    local src="$1" dst_base="$2" total_size="${3:-0}"
    [ "$total_size" -le 0 ] && total_size=$(get_part_size "$src")
    [ "$total_size" -le 0 ] && total_size=1
    local engine="${BACKUP_ENGINE:-dd}"
    echo -e "    ${DIM}$(print_msg "engine_writing" "$engine")${NC}"
    case "$engine" in
        sparse)
            BACKUP_OUT="${dst_base}.img"
            register_tmp "$BACKUP_OUT"
            _run_sparse "$src" "$BACKUP_OUT" "$total_size"
            local ret=$?; [ $ret -ne 0 ] && { rm -f "$BACKUP_OUT"; unregister_tmp "$BACKUP_OUT"; BACKUP_OUT=""; }
            return $ret ;;
        pigz)
            BACKUP_OUT="${dst_base}.img.gz"
            register_tmp "$BACKUP_OUT"
            _run_pigz "$src" "$BACKUP_OUT" "$total_size"
            local ret=$?; [ $ret -ne 0 ] && { rm -f "$BACKUP_OUT"; unregister_tmp "$BACKUP_OUT"; BACKUP_OUT=""; }
            return $ret ;;
        pbzip2)
            BACKUP_OUT="${dst_base}.img.bz2"
            register_tmp "$BACKUP_OUT"
            _run_pbzip2 "$src" "$BACKUP_OUT" "$total_size"
            local ret=$?; [ $ret -ne 0 ] && { rm -f "$BACKUP_OUT"; unregister_tmp "$BACKUP_OUT"; BACKUP_OUT=""; }
            return $ret ;;
        split)
            BACKUP_OUT="${dst_base}.img.part_aa"  # 校验时扫描所有 part_*
            _run_split "$src" "$dst_base" "$total_size"
            return $? ;;
        *)  # dd (default)
            BACKUP_OUT="${dst_base}.img"
            register_tmp "$BACKUP_OUT"
            run_dd_with_progress "$src" "$BACKUP_OUT" "$DD_BS" "$total_size"
            local ret=$?; [ $ret -ne 0 ] && { rm -f "$BACKUP_OUT"; unregister_tmp "$BACKUP_OUT"; BACKUP_OUT=""; }
            return $ret ;;
    esac
}

# § 系统信息
show_system_info() {
    # 按优先级获取 CPU 型号
    local cpu=""
    # 1. ro.soc.model (Android 12+)
    cpu=$(getprop ro.soc.model 2>/dev/null)
    # 2. ro.hardware.chipname
    [ -z "$cpu" ] && cpu=$(getprop ro.hardware.chipname 2>/dev/null)
    # 3. 厂商+平台名拼接
    if [ -z "$cpu" ]; then
        local mfr; mfr=$(getprop ro.soc.manufacturer 2>/dev/null)
        local plat; plat=$(getprop ro.board.platform 2>/dev/null)
        [ -n "$mfr" ] && [ -n "$plat" ] && cpu="$mfr $plat"
        [ -z "$cpu" ] && cpu="$plat"
    fi
    # 4. /proc/cpuinfo Hardware
    [ -z "$cpu" ] && cpu=$(grep "^Hardware" /proc/cpuinfo 2>/dev/null | head -1 | cut -d':' -f2 | sed 's/^[[:space:]]*//')
    # 5. 设备型号兜底
    [ -z "$cpu" ] && cpu=$(getprop ro.product.model 2>/dev/null)
    [ -z "$cpu" ] && cpu="Unknown"

    local batt="N/A"
    [ -f /sys/class/power_supply/battery/capacity ] && batt=$(cat /sys/class/power_supply/battery/capacity)%

    local ram_total; ram_total=$(awk '/MemTotal/{printf "%.0f", $2/1024}' /proc/meminfo 2>/dev/null || echo "?")
    local ram_free; ram_free=$(awk '/MemAvailable/{printf "%.0f", $2/1024}' /proc/meminfo 2>/dev/null || echo "?")

    local os; os=$(getprop ro.build.version.release 2>/dev/null)
    local sdk; sdk=$(getprop ro.build.version.sdk 2>/dev/null)
    local slot_disp="${SLOT:-None}"
    local selinux; selinux=$(getenforce 2>/dev/null || echo "N/A")
    local part_type; part_type=$([ "$IS_DYNAMIC" -eq 1 ] && echo "Dynamic" || echo "Static")
    local ab_text; ab_text=$([ "$IS_AB" -eq 1 ] && echo "A/B" || echo "A-only")

    echo -e "${BOLD}${LGREEN}  $(print_msg "sys_info")${NC}"
    echo -e "  ${CYAN}$(print_msg "cpu")${NC} $cpu"
    echo -e "  ${CYAN}$(print_msg "ram")${NC} ${ram_free}MB / ${ram_total}MB"
    echo -e "  ${CYAN}$(print_msg "battery")${NC} $batt"
    echo -e "  ${CYAN}$(print_msg "android")${NC} $os (API $sdk)"
    echo -e "  ${CYAN}$(print_msg "slot")${NC} $slot_disp  $ab_text  $part_type"
    echo -e "  ${CYAN}$(print_msg "selinux")${NC} $selinux"
}

# § 选择备份路径
choose_path() {
    [ "$PATH_SELECTED" -eq 1 ] && return 0
    section "📁" "$(print_msg "path_choice" "$DEFAULT_BACKUP")" "$PURPLE"
    echo -n "  "
    read -r INPUT
    local base_dir
    [ -z "$INPUT" ] && base_dir="$DEFAULT_BACKUP" || base_dir="$INPUT"
    base_dir="${base_dir%/}"

    # 每次备份建带时间戳的子目录
    local stamp; stamp=$(date +%Y%m%d_%H%M%S)
    BACKUP_DIR="${base_dir}/${stamp}"
    mkdir -p "$BACKUP_DIR" 2>/dev/null
    if [ ! -d "$BACKUP_DIR" ]; then
        echo -e "${RED}[!] $(print_msg "path_create_fail")${NC}"; exit 1
    fi

    local df_out; df_out=$(df -P "$base_dir" 2>/dev/null | tail -1)
    local avail; avail=$(printf '%s' "$df_out" | awk '{print $4}')
    if [ -z "$avail" ] || ! printf '%s' "$avail" | grep -qE '^[0-9]+$'; then
        echo -e "${YELLOW}[!] $(print_msg "path_space_unknown")${NC}"
    elif [ "$avail" -lt 512000 ]; then
        echo -e "${RED}[!] $(print_msg "path_space_low" "$((avail/1024))")${NC}"; exit 1
    else
        echo -e "${GREEN}[✓] $(print_msg "path_space_ok" "$((avail/1024))")${NC}"
    fi
    echo -e "${DIM}  → $BACKUP_DIR${NC}"

    echo -en "${YELLOW}[?] $(print_msg "path_compress")${NC}"
    read -r comp
    if [ "$comp" = "y" ] || [ "$comp" = "Y" ]; then
        USE_COMPRESS=1; echo -e "${GREEN}[i] $(print_msg "path_compress_on")${NC}"
    else
        USE_COMPRESS=0
    fi

    echo -en "${YELLOW}[?] $(print_msg "path_incremental")${NC}"
    read -r inc
    if [ "$inc" = "y" ] || [ "$inc" = "Y" ]; then
        INCREMENTAL_MODE=1; echo -e "${GREEN}[i] $(print_msg "path_incremental_on")${NC}"
    else
        INCREMENTAL_MODE=0
    fi

    LOGFILE="${BACKUP_DIR}/backup_${stamp}.log"
    {
        echo "=== Geek Toolbox v10.1 ==="
        echo "Device:      $(getprop ro.product.model 2>/dev/null)"
        echo "Android:     $(getprop ro.build.version.release 2>/dev/null)"
        echo "Slot:        ${SLOT:-None}"
        echo "Compression: $USE_COMPRESS"
        echo "Incremental: $INCREMENTAL_MODE"
        echo "Date:        $(date)"
        echo "Dir:         $BACKUP_DIR"
    } > "$LOGFILE"

    OP_START_TIME=$(date +%s)
    OP_FILE_COUNT=0
    OP_TOTAL_BYTES=0
    PATH_SELECTED=1
}

# § 通用备份
backup_partition() {
    local src="$1" base_dest="$2" name="$3"
    local final_dest content_sha1 size

    if [ -z "$src" ] || [ ! -e "$src" ]; then
        echo -e "${RED}[!] $(print_msg "part_not_exist" "$src")${NC}"
        log_msg "E" "$(print_msg "backup_fail_log" "$name" "$src")"
        return 1
    fi

    size=$(get_part_size "$src")
    [ "$size" -eq 0 ] && echo -e "${YELLOW}[!] $(print_msg "part_size_zero")${NC}"

    # 增量检查
    if [ "$INCREMENTAL_MODE" -eq 1 ] && [ -f "${base_dest}.content.sha1" ]; then
        local old_sha1; old_sha1=$(cat "${base_dest}.content.sha1" 2>/dev/null)
        if [ -n "$old_sha1" ]; then
            echo -e "${CYAN}[i] $(print_msg "backup_check" "$name")${NC}"
            local current_sha1; current_sha1=$(dd if="$src" bs=4M 2>/dev/null | sha1sum | awk '{print $1}')
            if [ "$current_sha1" = "$old_sha1" ]; then
                echo -e "${GREEN}[✓] $(print_msg "backup_skip" "$name")${NC}"
                log_msg "I" "Incremental skip: $name"
                return 0
            else
                echo -e "${YELLOW}[!] $(print_msg "backup_changed" "$name")${NC}"
            fi
        fi
    fi

    echo -e "${BLUE}[>] $(print_msg "backup_start" "$name")${NC}"
    echo -e "${DIM}    $(print_msg "backup_source" "$src" "$((size/1024/1024))")${NC}"

    # USE_COMPRESS=1 且 dd 引擎时用兼容 gzip，否则走多引擎
    if [ "$USE_COMPRESS" -eq 1 ] && [ "${BACKUP_ENGINE:-dd}" = "dd" ]; then
        # 兼容模式: dd+gzip
        final_dest="${base_dest}.img.gz"
        local tmp_img="${base_dest}.img.tmp"
        register_tmp "$tmp_img"; register_tmp "$final_dest"
        echo "    $(print_msg "backup_temp")"
        if ! dd if="$src" of="$tmp_img" bs="$DD_BS" conv=fsync >/dev/null 2>&1; then
            echo -e "${RED}[!] $(print_msg "backup_dd_fail")${NC}"
            rm -f "$tmp_img"; unregister_tmp "$tmp_img"; unregister_tmp "$final_dest"
            log_msg "E" "Backup $name: dd temp failed"; return 1
        fi
        sync
        content_sha1=$(compute_sha1 "$tmp_img")
        echo "    $(print_msg "backup_compressing")"
        if ! gzip -c "$tmp_img" > "$final_dest"; then
            echo -e "${RED}[!] $(print_msg "backup_compress_fail")${NC}"
            rm -f "$tmp_img" "$final_dest"
            unregister_tmp "$tmp_img"; unregister_tmp "$final_dest"
            log_msg "E" "Backup $name: gzip failed"; return 1
        fi
        rm -f "$tmp_img"; unregister_tmp "$tmp_img"
        echo "$content_sha1" > "${base_dest}.content.sha1"
        unregister_tmp "$final_dest"
        echo -e "${GREEN}[✓] $(print_msg "backup_compress_done" "$(basename "$final_dest")")${NC}"
    else
        # 多引擎调度
        if ! run_backup_engine "$src" "$base_dest" "$size"; then
            echo -e "${RED}[!] $(print_msg "backup_dd_fail2")${NC}"
            log_msg "E" "Backup $name: engine failed (${BACKUP_ENGINE:-dd})"; return 1
        fi
        final_dest="$BACKUP_OUT"
        sync
        # split 引擎: sha1 合并所有分片
        if [ "${BACKUP_ENGINE:-dd}" = "split" ]; then
            content_sha1=$(cat "${base_dest}".img.part_* 2>/dev/null | sha1sum | awk '{print $1}')
        else
            content_sha1=$(compute_sha1 "$final_dest")
        fi
        echo "$content_sha1" > "${base_dest}.content.sha1"
        unregister_tmp "$final_dest"
        echo -e "${GREEN}[✓] $(print_msg "backup_done" "$(basename "$final_dest")")${NC}"
    fi

    # split 引擎: final_dest 为第一片
    local check_dest="$final_dest"
    [ "${BACKUP_ENGINE:-dd}" = "split" ] && check_dest="${base_dest}.img.part_aa"
    if [ ! -f "$check_dest" ]; then
        echo -e "${RED}[!] $(print_msg "backup_target_missing")${NC}"
        log_msg "E" "Backup $name: target missing"; return 1
    fi

    # 更新 sha1sums.txt，去重后追加
    if command -v sha1sum >/dev/null 2>&1; then
        local sums_file="${BACKUP_DIR}/sha1sums.txt"
        local tmp_sums="${sums_file}.tmp"

        if [ "${BACKUP_ENGINE:-dd}" = "split" ]; then
            # split 引擎：为每个分片单独记录 sha1，并额外记录一行合并校验值
            # 格式：  <sha1>  <part_xx>          ← 每个分片
            #         <sha1>  <name>.img.combined ← 合并后的完整校验（用于完整性验证）
            [ -f "$sums_file" ] && grep -v "  $(basename "${base_dest}")\.img\.part_\|  $(basename "${base_dest}")\.img\.combined$" \
                "$sums_file" > "$tmp_sums" 2>/dev/null || true
            [ ! -f "$tmp_sums" ] && touch "$tmp_sums"
            local combined_sha1=""
            for pf in "${base_dest}".img.part_*; do
                [ -f "$pf" ] || continue
                local psha; psha=$(compute_sha1 "$pf")
                echo "$psha  $(basename "$pf")" >> "$tmp_sums"
                combined_sha1="${combined_sha1}${psha}"
            done
            # 合并行：对所有分片 sha1 字符串再做一次 sha1（确定性标识）
            local combined_final; combined_final=$(printf '%s' "$combined_sha1" | sha1sum | awk '{print $1}')
            echo "$combined_final  $(basename "${base_dest}").img.combined" >> "$tmp_sums"
            mv -f "$tmp_sums" "$sums_file"
            echo -e "    ${DIM}$(print_msg "backup_checksum" "${combined_final:0:16}") [split×$(ls "${base_dest}".img.part_* 2>/dev/null | wc -l | tr -d ' ')]${NC}"
            # 统计：合计所有分片大小
            local fsize=0
            for pf in "${base_dest}".img.part_*; do
                [ -f "$pf" ] && fsize=$(( fsize + $(wc -c < "$pf" 2>/dev/null || echo 0) ))
            done
            OP_FILE_COUNT=$(( OP_FILE_COUNT + 1 ))
            OP_TOTAL_BYTES=$(( OP_TOTAL_BYTES + fsize ))
        else
            local file_sha1; file_sha1=$(compute_sha1 "$final_dest")
            local bname; bname=$(basename "$final_dest")
            if [ -f "$sums_file" ]; then
                grep -v "  ${bname}$" "$sums_file" > "$tmp_sums" 2>/dev/null || true
                echo "$file_sha1  $bname" >> "$tmp_sums"
                mv -f "$tmp_sums" "$sums_file"
            else
                echo "$file_sha1  $bname" > "$sums_file"
            fi
            echo -e "    ${DIM}$(print_msg "backup_checksum" "${file_sha1:0:16}")${NC}"
            # 统计
            local fsize; fsize=$(wc -c < "$final_dest" 2>/dev/null || echo 0)
            OP_FILE_COUNT=$(( OP_FILE_COUNT + 1 ))
            OP_TOTAL_BYTES=$(( OP_TOTAL_BYTES + fsize ))
        fi
    fi

    log_msg "I" "$(print_msg "backup_success_log" "$name" "$final_dest")"
    return 0
}

# § 备份模块
backup_boot() {
    [ "$PATH_SELECTED" -eq 0 ] && choose_path
    detect_device_type
    section "🔵" "$(print_msg "boot_title")"
    local parts="boot init_boot vendor_boot vendor_kernel_boot recovery dtbo pvmfw vbmeta vbmeta_system vbmeta_vendor vendor_dlkm system_dlkm"
    local success=0 failed=0
    for img in $parts; do
        local part=""
        [ "$IS_AB" -eq 1 ] && part=$(find_part "${img}${SLOT}") || part=$(find_part "$img")
        if [ -n "$part" ]; then
            local pname="${img}${SLOT}"
            [ "$IS_AB" -eq 0 ] && pname="$img"
            if backup_partition "$part" "$BACKUP_DIR/$pname" "$pname"; then
                success=$(( success + 1 ))
            else
                failed=$(( failed + 1 ))
            fi
        fi
    done
    echo -e "\n${GREEN}$(print_msg "boot_success" "$success" "$failed")${NC}"
    log_msg "I" "Boot backup: success=$success failed=$failed"
}

backup_efs() {
    [ "$PATH_SELECTED" -eq 0 ] && choose_path
    detect_device_type
    section "📡" "$(print_msg "efs_title")"
    echo -e "${YELLOW}[?] $(print_msg "efs_choice")${NC}"
    echo "  $(print_msg "efs_opt1")"
    echo "  $(print_msg "efs_opt2")"
    read -r efs_choice

    local parts="modemst1 modemst2 fsg fsc persist modem efs misc"
    [ "$IS_AB" -eq 1 ] && parts="$parts modem_a modem_b"

    if [ "$efs_choice" = "2" ]; then
        local tmp_dir="${BACKUP_DIR}/efs_temp_$$"
        mkdir -p "$tmp_dir"
        register_tmp "$tmp_dir"
        local success=0
        for p in $parts; do
            local part; part=$(find_part "$p")
            if [ -n "$part" ]; then
                echo -e "${BLUE}[>] $(print_msg "efs_temp" "$p")${NC}"
                if dd if="$part" of="$tmp_dir/${p}.img" bs="$DD_BS" conv=fsync >/dev/null 2>&1; then
                    success=$(( success + 1 ))
                else
                    echo -e "${RED}[!] $(print_msg "efs_fail" "$p")${NC}"
                fi
            fi
        done
        local tar_dest="${BACKUP_DIR}/EFS.tar.gz"
        register_tmp "$tar_dest"
        if [ $success -gt 0 ]; then
            echo -e "${CYAN}[>] $(print_msg "efs_packing")${NC}"
            if tar -czf "$tar_dest" -C "$tmp_dir" . 2>/dev/null; then
                sync
                echo -e "${GREEN}[✓] $(print_msg "efs_pack_done")${NC}"
                local sha; sha=$(compute_sha1 "$tar_dest")
                local sums_file="${BACKUP_DIR}/sha1sums.txt"
                local tmp_sums="${sums_file}.tmp"
                if [ -f "$sums_file" ]; then
                    grep -v "  EFS\.tar\.gz$" "$sums_file" > "$tmp_sums" 2>/dev/null || true
                    echo "$sha  EFS.tar.gz" >> "$tmp_sums"
                    mv -f "$tmp_sums" "$sums_file"
                else
                    echo "$sha  EFS.tar.gz" > "$sums_file"
                fi
                local fsize; fsize=$(wc -c < "$tar_dest" 2>/dev/null || echo 0)
                OP_FILE_COUNT=$(( OP_FILE_COUNT + 1 ))
                OP_TOTAL_BYTES=$(( OP_TOTAL_BYTES + fsize ))
                unregister_tmp "$tar_dest"
            else
                echo -e "${RED}[!] $(print_msg "efs_pack_fail")${NC}"
                rm -f "$tar_dest"; unregister_tmp "$tar_dest"
            fi
        else
            unregister_tmp "$tar_dest"
        fi
        rm -rf "$tmp_dir"
        unregister_tmp "$tmp_dir"
        echo -e "\n${GREEN}[✓] $(print_msg "efs_pack_success" "$success")${NC}"
    else
        mkdir -p "$BACKUP_DIR/EFS"
        local success=0
        for p in $parts; do
            local part; part=$(find_part "$p")
            if [ -n "$part" ]; then
                backup_partition "$part" "$BACKUP_DIR/EFS/$p" "$p" && success=$(( success + 1 ))
            fi
        done
        echo -e "\n${GREEN}[✓] $(print_msg "efs_single_success" "$success")${NC}"
    fi
    log_msg "I" "EFS backup done"
}

backup_metadata() {
    [ "$PATH_SELECTED" -eq 0 ] && choose_path
    detect_device_type
    section "🗂️" "$(print_msg "metadata_title")"
    local success=0
    local mp; mp=$(find_part "metadata")
    if [ -n "$mp" ]; then
        backup_partition "$mp" "$BACKUP_DIR/metadata" "metadata" && success=$(( success + 1 ))
    else
        echo -e "${YELLOW}[!] $(print_msg "metadata_not_found")${NC}"
    fi
    local sep; sep=$(find_part "super_empty")
    if [ -n "$sep" ]; then
        backup_partition "$sep" "$BACKUP_DIR/super_empty" "super_empty" && success=$(( success + 1 ))
    else
        echo -e "${YELLOW}[!] $(print_msg "super_empty_not_found")${NC}"
    fi
    echo -e "\n${GREEN}[✓] $(print_msg "metadata_done" "$success")${NC}"
    log_msg "I" "Metadata backup done"
}

backup_all() {
    choose_path
    backup_boot
    backup_efs
    backup_metadata
    print_summary
    echo -e "\n${GREEN}━━━ $(print_msg "all_done") ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    log_msg "I" "Full backup completed"
}

# § 增量备份
_inc_check_part() {
    local part="$1" part_name="$2" dest_prefix="$3"
    local sha1_file="${dest_prefix}.content.sha1"
    local old_sha1=""
    [ -f "$sha1_file" ] && old_sha1=$(cat "$sha1_file")
    echo -e "${CYAN}[i] $(print_msg "inc_check" "$part_name")${NC}"
    local current_sha1; current_sha1=$(dd if="$part" bs=4M 2>/dev/null | sha1sum | awk '{print $1}')
    if [ "$current_sha1" = "$old_sha1" ]; then
        echo -e "${GREEN}[✓] $(print_msg "inc_skip" "$part_name")${NC}"
    else
        echo -e "${YELLOW}[!] $(print_msg "inc_changed" "$part_name")${NC}"
        backup_partition "$part" "$dest_prefix" "$part_name"
    fi
}

incremental_backup() {
    section "🔄" "$(print_msg "inc_title")"
    echo -n "$(print_msg "inc_base_dir")"
    read -r base_dir
    if [ ! -d "$base_dir" ]; then
        echo -e "${RED}[!] $(print_msg "inc_dir_not_exist")${NC}"; return
    fi

    BACKUP_DIR="$base_dir"
    PATH_SELECTED=1
    ls "$base_dir"/*.gz >/dev/null 2>&1 && { USE_COMPRESS=1; echo -e "${GREEN}[i] $(print_msg "inc_detect_gz")${NC}"; } || USE_COMPRESS=0
    INCREMENTAL_MODE=1
    OP_START_TIME=$(date +%s)
    OP_FILE_COUNT=0; OP_TOTAL_BYTES=0
    echo -e "${YELLOW}[i] $(print_msg "inc_mode")${NC}"
    detect_device_type

    # 启动分区
    local parts="boot init_boot vendor_boot vendor_kernel_boot recovery dtbo pvmfw vbmeta vbmeta_system vbmeta_vendor vendor_dlkm system_dlkm"
    for img in $parts; do
        local part="" pname="$img"
        if [ "$IS_AB" -eq 1 ]; then
            part=$(find_part "${img}${SLOT}"); pname="${img}${SLOT}"
        else
            part=$(find_part "$img")
        fi
        [ -n "$part" ] && _inc_check_part "$part" "$pname" "$BACKUP_DIR/$pname"
    done

    # EFS
    if [ -d "$BACKUP_DIR/EFS" ]; then
        echo -e "\n${CYAN}[i] Checking EFS...${NC}"
        local efs_parts="modemst1 modemst2 fsg fsc persist modem efs misc"
        [ "$IS_AB" -eq 1 ] && efs_parts="$efs_parts modem_a modem_b"
        for p in $efs_parts; do
            local part; part=$(find_part "$p")
            [ -n "$part" ] && _inc_check_part "$part" "$p" "$BACKUP_DIR/EFS/$p"
        done
    fi

    # Metadata
    for pn in metadata super_empty; do
        local part; part=$(find_part "$pn")
        [ -n "$part" ] && _inc_check_part "$part" "$pn" "$BACKUP_DIR/$pn"
    done

    print_summary
    echo -e "\n${GREEN}[✓] $(print_msg "inc_done")${NC}"
    log_msg "I" "Incremental backup completed"
}

# § 分区恢复
restore_partition() {
    section "⚠️" "$(print_msg "restore_title")" "$LRED"
    check_battery || return
    detect_device_type

    echo -n "$(print_msg "restore_img_path")"
    read -r imgpath
    [ ! -f "$imgpath" ] && { echo -e "${RED}[!] $(print_msg "restore_file_not_exist")${NC}"; return; }

    local is_gz=0
    case "$imgpath" in *.gz) is_gz=1 ;; esac

    echo -n "$(print_msg "restore_part_name")"
    read -r pname
    local part; part=$(find_part "$pname")
    [ -z "$part" ] && { echo -e "${RED}[!] $(print_msg "restore_part_not_exist")${NC}"; return; }
    echo -e "${CYAN}[i] $(print_msg "restore_target" "$part")${NC}"

    check_mounted "$part" || return

    local part_size; part_size=$(get_part_size "$part")
    [ "$part_size" -gt 0 ] && echo -e "${CYAN}[i] $(print_msg "restore_part_size" "$((part_size/1024/1024))")${NC}"

    local img_size=0
    if [ "$is_gz" -eq 1 ]; then
        img_size=$(gzip -l "$imgpath" 2>/dev/null | tail -1 | awk '{print $2}' || echo 0)
        [ -z "$img_size" ] || ! printf '%s' "$img_size" | grep -qE '^[0-9]+$' && {
            echo -e "${YELLOW}[!] $(print_msg "restore_size_unknown")${NC}"; img_size=0
        }
    else
        img_size=$(wc -c < "$imgpath" 2>/dev/null || echo 0)
    fi

    if [ "$img_size" -gt 0 ] && [ "$part_size" -gt 0 ]; then
        if [ "$img_size" -gt "$part_size" ]; then
            echo -e "${RED}[!] $(print_msg "restore_size_exceed")${NC}"; return
        elif [ "$img_size" -lt "$part_size" ]; then
            echo -e "${YELLOW}[!] $(print_msg "restore_size_small" "$((img_size/1024/1024))")${NC}"
        fi
    fi

    # SHA1 预比较
    echo -e "\n${CYAN}[*] $(print_msg "restore_calc_sha1")${NC}"
    local same_content=0
    if command -v sha1sum >/dev/null 2>&1 && [ "$img_size" -gt 0 ]; then
        local part_sha1 img_sha1
        if [ "$is_gz" -eq 1 ]; then
            part_sha1=$(dd if="$part" bs=4M count=$(( (img_size/4/1024/1024) + 1 )) 2>/dev/null | sha1sum | awk '{print $1}')
            img_sha1=$(zcat "$imgpath" 2>/dev/null | sha1sum | awk '{print $1}')
        else
            part_sha1=$(dd if="$part" bs="$DD_BS" 2>/dev/null | sha1sum | awk '{print $1}')
            img_sha1=$(compute_sha1 "$imgpath")
        fi
        if [ "$part_sha1" = "$img_sha1" ]; then
            echo -e "${YELLOW}[!] $(print_msg "restore_same_content")${NC}"
            same_content=1
        else
            echo -e "${GREEN}[i] $(print_msg "restore_diff")${NC}"
        fi
    else
        echo -e "${YELLOW}[!] $(print_msg "restore_sha1_skip")${NC}"
    fi

    [ "$same_content" -eq 1 ] && { confirm "restore_force" || return; }

    # 备份原分区
    [ -z "$BACKUP_DIR" ] && BACKUP_DIR="$DEFAULT_BACKUP" && mkdir -p "$BACKUP_DIR"
    local bak_orig="${BACKUP_DIR}/auto_backup_${pname}_$(date +%Y%m%d_%H%M%S).img"
    echo -e "${CYAN}[i] $(print_msg "restore_backup")${NC}"
    echo "    $bak_orig"
    if ! dd if="$part" of="$bak_orig" bs="$DD_BS" conv=fsync >/dev/null 2>&1; then
        echo -e "${YELLOW}[!] $(print_msg "restore_backup_fail")${NC}"
        confirm "restore_continue" || return
    fi

    # 最终确认
    echo -e "\n${RED}[!] $(print_msg "restore_final_confirm" "$imgpath" "$pname")${NC}"
    confirm_yes "yes_confirm" || { echo "$(print_msg "cancel")"; return; }

    echo -e "[>] $(print_msg "restore_writing")"
    local write_ok=0
    if [ "$is_gz" -eq 1 ]; then
        # gz 恢复进度：解压后大小未知，用目标分区写入量做进度参考
        # 优先用 pv（如果存在），否则用后台进度轮询
        if command -v pv >/dev/null 2>&1; then
            local gz_size; gz_size=$(wc -c < "$imgpath" 2>/dev/null || echo 1)
            # pv 追踪 zcat 输出流（解压后字节数），目标分区大小做上限
            zcat "$imgpath" 2>/dev/null \
                | pv -s "$part_size" -p -t -e -r -b \
                | dd of="$part" bs="$DD_BS" conv=fsync >/dev/null 2>&1
            write_ok=${PIPESTATUS[2]}
        else
            # 无 pv：后台运行管道，轮询目标分区已写字节数做进度条
            local gz_ret_f; gz_ret_f="${imgpath}.gz_ret.tmp"
            local start; start=$(date +%s)
            ( zcat "$imgpath" 2>/dev/null \
                | dd of="$part" bs="$DD_BS" conv=fsync >/dev/null 2>&1
              # PIPESTATUS 在子 shell 内有效
              echo ${PIPESTATUS[1]} > "$gz_ret_f" ) &
            local pipe_pid=$!
            # 进度轮询：读 /proc/$pipe_pid 子进程组写出字节数
            local use_proc_io=1
            sleep 0.1
            if ! awk '/^write_bytes/' /proc/$pipe_pid/io >/dev/null 2>&1; then
                use_proc_io=0
            fi
            while kill -0 $pipe_pid 2>/dev/null; do
                local written=0
                if [ "$use_proc_io" -eq 1 ]; then
                    written=$(awk '/^write_bytes/{print $2}' /proc/$pipe_pid/io 2>/dev/null || echo 0)
                else
                    # 通过读分区块设备当前已写位置估算（部分内核支持）
                    written=$(blockdev --getsize64 "$part" 2>/dev/null || echo 0)
                    # blockdev 返回的是分区总大小不是写入量，改用固定估算
                    written=0
                fi
                local pct=0
                [ "$part_size" -gt 0 ] && pct=$(( written * 100 / part_size ))
                [ "$pct" -gt 99 ] && pct=99   # 未完成时不显示 100%
                local now; now=$(date +%s); local diff=$(( now - start )); [ "$diff" -eq 0 ] && diff=1
                local speed=$(( written / diff / 1024 / 1024 ))
                local filled=$(( pct / 4 ))
                local bar; bar=$(printf "%${filled}s" | tr ' ' '━')
                local space; space=$(printf "%$((25 - filled))s")
                printf "\r\033[K${LPURPLE}┠${LGREEN}%s${WHITE}%s${LPURPLE}┨ ${LBLUE}%d%%${NC} | ${LYELLOW}%d MB/s${NC} [gz→part]" \
                    "$bar" "$space" "$pct" "$speed"
                usleep 300000 2>/dev/null || sleep 1
            done
            wait $pipe_pid
            printf "\r\033[K${LGREEN}┗━━━━━━━━━━━━━━━━━━━━━━━━━┛ done [gz restore]${NC}\n"
            write_ok=1
            [ -f "$gz_ret_f" ] && { write_ok=$(cat "$gz_ret_f"); rm -f "$gz_ret_f"; }
        fi
    else
        run_dd_with_progress "$imgpath" "$part" "$DD_BS" "$img_size"
        write_ok=$?
    fi

    sync
    if [ $write_ok -eq 0 ]; then
        echo -e "${GREEN}[✓] $(print_msg "restore_success")${NC}"
        echo "    $bak_orig"
        echo -e "${YELLOW}[!] $(print_msg "restore_reboot")${NC}"
        log_msg "I" "Restore OK: $pname from $imgpath"
    else
        echo -e "${RED}[!] $(print_msg "restore_fail")${NC}"
        if dd if="$bak_orig" of="$part" bs="$DD_BS" conv=fsync >/dev/null 2>&1; then
            echo -e "${GREEN}[✓] $(print_msg "restore_rollback_ok")${NC}"
            log_msg "W" "Restore failed, rolled back: $pname"
        else
            echo -e "${RED}[!] $(print_msg "restore_rollback_fail" "$bak_orig")${NC}"
            log_msg "E" "Restore failed AND rollback failed: $pname"
        fi
    fi
}

# § 校验备份
verify_backup() {
    section "🔍" "$(print_msg "verify_title")"
    echo -n "$(print_msg "verify_dir")"
    read -r vdir
    [ -z "$vdir" ] && vdir="${BACKUP_DIR:-$DEFAULT_BACKUP}"
    if [ ! -d "$vdir" ]; then
        echo -e "${RED}[!] $(print_msg "verify_dir_not_exist")${NC}"; return
    fi
    # 用绝对路径，避免污染 $PWD
    local sums_file; sums_file=$(realpath "$vdir/sha1sums.txt" 2>/dev/null || echo "$vdir/sha1sums.txt")

    if [ ! -f "$sums_file" ]; then
        echo -e "${RED}[!] $(print_msg "verify_file_missing")${NC}"; return
    fi

    local total; total=$(grep -cE '^[0-9a-f]{40}' "$sums_file" 2>/dev/null || echo 0)
    echo -e "${YELLOW}[i] $(print_msg "verify_total" "$total")${NC}"

    local failed=0 count=0
    while IFS= read -r line; do
        local sum; sum=$(printf '%s' "$line" | awk '{print $1}')
        local fname; fname=$(printf '%s' "$line" | awk '{print $2}')
        [ -z "$sum" ] || [ -z "$fname" ] && continue
        # 拼上目录得完整路径
        local fpath="$vdir/$fname"
        count=$(( count + 1 ))
        printf "$(print_msg "verify_checking" "$count" "$total" "$fname")"
        if [ ! -f "$fpath" ]; then
            echo -e "${RED}$(print_msg "verify_lost")${NC}"; failed=$(( failed + 1 )); continue
        fi
        local cur; cur=$(compute_sha1 "$fpath")
        if [ "$cur" = "$sum" ]; then
            echo -e "${GREEN}$(print_msg "verify_ok")${NC}"
        else
            echo -e "${RED}$(print_msg "verify_bad")${NC}"; failed=$(( failed + 1 ))
        fi
    done < "$sums_file"

    echo -e "\n${GREEN}$(print_msg "verify_result" "$((total-failed))" "$failed")${NC}"
    [ "$failed" -eq 0 ] \
        && echo -e "${GREEN}[✓] $(print_msg "verify_all_ok")${NC}" \
        || echo -e "${RED}[!] $(print_msg "verify_rebackup")${NC}"
    log_msg "I" "Verify: passed=$((total-failed)) failed=$failed dir=$vdir"
}

# § OTA Payload 提取
# 格式: CrAU(0) + ver(4) + manifest_size(12) + [meta_sig(20,v2+)] + manifest + blob
# 纯shell+dd+od解析protobuf；优先使用payload_dumper

# 读取 big-endian 整数
_read_be_u64() {
    local file="$1" offset="$2"
    dd if="$file" bs=1 skip="$offset" count=8 2>/dev/null | od -An -tu8 | awk '{print $1}'
}

_read_be_u32() {
    local file="$1" offset="$2"
    dd if="$file" bs=1 skip="$offset" count=4 2>/dev/null | od -An -tu4 | awk '{print $1}'
}

_read_be_u16() {
    local file="$1" offset="$2"
    dd if="$file" bs=1 skip="$offset" count=2 2>/dev/null | od -An -tu2 | awk '{print $1}'
}

# 解码 protobuf varint，输出 "value consumed_bytes"
_decode_varint() {
    local bytes="$1"   # 十六进制字节序列，空格分隔
    local val=0 shift=0 i=1
    for hb in $bytes; do
        local b=$(( 0x$hb ))
        val=$(( val | ( (b & 0x7F) << shift ) ))
        shift=$(( shift + 7 ))
        i=$(( i + 1 ))
        [ $(( b & 0x80 )) -eq 0 ] && break
    done
    echo "$val $((i - 1))"
}

ota_payload_extract() {
    section "📦" "$(print_msg "ota_title")"
    echo -e "${CYAN}$(print_msg "ota_intro")${NC}"
    echo -e "${DIM}$(print_msg "ota_zip_hint")${NC}"

    echo -n "$(print_msg "ota_path")"
    read -r payload_path
    [ ! -f "$payload_path" ] && { echo -e "${RED}[!] $(print_msg "ota_not_exist")${NC}"; return; }

    local def_out="${DEFAULT_BACKUP}/payload_out"
    echo -n "$(print_msg "ota_outdir" "$def_out")"
    read -r out_dir
    [ -z "$out_dir" ] && out_dir="$def_out"
    mkdir -p "$out_dir" || { echo -e "${RED}[!] $(print_msg "path_create_fail")${NC}"; return; }

    # 优先使用 payload_dumper
    if command -v payload_dumper >/dev/null 2>&1; then
        echo -e "${GREEN}[✓] Using payload_dumper...${NC}"
        payload_dumper --out "$out_dir" "$payload_path" \
            && { echo -e "${GREEN}[✓] $(print_msg "ota_done" "$out_dir")${NC}"; return; } \
            || echo -e "${YELLOW}[!] payload_dumper failed, falling back to built-in parser...${NC}"
    fi
    [ -x /data/local/tmp/payload_dumper ] && {
        echo -e "${GREEN}[✓] Using local payload_dumper...${NC}"
        /data/local/tmp/payload_dumper --out "$out_dir" "$payload_path" \
            && { echo -e "${GREEN}[✓] $(print_msg "ota_done" "$out_dir")${NC}"; return; }
    }

    # 内置解析器
    echo -e "${YELLOW}$(print_msg "ota_reading_manifest")${NC}"

    # 1. 验证魔数
    local magic; magic=$(dd if="$payload_path" bs=1 count=4 2>/dev/null | od -An -tx1 | tr -d ' \n')
    if [ "$magic" != "43724155" ]; then   # "CrAU"
        echo -e "${RED}[!] $(print_msg "ota_manifest_fail")${NC}"
        echo -e "${DIM}  Magic: $magic (expected 43724155)${NC}"
        return
    fi

    # 2. 读版本和 manifest 大小
    local ver; ver=$(_read_be_u64 "$payload_path" 4)
    local manifest_size; manifest_size=$(_read_be_u64 "$payload_path" 12)
    local header_size=20
    [ "$ver" -ge 2 ] && {
        local meta_sig_size; meta_sig_size=$(_read_be_u32 "$payload_path" 20)
        header_size=24
    }

    echo -e "${DIM}  Payload version: $ver  manifest_size: $manifest_size bytes${NC}"

    if [ "$manifest_size" -le 0 ] || [ "$manifest_size" -gt 10485760 ]; then
        echo -e "${RED}[!] $(print_msg "ota_manifest_fail")${NC}"; return
    fi

    # 3. 提取 manifest
    local manifest_file="$out_dir/.manifest.pb"
    dd if="$payload_path" bs=1 skip="$header_size" count="$manifest_size" \
        of="$manifest_file" 2>/dev/null

    # 4. 从 manifest 提取分区名
    local part_names
    part_names=$(strings "$manifest_file" 2>/dev/null \
        | grep -E '^[a-z_]+[a-z0-9_]{1,30}$' \
        | grep -vE '^(lz4|brotli|xz|zstd|none|raw|replace|source_copy)$' \
        | sort -u)

    rm -f "$manifest_file"

    if [ -z "$part_names" ]; then
        echo -e "${RED}[!] $(print_msg "ota_manifest_fail")${NC}"
        echo -e "${DIM}  Could not extract partition names from manifest${NC}"
        echo -e "${CYAN}$(print_msg "ota_tool_hint")${NC}"
        return
    fi

    echo -e "${GREEN}$(print_msg "ota_partitions")${NC}"
    printf '  %s\n' $part_names

    echo -n "$(print_msg "ota_select")"
    read -r selected
    local target_parts
    if [ -z "$selected" ]; then
        target_parts="$part_names"
    else
        target_parts="$selected"
    fi

    # 5. 计算数据块偏移
    local data_offset=$(( header_size + manifest_size ))
    [ "$ver" -ge 2 ] && data_offset=$(( data_offset + meta_sig_size ))

    echo -e "${YELLOW}[i] Data blob starts at offset: $data_offset${NC}"
    echo -e "${YELLOW}[i] Built-in parser: extracting raw extents (no decompression)${NC}"

    # 6. 引导用户使用外部工具完整提取
    echo -e "\n${YELLOW}[!] Built-in parser requires payload_dumper for full extraction.${NC}"
    echo -e "${CYAN}  Detected partitions: $(echo "$part_names" | tr '\n' ' ')${NC}"
    echo -e "\n${BOLD}How to extract on-device:${NC}"
    echo -e "  ${GREEN}Option 1:${NC} Install payload_dumper via Magisk module"
    echo -e "            → github.com/vm03/payload_dumper (ARM binary)"
    echo -e "  ${GREEN}Option 2:${NC} Place payload_dumper at /data/local/tmp/payload_dumper"
    echo -e "            and re-run this option"
    echo -e "  ${GREEN}Option 3:${NC} Use termux + python3:"
    echo -e "            ${DIM}pip install payload-dumper-go${NC}"
    echo -e "            ${DIM}payload-dumper-go $payload_path${NC}"
    echo -e "\n  ${CYAN}$(print_msg "ota_tool_hint")${NC}"

    # 尝试使用 python3
    if command -v python3 >/dev/null 2>&1; then
        echo -e "\n${GREEN}[✓] python3 found! Attempting extraction via inline script...${NC}"
        _ota_python_extract "$payload_path" "$out_dir" "$target_parts"
    fi

    log_msg "I" "OTA payload extraction attempted: $payload_path"
}

# Python3 辅助提取
_ota_python_extract() {
    local payload="$1" outdir="$2" parts="$3"
    local py_script="$outdir/.extract.py"

    # 写临时 Python 脚本
    cat > "$py_script" << 'PYEOF'
#!/usr/bin/env python3
# Minimal payload.bin extractor - no dependencies beyond stdlib
import sys, struct, os, hashlib

def read_u64(f, off):
    f.seek(off); return struct.unpack('>Q', f.read(8))[0]

def read_u32(f, off):
    f.seek(off); return struct.unpack('>I', f.read(4))[0]

def decode_varint(data, pos):
    val, shift = 0, 0
    while pos < len(data):
        b = data[pos]; pos += 1
        val |= (b & 0x7F) << shift; shift += 7
        if not (b & 0x80): break
    return val, pos

def parse_string(data, pos):
    length, pos = decode_varint(data, pos)
    return data[pos:pos+length].decode('utf-8', errors='replace'), pos+length

def parse_bytes_field(data, pos):
    length, pos = decode_varint(data, pos)
    return data[pos:pos+length], pos+length

def parse_varint_field(data, pos):
    return decode_varint(data, pos)

INSTALL_OP_TAG_TYPE        = 1   # varint: OperationType
INSTALL_OP_DATA_OFFSET     = 4   # uint64
INSTALL_OP_DATA_LENGTH     = 5   # uint64
INSTALL_OP_DATA_SHA256     = 6   # bytes
INSTALL_OP_DST_EXTENTS     = 2   # repeated Extent

EXTENT_START_BLOCK = 1   # uint64
EXTENT_NUM_BLOCKS  = 2   # uint64

PARTITION_NAME_TAG = 1   # string
PARTITION_OPS_TAG  = 3   # repeated InstallOperation
PARTITION_INFO_TAG = 2   # PartitionInfo

def parse_extent(data, pos, end):
    start_block, num_blocks = 0, 0
    while pos < end:
        tag_varint, pos = decode_varint(data, pos)
        field_num = tag_varint >> 3; wire_type = tag_varint & 0x7
        if wire_type == 0:
            val, pos = decode_varint(data, pos)
            if field_num == EXTENT_START_BLOCK: start_block = val
            elif field_num == EXTENT_NUM_BLOCKS: num_blocks = val
        elif wire_type == 2:
            _, pos = parse_bytes_field(data, pos)
        else:
            break
    return start_block, num_blocks

def parse_install_op(data, pos, end):
    op_type, data_offset, data_length = 0, 0, 0
    while pos < end:
        tag_varint, pos = decode_varint(data, pos)
        field_num = tag_varint >> 3; wire_type = tag_varint & 0x7
        if wire_type == 0:
            val, pos = decode_varint(data, pos)
            if field_num == INSTALL_OP_TAG_TYPE: op_type = val
            elif field_num == INSTALL_OP_DATA_OFFSET: data_offset = val
            elif field_num == INSTALL_OP_DATA_LENGTH: data_length = val
        elif wire_type == 2:
            raw, pos = parse_bytes_field(data, pos)
        else:
            break
    return op_type, data_offset, data_length

OP_REPLACE = 4; OP_REPLACE_BZ = 5; OP_REPLACE_XZ = 8

def extract_partition(payload_path, outdir, name, ops_raw, data_blob_offset):
    out_path = os.path.join(outdir, name + '.img')
    print(f"  Extracting {name} → {out_path}")
    BLOCK = 4096
    with open(payload_path, 'rb') as pf, open(out_path, 'wb') as of:
        for op_data in ops_raw:
            op_type, d_offset, d_length = parse_install_op(op_data, 0, len(op_data))
            if d_length == 0: continue
            abs_offset = data_blob_offset + d_offset
            pf.seek(abs_offset)
            chunk = pf.read(d_length)
            if op_type == OP_REPLACE:
                of.write(chunk)
            elif op_type == OP_REPLACE_BZ:
                import bz2; of.write(bz2.decompress(chunk))
            elif op_type == OP_REPLACE_XZ:
                import lzma; of.write(lzma.decompress(chunk))
            else:
                of.write(chunk)
    return out_path

def main():
    payload_path = sys.argv[1]
    outdir = sys.argv[2]
    wanted = sys.argv[3].split() if len(sys.argv) > 3 else None
    os.makedirs(outdir, exist_ok=True)

    with open(payload_path, 'rb') as f:
        magic = f.read(4)
        if magic != b'CrAU': print("Not a payload.bin"); sys.exit(1)
        version = read_u64(f, 4)
        manifest_size = read_u64(f, 12)
        header_size = 20
        meta_sig_size = 0
        if version >= 2:
            meta_sig_size = read_u32(f, 20)
            header_size = 24
        f.seek(header_size)
        manifest_data = f.read(manifest_size)

    data_blob_offset = header_size + manifest_size + meta_sig_size

    # Parse partitions from manifest
    pos = 0; partitions = {}
    while pos < len(manifest_data):
        tag_varint, pos = decode_varint(manifest_data, pos)
        field_num = tag_varint >> 3; wire_type = tag_varint & 0x7
        if wire_type == 2:
            raw, pos = parse_bytes_field(manifest_data, pos)
            if field_num == 13:  # partitions field in DeltaArchiveManifest
                # Parse PartitionUpdate
                p_pos = 0; p_name = ''; ops = []
                while p_pos < len(raw):
                    pt, p_pos = decode_varint(raw, p_pos)
                    pf_num = pt >> 3; pw_type = pt & 0x7
                    if pw_type == 2:
                        field_raw, p_pos = parse_bytes_field(raw, p_pos)
                        if pf_num == 1: p_name = field_raw.decode('utf-8', errors='replace')
                        elif pf_num == 3: ops.append(field_raw)
                    elif pw_type == 0:
                        _, p_pos = decode_varint(raw, p_pos)
                    else:
                        break
                if p_name: partitions[p_name] = ops
        elif wire_type == 0:
            _, pos = decode_varint(manifest_data, pos)
        else:
            pos += 1

    if not partitions:
        print("No partitions found in manifest"); sys.exit(1)

    print(f"Found {len(partitions)} partitions: {' '.join(partitions.keys())}")
    targets = wanted if wanted else list(partitions.keys())
    success, failed = 0, 0
    for name in targets:
        if name not in partitions:
            print(f"  Partition '{name}' not in manifest"); failed += 1; continue
        try:
            extract_partition(payload_path, outdir, name, partitions[name], data_blob_offset)
            success += 1
        except Exception as e:
            print(f"  FAILED {name}: {e}"); failed += 1

    print(f"\nExtraction done: success={success} failed={failed}")
    print(f"Files at: {outdir}")

main()
PYEOF

    python3 "$py_script" "$payload" "$outdir" "$parts" 2>&1
    local ret=$?
    rm -f "$py_script"
    if [ $ret -eq 0 ]; then
        echo -e "${GREEN}[✓] $(print_msg "ota_done" "$outdir")${NC}"
    else
        echo -e "${RED}[!] Python extraction failed (exit $ret)${NC}"
    fi
}

# § WebDAV 云备份
webdav_upload() {
    section "☁️" "$(print_msg "webdav_title")"
    echo -e "${CYAN}$(print_msg "webdav_intro")${NC}"

    # 检查 curl
    if ! command -v curl >/dev/null 2>&1; then
        echo -e "${RED}[!] $(print_msg "webdav_no_curl")${NC}"
        echo -e "${DIM}  Termux: pkg install curl${NC}"
        return
    fi

    # WebDAV 配置
    local dav_url dav_user dav_pass dav_remote dav_local
    local dav_insecure=0   # 是否跳过 TLS 验证

    # 读取已保存配置
    if [ -f "$WEBDAV_CFG" ]; then
        echo -en "${YELLOW}[?] $(print_msg "webdav_cfg_load")${NC} "
        read -r use_cfg
        if [ "$use_cfg" = "y" ] || [ "$use_cfg" = "Y" ] || [ -z "$use_cfg" ]; then
            # shellcheck disable=SC1090
            . "$WEBDAV_CFG" 2>/dev/null
        fi
    fi

    # 收集未填写参数
    if [ -z "${dav_url:-}" ]; then
        echo -n "$(print_msg "webdav_url")"
        read -r dav_url
        dav_url="${dav_url%/}/"
    fi
    if [ -z "${dav_user:-}" ]; then
        echo -n "$(print_msg "webdav_user")"
        read -r dav_user
    fi
    if [ -z "${dav_pass:-}" ]; then
        echo -n "$(print_msg "webdav_pass")"
        stty -echo 2>/dev/null; read -r dav_pass; stty echo 2>/dev/null; echo ""
    fi
    if [ -z "${dav_remote:-}" ]; then
        echo -n "$(print_msg "webdav_remote_dir")"
        read -r dav_remote
        [ -z "$dav_remote" ] && dav_remote="/GeekTool/"
        dav_remote="/${dav_remote#/}"; dav_remote="${dav_remote%/}/"
    fi

    echo -n "$(print_msg "webdav_src_dir")"
    read -r dav_local
    [ -z "$dav_local" ] && dav_local="${BACKUP_DIR:-$DEFAULT_BACKUP}"
    if [ ! -d "$dav_local" ]; then
        echo -e "${RED}[!] $(print_msg "verify_dir_not_exist")${NC}"; return
    fi

    # TLS 证书选项（仅 https）
    local curl_tls_opt=""
    case "$dav_url" in
        https://*)
            echo -en "${YELLOW}[?] $(print_msg "webdav_tls_ask")${NC} "
            read -r tls_ans
            if [ "$tls_ans" = "2" ]; then
                dav_insecure=1
                curl_tls_opt="--insecure"
                echo -e "${YELLOW}[!] $(print_msg "webdav_tls_insecure_warn")${NC}"
            fi
            ;;
    esac

    # curl 封装
    _dav_curl() {
        curl -s $curl_tls_opt \
            --user "$dav_user:$dav_pass" \
            "$@"
    }

    # 测试连接
    echo -e "${CYAN}[*] $(print_msg "webdav_test")${NC}"
    local http_code
    http_code=$(_dav_curl -o /dev/null -w "%{http_code}" \
        --request PROPFIND \
        --header "Depth: 0" \
        --max-time 15 \
        "$dav_url" 2>/dev/null)

    case "$http_code" in
        207|200|301)
            echo -e "${GREEN}[✓] $(print_msg "webdav_test_ok")${NC}" ;;
        401|403)
            echo -e "${RED}[!] $(print_msg "webdav_test_fail") (HTTP $http_code — credentials)${NC}"; return ;;
        60)
            # curl 60 = SSL 证书错误
            echo -e "${RED}[!] $(print_msg "webdav_test_fail") (TLS cert error — $(print_msg "webdav_tls_hint"))${NC}"; return ;;
        *)
            echo -e "${RED}[!] $(print_msg "webdav_test_fail") (HTTP $http_code)${NC}"; return ;;
    esac

    # 创建远端目录
    local device_name; device_name=$(getprop ro.product.model 2>/dev/null | tr ' ' '_')
    local date_stamp; date_stamp=$(date +%Y%m%d)
    local remote_path="${dav_url%/}${dav_remote}${device_name}_${date_stamp}/"

    echo -e "${CYAN}[>] $(print_msg "webdav_mkdir" "$remote_path")${NC}"
    _dav_curl -o /dev/null \
        --request MKCOL \
        --max-time 15 \
        "$remote_path" 2>/dev/null || true

    # 枚举待上传文件
    local files
    files=$(find "$dav_local" -maxdepth 2 \
        \( -name "*.img" -o -name "*.img.gz" -o -name "*.tar.gz" \
           -o -name "sha1sums.txt" -o -name "*.log" \) \
        -type f 2>/dev/null | sort)

    local total; total=$(printf '%s\n' $files | wc -l | tr -d ' ')
    local success=0 failed=0 idx=0

    for fpath in $files; do
        idx=$(( idx + 1 ))
        local fname; fname=$(basename "$fpath")
        local remote_file="${remote_path}${fname}"
        echo -e "${CYAN}[>] $(print_msg "webdav_uploading" "$idx" "$total" "$fname")${NC}"

        # 断点续传检查
        local remote_exists
        remote_exists=$(_dav_curl -o /dev/null -w "%{http_code}" \
            --request HEAD --max-time 10 \
            "$remote_file" 2>/dev/null)

        if [ "$remote_exists" = "200" ] || [ "$remote_exists" = "207" ]; then
            echo -en "${YELLOW}[?] $(print_msg "webdav_resume")${NC} "
            read -r skip_ans
            [ -z "$skip_ans" ] || [ "$skip_ans" = "y" ] || [ "$skip_ans" = "Y" ] && {
                echo -e "${DIM}  Skipped (already exists)${NC}"; success=$(( success + 1 )); continue
            }
        fi

        # 上传（最多3次）
        local uploaded=0
        for attempt in 1 2 3; do
            local fsize; fsize=$(wc -c < "$fpath" 2>/dev/null || echo 0)
            http_code=$(_dav_curl -o /dev/null -w "%{http_code}" \
                --request PUT \
                --upload-file "$fpath" \
                --header "Content-Length: $fsize" \
                --max-time 600 \
                --retry 0 \
                "$remote_file" 2>/dev/null)
            if [ "$http_code" = "200" ] || [ "$http_code" = "201" ] || [ "$http_code" = "204" ]; then
                echo -e "${GREEN}[✓] $(print_msg "webdav_upload_ok" "$fname") [HTTP $http_code]${NC}"
                uploaded=1; break
            else
                echo -e "${YELLOW}  Attempt $attempt failed (HTTP $http_code), retrying...${NC}"
                sleep 2
            fi
        done
        if [ "$uploaded" -eq 1 ]; then
            success=$(( success + 1 ))
        else
            echo -e "${RED}[!] $(print_msg "webdav_upload_fail" "$fname")${NC}"
            failed=$(( failed + 1 ))
            log_msg "E" "WebDAV upload failed: $fname"
        fi
    done

    echo -e "\n${GREEN}$(print_msg "webdav_done" "$success" "$failed")${NC}"
    echo -e "${DIM}  Remote: $remote_path${NC}"

    # 提示保存配置
    echo -en "${YELLOW}[?] $(print_msg "webdav_save_cfg")${NC} "
    read -r save_ans
    if [ "$save_ans" = "y" ] || [ "$save_ans" = "Y" ]; then
        mkdir -p "$(dirname "$WEBDAV_CFG")" 2>/dev/null
        chmod 700 "$(dirname "$WEBDAV_CFG")" 2>/dev/null
        cat > "$WEBDAV_CFG" << EOF
# Geek Toolbox WebDAV Config - $(date)
dav_url="$dav_url"
dav_user="$dav_user"
dav_pass="$dav_pass"
dav_remote="$dav_remote"
dav_insecure=$dav_insecure
EOF
        chmod 600 "$WEBDAV_CFG" 2>/dev/null
        echo -e "${GREEN}[✓] $(print_msg "webdav_cfg_saved" "$WEBDAV_CFG")${NC}"
    fi

    log_msg "I" "WebDAV upload done: success=$success failed=$failed remote=$remote_path"
}

# § 备份目录管理
# 备份集 = backup_YYYYMMDD_HHMMSS.log + 对应 img/gz 文件
backup_manager() {
    section "🗃️" "$(print_msg "mgr_title")"
    echo -n "$(print_msg "mgr_dir")"
    read -r mgr_dir
    [ -z "$mgr_dir" ] && mgr_dir="${BACKUP_DIR:-$DEFAULT_BACKUP}"
    if [ ! -d "$mgr_dir" ]; then
        echo -e "${RED}[!] $(print_msg "verify_dir_not_exist")${NC}"; return
    fi

    # 列出备份文件
    local all_files
    all_files=$(find "$mgr_dir" -maxdepth 2 \
        \( -name "*.img" -o -name "*.img.gz" -o -name "*.tar.gz" \) \
        -type f 2>/dev/null | sort)

    if [ -z "$all_files" ]; then
        echo -e "${YELLOW}[!] $(print_msg "mgr_no_backups")${NC}"; return
    fi

    # 统计总大小
    local total_bytes=0 file_count=0
    for f in $all_files; do
        local s; s=$(wc -c < "$f" 2>/dev/null || echo 0)
        total_bytes=$(( total_bytes + s ))
        file_count=$(( file_count + 1 ))
    done
    local total_mb=$(( total_bytes / 1024 / 1024 ))

    # 按时间升序列出备份集日志
    local log_files
    log_files=$(find "$mgr_dir" -maxdepth 1 -name "backup_*.log" -type f 2>/dev/null | sort)
    local total_sets=0
    [ -n "$log_files" ] && total_sets=$(printf '%s\n' $log_files | wc -l | tr -d ' ')

    echo -e "\n${BOLD}${LGREEN}  $(print_msg "mgr_list_title")${NC}"
    echo -e "${LCYAN}  ──────────────────────────${NC}"

    if [ -n "$log_files" ]; then
        local set_idx=0
        for lf in $log_files; do
            set_idx=$(( set_idx + 1 ))
            local lname; lname=$(basename "$lf")

            local ts; ts=$(echo "$lname" | sed 's/backup_\([0-9]\{8\}\)_\([0-9]\{6\}\)\.log/\1 \2/' \
                | awk '{d=$1; t=$2;
                    printf "%s-%s-%s %s:%s",
                    substr(d,1,4),substr(d,5,2),substr(d,7,2),
                    substr(t,1,2),substr(t,3,2)}')
            # 统计该备份集文件数和大小（扫描 log 内容匹配）
            local set_bytes=0 set_files=0
            while IFS= read -r logline; do
                case "$logline" in
                    "Backup successful:"*|"备份成功:"*)
                        local fname; fname=$(echo "$logline" | awk '{print $NF}')
                        fname=$(basename "$fname")
                        local fpath="$mgr_dir/$fname"
                        [ ! -f "$fpath" ] && fpath=$(find "$mgr_dir" -maxdepth 2 -name "$fname" -type f 2>/dev/null | head -1)
                        if [ -f "$fpath" ]; then
                            local fs; fs=$(wc -c < "$fpath" 2>/dev/null || echo 0)
                            set_bytes=$(( set_bytes + fs ))
                            set_files=$(( set_files + 1 ))
                        fi
                        ;;
                esac
            done < "$lf"
            local set_mb=$(( set_bytes / 1024 / 1024 ))
            printf "  ${CYAN}%2d.${NC} %-20s  ${DIM}%d files  %d MB${NC}\n" \
                "$set_idx" "$ts" "$set_files" "$set_mb"
        done
        echo -e "\n  $(print_msg "mgr_total" "$file_count" "$total_mb")"
    else
        # 无 log 文件，直接列
        local idx=0
        for f in $all_files; do
            idx=$(( idx + 1 ))
            local fsz; fsz=$(( $(wc -c < "$f" 2>/dev/null || echo 0) / 1024 / 1024 ))
            printf "  ${CYAN}%3d.${NC} %-44s ${DIM}%d MB${NC}\n" "$idx" "$(basename "$f")" "$fsz"
        done
        echo -e "\n  $(print_msg "mgr_total" "$file_count" "$total_mb")"
        echo -e "${YELLOW}[!] No log files found — cannot identify backup sets for cleanup.${NC}"
        return
    fi

    # 清理
    echo ""
    echo -n "  $(print_msg "mgr_keep_ask")"
    read -r keep_n

    [ -z "$keep_n" ] || [ "$keep_n" = "0" ] && return

    case "$keep_n" in
        *[!0-9]*) echo -e "${RED}[!] $(print_msg "mgr_keep_invalid")${NC}"; return ;;
    esac

    local del_count=$(( total_sets - keep_n ))
    if [ "$del_count" -le 0 ]; then
        echo -e "${GREEN}[✓] $(print_msg "mgr_nothing_to_del")${NC}"; return
    fi

    # 最旧的若干备份集
    local to_delete_logs
    to_delete_logs=$(printf '%s\n' $log_files | head -n "$del_count")

    # 估算释放空间
    local del_bytes=0
    local del_file_list=""
    for lf in $to_delete_logs; do

        del_bytes=$(( del_bytes + $(wc -c < "$lf" 2>/dev/null || echo 0) ))
        del_file_list="$del_file_list $lf"

        while IFS= read -r logline; do
            case "$logline" in
                "Backup successful:"*|"备份成功:"*)
                    local fname; fname=$(echo "$logline" | awk '{print $NF}')
                    fname=$(basename "$fname")
                    local fpath
                    fpath=$(find "$mgr_dir" -maxdepth 2 -name "$fname" -type f 2>/dev/null | head -1)
                    if [ -n "$fpath" ] && [ -f "$fpath" ]; then
                        del_bytes=$(( del_bytes + $(wc -c < "$fpath" 2>/dev/null || echo 0) ))
                        del_file_list="$del_file_list $fpath"
                        # 标记 .content.sha1
                        local sha_f="${fpath%.img}.content.sha1"
                        [ ! -f "$sha_f" ] && sha_f="${fpath%.img.gz}.content.sha1"
                        [ -f "$sha_f" ] && del_file_list="$del_file_list $sha_f"
                    fi
                    ;;
            esac
        done < "$lf"
    done
    local del_mb=$(( del_bytes / 1024 / 1024 ))

    echo -en "${RED}[!] $(print_msg "mgr_del_confirm" "$del_count" "$del_mb")${NC}"
    read -r confirm_del
    [ "$confirm_del" != "YES" ] && { echo "$(print_msg "cancel")"; return; }

    local freed=0
    for fpath in $del_file_list; do
        [ -f "$fpath" ] || continue
        local fs; fs=$(wc -c < "$fpath" 2>/dev/null || echo 0)
        freed=$(( freed + fs ))
        echo -e "  ${DIM}$(print_msg "mgr_deleting" "$(basename "$fpath")")${NC}"
        rm -f "$fpath"
    done

    # 清理 sha1sums.txt 失效条目
    local sums="$mgr_dir/sha1sums.txt"
    if [ -f "$sums" ]; then
        local tmp_s="${sums}.tmp"
        while IFS= read -r line; do
            local fn; fn=$(printf '%s' "$line" | awk '{print $2}')
            [ -f "$mgr_dir/$fn" ] && printf '%s\n' "$line"
        done < "$sums" > "$tmp_s"
        mv -f "$tmp_s" "$sums"
    fi

    echo -e "${GREEN}[✓] $(print_msg "mgr_done" "$((freed/1024/1024))")${NC}"
    log_msg "I" "Backup cleanup: deleted $del_count sets, freed ~$((freed/1024/1024)) MB"
}

# § 自定义分区备份
backup_custom() {
    [ "$PATH_SELECTED" -eq 0 ] && choose_path
    detect_device_type
    section "🎯" "$(print_msg "custom_title")"
    echo -e "${CYAN}$(print_msg "custom_hint")${NC}"

    # 显示可用分区
    echo -e "${DIM}  Available partitions:${NC}"
    local known
    known=$(ls "$BASE_COMMON" "$BASE_BOOTDEV" "$BASE_MAPPER" 2>/dev/null \
        | grep -v '^$' | sort -u \
        | sed 's/_[ab]$//' | sort -u \
        | tr '\n' ' ')
    echo -e "${DIM}  $known${NC}\n"

    echo -n "  $(print_msg "custom_prompt")"
    read -r custom_input
    [ -z "$custom_input" ] && { echo "$(print_msg "cancel")"; return; }

    local success=0 failed=0
    for pname in $custom_input; do
        # 优先带 slot 后缀
        local part=""
        if [ "$IS_AB" -eq 1 ]; then
            part=$(find_part "${pname}${SLOT}")
            [ -z "$part" ] && part=$(find_part "$pname")
        else
            part=$(find_part "$pname")
        fi

        if [ -z "$part" ]; then
            echo -e "${YELLOW}[!] $(print_msg "custom_not_found" "$pname")${NC}"
            failed=$(( failed + 1 ))
            continue
        fi

        local dest_name="${pname}${SLOT}"
        [ "$IS_AB" -eq 0 ] && dest_name="$pname"

        if backup_partition "$part" "$BACKUP_DIR/$dest_name" "$dest_name"; then
            success=$(( success + 1 ))
        else
            failed=$(( failed + 1 ))
        fi
    done

    echo -e "\n${GREEN}$(print_msg "boot_success" "$success" "$failed")${NC}"
    log_msg "I" "Custom backup: success=$success failed=$failed parts=$custom_input"
}

# § 多云同步
cloud_sync() {
    section "🌐" "$(print_msg "cloud_title")"

    # 枚举待上传文件
    local src_dir
    echo -n "$(print_msg "webdav_src_dir")"
    read -r src_dir
    [ -z "$src_dir" ] && src_dir="${BACKUP_DIR:-$DEFAULT_BACKUP}"
    if [ ! -d "$src_dir" ]; then
        echo -e "${RED}[!] $(print_msg "verify_dir_not_exist")${NC}"; return
    fi

    local files
    files=$(find "$src_dir" -maxdepth 2 \
        \( -name "*.img" -o -name "*.img.gz" -o -name "*.img.bz2" \
           -o -name "*.img.part_*" -o -name "*.tar.gz" \
           -o -name "sha1sums.txt" -o -name "*.log" \) \
        -type f 2>/dev/null | sort)

    if [ -z "$files" ]; then
        echo -e "${YELLOW}[!] $(print_msg "mgr_no_backups")${NC}"; return
    fi
    local total; total=$(printf '%s\n' $files | wc -l | tr -d ' ')

    # 选择后端
    echo -e "\n${CYAN}$(print_msg "cloud_backend_ask")${NC}"
    echo "  $(print_msg "cloud_backend_webdav")"
    echo "  $(print_msg "cloud_backend_rclone")"
    echo "  $(print_msg "cloud_backend_ftp")"
    echo -n "  > "
    read -r backend_sel

    case "$backend_sel" in
        1) _cloud_webdav   "$src_dir" "$files" "$total" ;;
        2) _cloud_rclone   "$src_dir" "$files" "$total" ;;
        3) _cloud_ftp_sftp "$src_dir" "$files" "$total" ;;
        *) echo -e "${RED}[!] $(print_msg "invalid_opt")${NC}" ;;
    esac
}

# 后端1: WebDAV
_cloud_webdav() {
    local src_dir="$1" files="$2" total="$3"
    # 复用 webdav_upload
    webdav_upload
}

# 后端2: rclone
_cloud_rclone() {
    local src_dir="$1" files="$2" total="$3"

    if ! command -v rclone >/dev/null 2>&1; then
        echo -e "${RED}[!] $(print_msg "cloud_rclone_missing")${NC}"
        echo -e "${DIM}  Termux: pkg install rclone${NC}"
        echo -e "${DIM}  Manual: curl https://rclone.org/install.sh | bash${NC}"
        return
    fi

    # 列出已配置 remote
    local remotes; remotes=$(rclone listremotes 2>/dev/null | tr -d ':' | tr '\n' ' ')
    if [ -z "$remotes" ]; then
        echo -e "${RED}[!] $(print_msg "cloud_rclone_no_remote")${NC}"
        echo -e "${DIM}  Run: rclone config${NC}"
        return
    fi
    echo -e "${CYAN}[i] Available remotes: ${BOLD}$remotes${NC}"
    echo -n "$(print_msg "cloud_rclone_remote")"
    read -r rclone_remote
    [ -z "$rclone_remote" ] && { echo "$(print_msg "cancel")"; return; }

    echo -n "$(print_msg "cloud_rclone_path")"
    read -r rclone_path
    [ -z "$rclone_path" ] && rclone_path="/GeekTool"
    rclone_path="/${rclone_path#/}"

    local device_name; device_name=$(getprop ro.product.model 2>/dev/null | tr ' ' '_')
    local date_stamp; date_stamp=$(date +%Y%m%d)
    local remote_dest="${rclone_remote}:${rclone_path}/${device_name}_${date_stamp}"

    echo -e "${CYAN}[>] Remote: ${BOLD}${remote_dest}${NC}"

    # 测试连接
    echo -e "${CYAN}[*] $(print_msg "webdav_test")${NC}"
    if ! rclone lsd "${rclone_remote}:" --max-depth 1 >/dev/null 2>&1; then
        echo -e "${RED}[!] $(print_msg "webdav_test_fail") (rclone connection failed)${NC}"
        return
    fi
    echo -e "${GREEN}[✓] $(print_msg "webdav_test_ok")${NC}"

    local success=0 failed=0 idx=0
    for fpath in $files; do
        idx=$(( idx + 1 ))
        local fname; fname=$(basename "$fpath")
        echo -e "${CYAN}[>] $(print_msg "cloud_uploading" "rclone" "$fname") [$idx/$total]${NC}"

        # rclone copyto 单文件上传
        if rclone copyto "$fpath" "${remote_dest}/${fname}" \
            --no-traverse \
            --retries 3 \
            --low-level-retries 5 \
            --stats-one-line \
            --progress \
            2>&1 | tail -1; then
            echo -e "${GREEN}[✓] $fname${NC}"
            success=$(( success + 1 ))
        else
            echo -e "${RED}[!] $(print_msg "webdav_upload_fail" "$fname")${NC}"
            failed=$(( failed + 1 ))
            log_msg "E" "rclone upload failed: $fname"
        fi
    done

    echo -e "\n${GREEN}$(print_msg "cloud_done" "$success" "$failed")${NC}"
    echo -e "${DIM}  Remote: $remote_dest${NC}"
    log_msg "I" "rclone upload done: success=$success failed=$failed remote=$remote_dest"
}

# 后端3: FTP/SFTP
_cloud_ftp_sftp() {
    local src_dir="$1" files="$2" total="$3"

    if ! command -v curl >/dev/null 2>&1; then
        echo -e "${RED}[!] $(print_msg "webdav_no_curl")${NC}"; return
    fi

    echo -n "$(print_msg "cloud_ftp_proto")"
    read -r ftp_proto_sel
    local proto="ftp"
    [ "$ftp_proto_sel" = "2" ] && proto="sftp"

    echo -n "$(print_msg "cloud_ftp_host")"
    read -r ftp_host
    [ -z "$ftp_host" ] && { echo "$(print_msg "cancel")"; return; }

    echo -n "$(print_msg "cloud_ftp_port")"
    read -r ftp_port
    [ -z "$ftp_port" ] && { [ "$proto" = "sftp" ] && ftp_port=22 || ftp_port=21; }

    echo -n "$(print_msg "cloud_ftp_user")"
    read -r ftp_user

    echo -n "$(print_msg "cloud_ftp_pass")"
    stty -echo 2>/dev/null; read -r ftp_pass; stty echo 2>/dev/null; echo ""

    echo -n "$(print_msg "cloud_ftp_remote")"
    read -r ftp_remote
    [ -z "$ftp_remote" ] && ftp_remote="/GeekTool"
    ftp_remote="/${ftp_remote#/}"; ftp_remote="${ftp_remote%/}/"

    local device_name; device_name=$(getprop ro.product.model 2>/dev/null | tr ' ' '_')
    local date_stamp; date_stamp=$(date +%Y%m%d)
    local remote_path="${ftp_remote}${device_name}_${date_stamp}/"
    local base_url="${proto}://${ftp_host}:${ftp_port}${remote_path}"

    # 测试连接
    echo -e "${CYAN}[*] $(print_msg "webdav_test")${NC}"
    local test_code
    test_code=$(curl -s -o /dev/null -w "%{http_code}" \
        --user "$ftp_user:$ftp_pass" \
        --max-time 15 \
        "${proto}://${ftp_host}:${ftp_port}/" 2>/dev/null)
    # FTP 成功返回 exit 0，非 HTTP code
    if curl -s --user "$ftp_user:$ftp_pass" --max-time 15 \
        "${proto}://${ftp_host}:${ftp_port}/" -o /dev/null 2>/dev/null; then
        echo -e "${GREEN}[✓] $(print_msg "webdav_test_ok")${NC}"
    else
        echo -e "${RED}[!] $(print_msg "webdav_test_fail")${NC}"; return
    fi

    local success=0 failed=0 idx=0
    for fpath in $files; do
        idx=$(( idx + 1 ))
        local fname; fname=$(basename "$fpath")
        echo -e "${CYAN}[>] $(print_msg "cloud_uploading" "$proto" "$fname") [$idx/$total]${NC}"
        if curl -s --user "$ftp_user:$ftp_pass" \
            --upload-file "$fpath" \
            --max-time 600 \
            --ftp-create-dirs \
            "${base_url}${fname}" 2>/dev/null; then
            echo -e "${GREEN}[✓] $fname${NC}"
            success=$(( success + 1 ))
        else
            echo -e "${RED}[!] $(print_msg "webdav_upload_fail" "$fname")${NC}"
            failed=$(( failed + 1 ))
            log_msg "E" "$proto upload failed: $fname"
        fi
    done

    echo -e "\n${GREEN}$(print_msg "cloud_done" "$success" "$failed")${NC}"
    log_msg "I" "$proto upload done: success=$success failed=$failed"
}

# § 设置菜单
settings_menu() {
    section "⚙️" "$(print_msg "settings_title")"

    # 语言
    echo -e "${CYAN}$(print_msg "lang_current")${NC}"
    echo "$(print_msg "lang_choice")"
    echo "  $(print_msg "lang_zh")"
    echo "  $(print_msg "lang_en")"
    echo -n "  > "
    read -r lc
    case "$lc" in
        1) CURRENT_LANG="zh" ;;
        2) CURRENT_LANG="en" ;;
        *) echo -e "${RED}[!] $(print_msg "invalid_opt")${NC}" ;;
    esac
    mkdir -p "$(dirname "$LANG_FILE")" 2>/dev/null
    echo "$CURRENT_LANG" > "$LANG_FILE" 2>/dev/null
    echo -e "${GREEN}[✓] $(print_msg "lang_saved")${NC}"

    # dd 块大小
    echo -e "\n${CYAN}$(print_msg "bs_setting")${NC}"
    echo "  1) $(print_msg "bs_1m")"
    echo "  2) $(print_msg "bs_4k")"
    echo -n "  > "
    read -r bs_sel
    [ "$bs_sel" = "2" ] && DD_BS="4096" || DD_BS="1M"
    echo -e "${GREEN}[i] $(print_msg "bs_selected")${NC}"

    # 备份引擎
    echo -e "\n${CYAN}$(print_msg "engine_title")${NC}"
    echo -e "  ${DIM}$(print_msg "engine_current" "$BACKUP_ENGINE")${NC}"
    echo "  $(print_msg "engine_dd")"
    echo "  $(print_msg "engine_sparse")"
    echo "  $(print_msg "engine_pigz")"
    echo "  $(print_msg "engine_pbzip2")"
    echo "  $(print_msg "engine_split")"
    echo -n "  > "
    read -r engine_sel
    case "$engine_sel" in
        1) BACKUP_ENGINE="dd" ;;
        2) BACKUP_ENGINE="sparse" ;;
        3) BACKUP_ENGINE="pigz" ;;
        4) BACKUP_ENGINE="pbzip2" ;;
        5) BACKUP_ENGINE="split" ;;
        *) echo -e "${YELLOW}[i] Keeping: $BACKUP_ENGINE${NC}" ;;
    esac

    # 多线程引擎线程数
    if [ "$BACKUP_ENGINE" = "pigz" ] || [ "$BACKUP_ENGINE" = "pbzip2" ]; then
        echo -n "  $(print_msg "engine_threads")"
        read -r thr
        case "$thr" in
            [1-8]) ENGINE_THREADS="$thr" ;;
            *) ENGINE_THREADS=4 ;;
        esac
        echo -e "${GREEN}[i] Threads: $ENGINE_THREADS${NC}"
    fi

    # split 分片大小
    if [ "$BACKUP_ENGINE" = "split" ]; then
        echo -n "  $(print_msg "engine_split_size")"
        read -r sp_mb
        case "$sp_mb" in
            ''|*[!0-9]*) ENGINE_SPLIT_MB=2048 ;;
            *) ENGINE_SPLIT_MB="$sp_mb" ;;
        esac
        echo -e "${GREEN}[i] Split size: ${ENGINE_SPLIT_MB}MB${NC}"
    fi

    echo -e "${GREEN}[✓] $(print_msg "engine_saved" "$BACKUP_ENGINE")${NC}"
    sleep 1
}

# § 主菜单
menu_loop() {
    while true; do
        print_banner
        detect_device_type
        show_system_info
        echo ""
        if [ "$CURRENT_LANG" = "en" ]; then
            echo -e "${DIM}  Language: English | S = Settings${NC}"
        else
            echo -e "${DIM}  当前语言: 中文 | S = 设置${NC}"
        fi
        echo ""
        echo -e "${BOLD}${LCYAN}  $(print_msg "main_menu")${NC}"
        echo -e "${LCYAN}  ──────────────────────────${NC}"
        echo -e "  ${CYAN}1.${NC} $(print_msg "menu_1")"
        echo -e "  ${CYAN}2.${NC} $(print_msg "menu_2")"
        echo -e "  ${CYAN}3.${NC} $(print_msg "menu_3")"
        echo -e "  ${CYAN}4.${NC} $(print_msg "menu_4")"
        echo -e "  ${CYAN}5.${NC} $(print_msg "menu_5")"
        echo -e "  ${YELLOW}6.${NC} $(print_msg "menu_6")"
        echo -e "  ${CYAN}7.${NC} $(print_msg "menu_7")"
        echo -e "  ${LGREEN}8.${NC} $(print_msg "menu_8")"
        echo -e "  ${LGREEN}9.${NC} $(print_msg "menu_9")"
        echo -e "  ${LGREEN}A.${NC} $(print_msg "menu_a")"
        echo -e "  ${LGREEN}B.${NC} $(print_msg "menu_b")"
        echo -e "  ${DIM}S.${NC} $(print_msg "menu_s")"
        echo -e "  ${DIM}0.${NC} $(print_msg "menu_0")"
        echo ""
        echo -n "  $(print_msg "menu_prompt")"
        read -r ch
        case "$ch" in
            1) backup_boot ;;
            2) backup_efs ;;
            3) backup_metadata ;;
            4) backup_all ;;
            5) incremental_backup ;;
            6) restore_partition ;;
            7) verify_backup ;;
            8) ota_payload_extract ;;
            9) cloud_sync ;;
            a|A) backup_custom ;;
            b|B) backup_manager ;;
            s|S) settings_menu ;;
            0) cleanup 0 ;;
            *) echo -e "${RED}[!] $(print_msg "invalid_opt")${NC}"; sleep 1; continue ;;
        esac
        echo -e "\n${YELLOW}$(print_msg "press_enter")${NC}"
        read -r _dummy
    done
}

# § 启动检查
if [ "$(id -u)" != "0" ]; then
    echo -e "${RED}[!] $(print_msg "err_root")${NC}"; exit 1
fi

# SELinux
if command -v getenforce >/dev/null 2>&1; then
    if [ "$(getenforce)" = "Enforcing" ]; then
        echo -e "${YELLOW}[⚠] $(print_msg "selinux_msg")${NC}"
        SELINUX_WAS_ENFORCING=1
        setenforce 0 2>/dev/null || true
    fi
fi

# 选择 dd 块大小
echo -e "${YELLOW}$(print_msg "bs_choice")${NC}"
echo "  1) $(print_msg "bs_1m")"
echo "  2) $(print_msg "bs_4k")"
echo -n "  > "
read -r _bs_sel
[ "$_bs_sel" = "2" ] && DD_BS="4096" || DD_BS="1M"
echo -e "${GREEN}[i] $(print_msg "bs_selected")${NC}"
sleep 1

detect_device_type
menu_loop
