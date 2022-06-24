#!/data/data/com.termux/files/usr/bin/env bash

# termux-playstore-fixer - A script that revive termux from playstore back to live.
# Written by Yonle <yonle@duck.com>, Licensed under BSD 3 Clause

ready() {
  if ! [ -d "/data/data/com.termux/cache" ]; then
    mkdir /data/data/com.termux/cache
  fi

  echo -e "\nYou're now ready to go."
  echo "Please execute the following command to relogin:"
  echo "  $ exec login"
  exit 0
}

patch_login() {
  cat <<-EOM | patch -R -p1 /data/data/com.termux/files/usr/bin/login
diff -uNr /data/data/com.termux/files/usr/bin/login /data/data/com.termux/files/usr/bin/login.mod
--- /data/data/com.termux/files/usr/bin/login	2022-06-24 22:26:58.921000163 +0700
+++ /data/data/com.termux/files/usr/bin/login.mod	2022-06-25 00:16:31.345000555 +0700
@@ -7,11 +7,6 @@
 	unset TERMUX_HUSHLOGIN
 fi
 
-# TERMUX_VERSION env variable has been exported since v0.107 and PATH was being set to following value in <0.104. Last playstore version was v0.101.
-if [ \$# = 0 ] && [ -f /data/data/com.termux/files/usr/etc/motd-playstore ] && [ -z "\$TERMUX_VERSION" ] && [ "\$PATH" = "/data/data/com.termux/files/usr/bin:/data/data/com.termux/files/usr/bin/applets" ]; then
-	printf '\033[0;31m'; cat /data/data/com.termux/files/usr/etc/motd-playstore; printf '\033[0m'
-fi
-
 if [ -G ~/.termux/shell ]; then
 	export SHELL="\`realpath ~/.termux/shell\`"
 else
EOM
  if [ "$?" = "0" ]; then
    echo "Succesfully Patched."
    ready
  fi
}

remove_playstore_deprecation_warning() {
  read -p "Do you want to remove the deprecation warning? [y/n/v] " s

  case $s in
    y|Y)  patch_login ;;
    n|N)  ready ;;
    ?|v|V)  cat $PREFIX/etc/motd-playstore; remove_playstore_deprecation_warning ;;
    *)  remove_playstore_deprecation_warning ;;
  esac
}

upgrade_environment() {
  apt-get dist-upgrade -y
  if [ "$?" = "0" ]; then
    remove_playstore_deprecation_warning
  fi
}

rm -rf $PREFIX/var/spool $PREFIX/etc/apt/sources.list.d/{game,science}.list 
echo "deb https://grimler.se/termux-packages-24 stable main" > $PREFIX/etc/apt/sources.list

if [ -f "/data/data/com.termux/files/usr/etc/apt/sources.list.d/root.list" ]; then
  echo "deb https://grimler.se/termux-root-packages-24 root stable" > /data/data/com.termux/files/usr/etc/apt/sources.list.d/root.list
fi

if [ -f "/data/data/com.termux/files/usr/etc/apt/sources.list.d/x11.list" ]; then
  echo "deb https://grimler.se/x11-packages x11 main" > /data/data/com.termux/files/usr/etc/apt/sources.list.d/x11.list
fi

apt-get update --allow-insecure-repositories
apt-get install termux-keyring --allow-unauthenticated -y && apt-get update

apt-get install openssl1.1 -y && echo -n "Relinking openssl1.1 for compatibility... "; ln -s $PREFIX/lib/openssl-1.1/{engines-1.1,lib{crypto,ssl}.so.1.1} $PREFIX/lib && echo "Done"

# Some packages should be downloaded & installed in a order
# Installing them all in single command will mess the environment instantly
for i in diffutils coreutils liblzma patch; do
  apt-get install $i -y
  if [ "$?" != "0" ]; then
    echo "An error occured. Please try again or report this error to"
    echo "https://github.com/Yonle/yonle-tools/issues"
    exit 6
  fi
done

if [ "$?" != "0" ]; then
  echo "An error occured. Please try again or report this error to"
  echo "https://github.com/Yonle/yonle-tools/issues"
  exit 6
fi

echo -n "Removing unusued busybox applets... "
export PATH=/data/data/com.termux/files/usr/bin

rm -rf $PREFIX/bin/applet
echo "Done"

upgrade_environment
