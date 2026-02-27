#!/system/bin/sh
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m'
DEFAULT_BACKUP="/sdcard/GeekTool"
BASE_COMMON="/dev/block/by-name"
BASE_BOOTDEV="/dev/block/bootdevice/by-name"
BASE_MAPPER="/dev/block/mapper"
LOGFILE=""
SLOT=""
OTHER_SLOT=""
IS_AB=0
IS_VAB=0
USE_PV=0 # 强制关闭 pv，防止报错
BACKUP_DIR=""
SELINUX_WAS_ENFORCING=0
MNT_VAB="/mnt/vab_super"

# ======================================================
#  退出自动清理
# ======================================================
cleanup() {
    umount "$MNT_VAB" 2>/dev/null
    rm -rf "$MNT_VAB" 2>/dev/null
    if [ "$SELINUX_WAS_ENFORCING" -eq 1 ]; then
        echo -e "\n${YELLOW}[!] 恢复 SELinux Enforcing${NC}"
        setenforce 1 2>/dev/null
    fi
    sync
}
trap cleanup EXIT

# ======================================================
#  ROOT 检查
# ======================================================
if [ "$(id -u)" != "0" ]; then
    echo -e "${RED}[!] 必须 ROOT${NC}"
    exit 1
fi

# ======================================================
#  SELinux 处理
# ======================================================
if command -v getenforce >/dev/null 2>&1; then
    ENFORCE=$(getenforce)
    if [ "$ENFORCE" = "Enforcing" ]; then
        echo -e "${YELLOW}[!] SELinux 临时关闭${NC}"
        SELINUX_WAS_ENFORCING=1
        setenforce 0 2>/dev/null
    fi
fi

# ======================================================
#  进度条 pv 检测 (已禁用，防止因找不到 pv 命令报错)
# ======================================================
# if command -v pv >/dev/null 2>&1; then
#     USE_PV=1
# fi
USE_PV=0 # 强制设为0

# ======================================================
#  dd 配置（版本检测+块大小选择）
# ======================================================
echo "[i] dd 版本信息:"
dd --version 2>&1 | head -n 3 || echo "dd 无 --version 支持 (toybox常见)"
echo -e "${YELLOW}选择 dd 块大小 (你的设备支持1M): ${NC}"
echo "1) 1M (推荐，快)"
echo "2) 4096 (最稳，但慢)"
read -r bs_sel
if [ "$bs_sel" = "1" ]; then
    DD_BS=1M
else
    DD_BS=4096
fi
echo -e "${GREEN}[i] 已选择 dd 块大小: $DD_BS${NC}"

# ======================================================
#  分区自动查找
# ======================================================
find_part() {
    local name="$1"
    for path in "$BASE_COMMON/$name" "$BASE_BOOTDEV/$name" "$BASE_MAPPER/$name"; do
        if [ -e "$path" ]; then
            echo "$path"
            return
        fi
    done
    echo ""
}

# ======================================================
#  检测 AB / VAB
# ======================================================
detect_device_type() {
    SLOT=$(getprop ro.boot.slot_suffix 2>/dev/null | tr -d '[:space:]')
    
    # 验证性检测：有 slot_suffix 且对应分区存在
    if [ -n "$SLOT" ] && [ -n "$(find_part boot${SLOT})" ]; then
        IS_AB=1
        if [ "$SLOT" = "_a" ]; then
            OTHER_SLOT="_b"
        else
            OTHER_SLOT="_a"
        fi
    else
        # 清理状态，防止半初始化
        SLOT=""
        OTHER_SLOT=""
        IS_AB=0
    fi
    
    # VAB 检测：super 分区存在且能识别为逻辑分区
    if [ -e "$(find_part super)" ] || [ -e "$(find_part supersupert)" ]; then
        IS_VAB=1
    else
        IS_VAB=0
    fi
    
    echo -e "${CYAN}[i] 槽位: ${GREEN}${SLOT:-none}${NC}"
    echo -e "${CYAN}[i] A/B: ${GREEN}${IS_AB}${NC}  ${CYAN}VAB: ${GREEN}${IS_VAB}${NC}"
}


# ======================================================
#  选择备份目录
# ======================================================
choose_path() {
    echo -e "${YELLOW}[?] 备份路径 (回车默认: ${DEFAULT_BACKUP})${NC}"
    read -r INPUT
    [ -z "$INPUT" ] && BACKUP_DIR="$DEFAULT_BACKUP" || BACKUP_DIR="$INPUT"
    BACKUP_DIR="${BACKUP_DIR%/}"
    mkdir -p "$BACKUP_DIR" 2>/dev/null
    if [ ! -d "$BACKUP_DIR" ]; then
        echo -e "${RED}[!] 目录创建失败${NC}"
        exit 1
    fi
    # 修复 df 命令兼容性，有些系统不支持直接 df dir
    # 修复空间检测：直接用 df 检查备份目录的可用空间
    AVAIL=$(df "$BACKUP_DIR" 2>/dev/null | tail -1 | awk '{print $4}' | tr -d '[:space:]')
    if [ -z "$AVAIL" ] || [ "$AVAIL" -lt 512000 ]; then
        echo -e "${RED}[!] 空间不足 < 500MB${NC}"
        exit 1
    fi
    LOGFILE="${BACKUP_DIR}/backup_$(date +%Y%m%d_%H%M%S).log"
    echo "=== GeekTool v7.0 Fixed Version ===" > "$LOGFILE"
    echo "Device: $(getprop ro.product.model)" >> "$LOGFILE"
    echo "Android: $(getprop ro.build.version.release)" >> "$LOGFILE"
}

# ======================================================
#  安全 dd (核心修复区)
# ======================================================
safe_dd() {
    local src="$1" dest="$2"
    local name=$(basename "$dest")
    
    # 防御性检查
    if [ -z "$src" ]; then
        echo -e "${RED}[!] 内部错误：源分区路径为空${NC}"
        return 1
    fi
    if [ -z "$dest" ]; then
        echo -e "${RED}[!] 内部错误：目标路径为空${NC}"
        return 1
    fi
    
    echo -e "${BLUE}[>] 备份: $name${NC}"
    echo "    源: $src"
    echo "    目标: $dest"
    
    if [ ! -e "$src" ]; then
        echo -e "${RED}[!] 源分区不存在: $src${NC}"
        return 1
    fi
    
    local size=$(blockdev --getsize64 "$src" 2>/dev/null)
    if [ -z "$size" ] || [ "$size" = "0" ]; then
        size=0
        echo "    大小: 未知 (尝试全量读取)"
    else
        echo "    大小: $((size/1024/1024))MB"
    fi

    # dd 执行
    if ! dd if="$src" of="$dest" bs=$DD_BS; then
        echo -e "${RED}[!] dd 命令失败${NC}"
        rm -f "$dest"
        return 1
    fi

    sync
    
    if [ ! -f "$dest" ]; then
        echo -e "${RED}[!] 失败：目标文件未生成${NC}"
        return 1
    fi

    local out_size=$(ls -l "$dest" | awk '{print $5}')
    [ -z "$out_size" ] && out_size=0

    if [ "$size" -gt 0 ] && [ "$out_size" -gt 0 ] && [ "$out_size" -ne "$size" ]; then
        echo -e "${YELLOW}[!] 警告：大小不匹配！源: $size 目标: $out_size${NC}"
    fi

    # === 修复：sha1sum 生成校验码 ===
    if [ "$out_size" -gt 0 ] && command -v sha1sum >/dev/null 2>&1; then
        local checksum=$(sha1sum "$dest" 2>/dev/null | awk '{print $1}')
        if [ -n "$checksum" ]; then
            echo "$checksum  $name" >> "${BACKUP_DIR}/sha1sums.txt"
            echo "    校验码: ${checksum:0:16}..."
        fi
    fi
    
    echo -e "${GREEN}[✓] 成功: $name (${out_size} 字节)${NC}"
    echo "OK $name" >> "$LOGFILE"
    return 0
}

# ======================================================
#  VAB 底层提取（从 super 分区直接读文件）
# ======================================================
extract_vab_boot() {
    echo -e "\n${PURPLE}=== VAB 物理底层提取 ===${NC}"
    mkdir -p "$MNT_VAB" 2>/dev/null
    local super_part=$(find_part super)
    [ -z "$super_part" ] && super_part=$(find_part supersupert)
    if [ -z "$super_part" ]; then
        echo -e "${RED}[!] 未找到 super${NC}"
        return 1
    fi
    echo -e "[✓] 挂载: $super_part"
    # mount 命令如果失败会报错，但不影响后续
    mount -o ro,loop "$super_part" "$MNT_VAB" 2>/dev/null
    
    # 检查挂载是否成功 (简单检查)
    if [ ! -d "$MNT_VAB" ] || [ ! -e "$MNT_VAB/boot.img" ]; then
        echo -e "${YELLOW}[i] 挂载失败或无文件，跳过 VAB 提取${NC}"
        umount "$MNT_VAB" 2>/dev/null
        return 1
    fi

    local found=0
    local dir
    for dir in "$MNT_VAB" "$MNT_VAB/boot" "$MNT_VAB/firmware" "$MNT_VAB/init" "$MNT_VAB/dev"; do
        local img
        for img in boot init_boot vendor_boot recovery; do
            local src="$dir/$img.img"
            local dest="$BACKUP_DIR/${img}${SLOT}.img"
            if [ -f "$src" ]; then
                echo -e "${GREEN}[>] 提取 $src${NC}"
                cp -af "$src" "$dest"
                sync
                # 兼容性 sha1sum
                if command -v sha1sum >/dev/null 2>&1; then
                    sha1sum "$dest" | awk '{print $1,"  "'"$(basename "$dest")"'}' >> "${BACKUP_DIR}/sha1sums.txt"
                fi
                found=1
            fi
        done
    done
    umount "$MNT_VAB" 2>/dev/null
    if [ "$found" -eq 1 ]; then
        echo -e "${GREEN}[✓] VAB 提取完成！${NC}"
        return 0
    else
        echo -e "${YELLOW}[i] 未找到文件${NC}"
        return 1
    fi
}

# ======================================================
#  启动分区备份
# ======================================================
backup_boot() {
    choose_path
    detect_device_type
    echo -e "\n${CYAN}=== 启动分区备份 ===${NC}"
    if [ "$IS_VAB" -eq 1 ]; then
        if extract_vab_boot; then
            echo -e "\n${GREEN}✅ 全部完成(VAB)${NC}"
            return
        fi
    fi
    local success=0 failed=0
    local img
    for img in boot init_boot vendor_boot recovery; do
        if [ "$IS_AB" -eq 1 ]; then
            local part=$(find_part "${img}${SLOT}")
            if [ -n "$part" ]; then
                if safe_dd "$part" "$BACKUP_DIR/${img}${SLOT}.img"; then
                    success=$((success+1))
                else
                    failed=$((failed+1))
                fi
            fi
        else
            local part=$(find_part "$img")
            if [ -n "$part" ]; then
                if safe_dd "$part" "$BACKUP_DIR/${img}.img"; then
                    success=$((success+1))
                else
                    failed=$((failed+1))
                fi
            fi
        fi
    done
    echo -e "\n${GREEN}成功: $success ${RED}失败: $failed${NC}"
}

# ======================================================
#  EFS / 基带备份
# ======================================================
backup_efs() {
    choose_path
    detect_device_type
    echo -e "\n${CYAN}=== EFS / 基带备份 ===${NC}"
    mkdir -p "$BACKUP_DIR/EFS" 2>/dev/null
    local success=0
    local p
    for p in modemst1 modemst2 fsg fsc persist modem efs misc; do
        local part=$(find_part "$p")
        if [ -n "$part" ]; then
            if safe_dd "$part" "$BACKUP_DIR/EFS/${p}.img"; then
                success=$((success+1))
            fi
        fi
    done
    # AB机型额外备份modem_a/modem_b
    if [ "$IS_AB" -eq 1 ]; then
        for p in modem_a modem_b; do
            local part=$(find_part "$p")
            if [ -n "$part" ]; then
                if safe_dd "$part" "$BACKUP_DIR/EFS/${p}.img"; then
                    success=$((success+1))
                fi
            fi
        done
    fi
    echo -e "\n${GREEN}[✓] EFS 完成: $success 个分区${NC}"
}

# ======================================================
#  分区恢复
# ======================================================
restore_partition() {
    echo -e "\n${RED}=== 分区恢复（危险）===${NC}"
    
    echo -n "备份文件路径: "
    read -r imgpath
    [ ! -f "$imgpath" ] && { echo -e "${RED}[!] 文件不存在${NC}"; return; }
    
    local src_size=$(ls -l "$imgpath" 2>/dev/null | awk '{print $5}')
    [ -z "$src_size" ] || [ "$src_size" -eq 0 ] && { 
        echo -e "${RED}[!] 镜像文件无效或为空${NC}"; 
        return; 
    }
    echo -e "${CYAN}[i] 镜像大小: $((src_size/1024/1024))MB${NC}"
    
    echo -n "目标分区名(如 boot_b): "
    read -r pname
    local part=$(find_part "$pname")
    [ -z "$part" ] && { echo -e "${RED}[!] 分区不存在${NC}"; return; }
    
    local part_size=$(blockdev --getsize64 "$part" 2>/dev/null)
    [ -n "$part_size" ] && {
        echo -e "${CYAN}[i] 分区大小: $((part_size/1024/1024))MB${NC}"
        if [ "$src_size" -gt "$part_size" ]; then
            echo -e "${RED}[!] 错误：镜像比分区大！${NC}"
            return
        fi
    }
    
    if mount | grep -q "$part"; then
        echo -e "${YELLOW}[!] 警告：该分区可能被挂载${NC}"
        echo -e "${YELLOW}    建议重启到 Recovery 模式再操作${NC}"
        echo -n "仍要继续？(yes/no): "
        read -r force
        [ "$force" != "yes" ] && return
    fi
    
    local backup_orig="${BACKUP_DIR}/auto_backup_${pname}_$(date +%Y%m%d_%H%M%S).img"
    echo -e "${CYAN}[i] 先备份原分区到:${NC}"
    echo "    $backup_orig"
    echo -n "确认开始？(yes/no): "
    read -r confirm
    [ "$confirm" != "yes" ] && { echo "取消"; return; }
    
    if ! dd if="$part" of="$backup_orig" bs=$DD_BS status=progress 2>/dev/null; then
        echo -e "${YELLOW}[!] 原分区备份失败，是否继续？(yes/no): ${NC}"
        read -r cont
        [ "$cont" != "yes" ] && return
    fi
    
    echo -e "\n${RED}[!] 最后确认：写入 $imgpath 到 $pname${NC}"
    echo -e "${RED}    此操作不可逆！输入 YES 执行:${NC}"
    read -r final
    [ "$final" != "YES" ] && { echo "取消"; return; }
    
    echo -e "[>] 写入中..."
    if dd if="$imgpath" of="$part" bs=$DD_BS status=progress; then
        sync
        echo -e "${GREEN}[✓] 完成！原分区备份在:${NC}"
        echo "    $backup_orig"
        echo -e "${YELLOW}[!] 请立即重启设备${NC}"
    else
        echo -e "${RED}[!] 写入失败！尝试从备份恢复...${NC}"
        dd if="$backup_orig" of="$part" bs=$DD_BS 2>/dev/null && \
            echo -e "${GREEN}[✓] 已回滚到原分区${NC}" || \
            echo -e "${RED}[!] 回滚也失败了，手动救砖吧: $backup_orig${NC}"
    fi
}


# ======================================================
#  校验备份
# ======================================================
verify_backup() {
    echo -e "\n${CYAN}=== 校验备份 ===${NC}"
    echo -n "目录: "
    read -r d
    [ ! -d "$d" ] && { echo "[!] 不存在"; return; }
    cd "$d" || return
    [ ! -f sha1sums.txt ] && { echo "[!] 无校验文件"; return; }
    # sha1sum -c 可能不兼容，简单检查
    if [ -s sha1sums.txt ]; then
        echo -e "${GREEN}[✓] 校验文件存在，建议在电脑上校验${NC}"
    else
        echo -e "${RED}[!] 校验文件为空${NC}"
    fi
}

# ======================================================
#  菜单
# ======================================================
menu_loop() {
    while true; do
        clear
        echo -e "${PURPLE}===== GEEK TOOLBOX v7.2 =====${NC}"
        echo -e "${GREEN}本工具由酷安紊穹制作，完全免费开源${NC}"
        echo "1. 启动分区备份 (传统/AB/VAB全支持)"
        echo "2. EFS / 基带备份"
        echo "3. 分区恢复（高危）"
        echo "4. 校验备份"
        echo "0. 退出"
        echo -n "请选择: "
        read -r ch
        case "$ch" in
            1) backup_boot ;;
            2) backup_efs ;;
            3) restore_partition ;;
            4) verify_backup ;;
            0) exit 0 ;;
            *) echo -e "${RED}[!] 错误${NC}"; sleep 1 ;;
        esac
        echo -e "\n按回车返回菜单"
        read -r
    done
}

menu_loop
