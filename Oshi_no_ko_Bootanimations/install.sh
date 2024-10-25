SKIPMOUNT=false
PROPFILE=false
POSTFSDATA=false
LATESTARTSERVICE=false

print_modname() {
  ui_print "***********************************************************"
  ui_print "*              ❤️ Oshi no ko bootanimations               *"
  ui_print "*   An Oshi no Ko themed startup animation for Android    *"
  ui_print "***********************************************************"
}

on_install() {
  nboot=0
  choice=1

  ui_print "- Extracting module files"
  unzip -o "$ZIPFILE" 'media/*' -d $MODPATH >&2

  ui_print "- Downloading and installing dependency"
  mkdir -p "$MODPATH/magic_overlayfs"
  latest_url=$(curl -s "https://api.github.com/repos/HuskyDG/magic_overlayfs/releases/latest" | grep "browser_download_url" | cut -d '"' -f 4)

  if [ -z "$latest_url" ]; then
    ui_print "- Failed to get the download URL for magic_overlayfs"
    exit 1
  fi

  ui_print "- Downloading magic_overlayfs.zip from $latest_url"
  wget -qO "$MODPATH/magic_overlayfs/magic_overlayfs.zip" "$latest_url"
  
  if [ $? -ne 0 ]; then
    ui_print "- Error occurred while downloading magic_overlayfs"
    exit 1
  fi

  ui_print "- Installing magic_overlayfs module"
  magisk --install-module "$MODPATH/magic_overlayfs/magic_overlayfs.zip"

  if [ $? -ne 0 ]; then
    ui_print "- Failed to install magic_overlayfs module"
    exit 1
  fi

  ui_print "- Remounting /product Partition"
  mount -o remount,rw /product

  ui_print "- Backing up original Bootanimation"
  mkdir -p "$MODPATH/backup"
  if [ -e /data/adb/modules/Oshi_no_ko_bootanimation-lite/backup/bootanimation.zip ]; then
    ui_print "- Found old backup."
    cp /data/adb/modules/Oshi_no_ko_bootanimation-lite/backup/bootanimation.zip $MODPATH/backup/
  else
    ui_print "- No previous backup found, creating a new one."
    cp /product/media/bootanimation.zip $MODPATH/backup/
  fi

  boot_options=("🌟AI" "💎Ruby" "🌊Aqua" "🔴Kana" "⭐Akane" "🔵MemCho")
  nboot=${#boot_options[@]}

  ui_print "- Select bootanimation file"
  for i in "${!boot_options[@]}"; do
    ui_print "$((i + 1))) ${boot_options[i]}"
  done

  ui_print "- Choose your favorite bootanimation!"
  ui_print "- Use volume up key to choose and volume down to confirm!"

  choice=1
  key_pressed=false

  while true; do
    event=$(getevent -lqc 1)

    if echo "$event" | grep -q "EV_KEY"; then
      if echo "$event" | grep -q "DOWN"; then
        if ! $key_pressed; then
          key_pressed=true
          if echo "$event" | grep -q "KEY_VOLUMEUP"; then
            choice=$(( (choice % nboot) + 1 ))
          elif echo "$event" | grep -q "KEY_VOLUMEDOWN"; then
            break
          fi
          ui_print "Your choice: ${boot_options[$((choice - 1))]}"
        fi
      else
        key_pressed=false
      fi
    fi
  done

  selected_boot="${boot_options[$((choice - 1))]}"
  filtered_element=$(echo "$selected_boot" | sed 's/[^[:alnum:]]//g')

  ui_print "- Downloading Bootanimation"
  mkdir -p "$MODPATH/media"
  url="https://github.com/Anto426/Oshi-no-Ko-Bootanimation/releases/download/1.$((choice - 1)).0/${filtered_element}0.zip"
  wget -qO "$MODPATH/media/${filtered_element}0.zip" "$url"

  if [ $? -ne 0 ]; then
    ui_print "- Error occurred during download"
    exit 1
  fi

  ui_print "- Renaming ${filtered_element}0.zip to bootanimation.zip"
  mv "$MODPATH/media/${filtered_element}0.zip" "$MODPATH/media/bootanimation.zip"

  ui_print "- Copying Bootanimation"
  cp -vf "$MODPATH/media/bootanimation.zip" /product/media/ >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    ui_print "- Bootanimation file copied successfully"
  else
    ui_print "- Error occurred while copying the bootanimation file"
  fi
}

set_permissions() {
  set_perm_recursive $MODPATH 0 0 0755 0644
  reboot_device
}

reboot_device() {
  ui_print "- Rebooting now..."
  su -c "reboot"
}

