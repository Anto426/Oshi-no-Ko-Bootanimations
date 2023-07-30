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

  ui_print "- Remounting /product Partition"
  mount -o remount,rw /product

  ui_print "- Copy original Bootanimation"
  cp /data/adb/modules/Oshi_no_ko_bootanimation-lite/backup/bootanimation.zip /product/media/ >/dev/null 2>&1

  ui_print "- Remove file module"
  rm -r /data/adb/modules/Oshi_no_ko_bootanimation-lite/
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
