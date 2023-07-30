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

  ui_print "- Remounting /product Partition"
  mount -o remount,rw /product

  ui_print "- Backup original Bootanimation"

  cd /data/adb/modules/Oshi_no_ko_bootanimation-lite/backup/
  if [ -e bootanimation.zip ]; then
    ui_print "- Foud Old Backup."
    mkdir "$MODPATH/backup"
    cp /data/adb/modules/Oshi_no_ko_bootanimation-lite/backup/bootanimation.zip $MODPATH/backup >/dev/null 2>&1
  else
    ui_print "- Not Foud Old Backup."
    ui_print "- Create Backup"
    mkdir "$MODPATH/backup"
    cp "/product/media/bootanimation.zip" $MODPATH/backup/
  fi

  boot="🌟AI 💎Ruby 🌊Aqua 🔴Kana ⭐Akane 🔵MemCho"

  ui_print "- Select bootanimation file"
  for element in $boot; do
    nboot=$((nboot + 1))
    ui_print "$nboot )$element"
  done
  ui_print "- Choose your favorite bootanimation!"
  ui_print "- Use volume up key to choose boot animation and volume down to confirm !"

  choice=1
  key_pressed=false

  while true; do
    event=$(getevent -lqc 1)

    if echo "$event" | grep -q "EV_KEY"; then
      key=$(echo "$event")

      if echo "$event" | grep -q "DOWN"; then
        if ! $key_pressed; then
          key_pressed=true

          if echo "$key" | grep -q "KEY_VOLUMEUP"; then
            choice=$((choice + 1))
          elif echo "$key" | grep -q "KEY_VOLUMEDOWN"; then
            break
          fi

          if [ $choice -gt $nboot ]; then
            choice=1
          fi
          temp=$(echo "$boot" | cut -d ' ' -f $((choice)))
          ui_print "Your choice: $temp"
        fi
      else
        key_pressed=false
      fi
    fi
  done

  ui_print "- Downloading Bootanimation"
  mkdir "$MODPATH/media/"
  cd "$MODPATH/media/"

  element=$(echo "$boot" | cut -d ' ' -f $((choice)))
  filtered_element=$(echo "$element" | sed -e 's/[^[:alnum:][:space:][:punct:]]//g')
  progress=0
  progress_bar=""

  # Funzione per generare la barra di avanzamento in base al progresso
  generate_progress_bar() {
    local width=20
    local completed=$((progress * width / 100))
    local remaining=$((width - completed))
    progress_bar="[$(printf '#%.0s' $(seq 1 $completed))$(printf '-%.0s' $(seq 1 $remaining))]"
  }

  ui_print "- https://github.com/Anto426/Oshi-no-Ko-Bootanimation/releases/download/1.$((choice - 1)).0/${filtered_element}0.zip"
  wget "https://github.com/Anto426/Oshi-no-Ko-Bootanimation/releases/download/1.$((choice - 1)).0/${filtered_element}0.zip" >/dev/null 2>&1 &
  pid=$!

  while kill -0 $pid >/dev/null 2>&1; do
    generate_progress_bar

    ui_print "Progress: $progress_bar ($progress%)"

    sleep 1
    progress=$((progress + 5))
  done

  if [ $? -eq 0 ]; then
    ui_print "- File downloaded successfully"
  else
    ui_print "- An error occurred while downloading the file. The program will exit."
    exit 1
  fi

  ui_print "- Rename ${filtered_element}0.zip to bootanimation.zip"
  mv "$MODPATH/media/${filtered_element}0.zip" "$MODPATH/media/bootanimation.zip"

  ui_print "- Copying Bootanimation"
  cp -vf "$MODPATH/media/bootanimation.zip" "/product/media/" >/dev/null 2>&1
  cp_exit_code=$?

  if [ $cp_exit_code -eq 0 ]; then
    ui_print "- Bootanimation file copied successfully"
  else
    ui_print "- An error occurred during the bootanimation file copy"
    ui_print "- Error details: $(cp -vf "$MODPATH/media/bootanimation.zip" "/product/media/" 2>&1 >/dev/null)"
  fi

}

set_permissions() {
  set_perm_recursive $MODPATH 0 0 0755 0644
  reboot
}

reboot() {
  ui_print "- Rebooting now..."
  su -c "reboot"
}
#######################################################################
