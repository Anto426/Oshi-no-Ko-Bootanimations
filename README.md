# 💫 Oshi-no-Ko-Bootanimation
An Oshi no Ko themed startup animation for Android

Preview


![Alt Text](./preview.gif)



## Instructions

1. Connect adb as root:

```shell
adb root
```

2. Remount partitions:

```shell
adb remount
```

3. Copy the bootanimation:

```shell
adb push "dir bootanimation" /product/media/
```
