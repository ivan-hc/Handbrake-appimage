#!/bin/sh

# NAME OF THE APP BY REPLACING "SAMPLE"
APP=handbrake
BIN="ghb"
DEPENDENCES="bzip2 desktop-file-utils ffmpeg gst-libav gst-plugin-gtk gst-plugin-libcamera gst-plugin-msdk gst-plugin-opencv gst-plugins-bad gst-plugins-bad-libs gst-plugins-base gst-plugins-base-libs gst-plugins-espeak gst-plugins-good gst-plugins-ugly gstreamer intltool jansson lame libass libdvdcss libdvdnav libdvdread libgudev libjpeg-turbo librsvg libtheora libva libvorbis libvpx libxml2 nasm numactl opus x264 xz zlib"
#BASICSTUFF="binutils gzip"
#COMPILERS="gcc"

# ADD A VERSION, THIS IS NEEDED FOR THE NAME OF THE FINEL APPIMAGE, IF NOT AVAILABLE ON THE REPO, THE VALUE COME FROM AUR, AND VICE VERSA
VERSION=$(wget -q https://archlinux.org/packages/extra/x86_64/handbrake/flag/ -O - | grep -i handbrake | head -1 | grep -o -P '(?<=handbrake ).*(?=</title)' | sed 's/(//g' | sed 's/)//g' | sed 's/ /-/g')

# CREATE THE APPDIR (DON'T TOUCH THIS)...
wget -q https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage -O appimagetool
chmod a+x appimagetool
mkdir $APP.AppDir

# ENTER THE APPDIR
cd $APP.AppDir

# SET APPDIR AS A TEMPORARY $HOME DIRECTORY, THIS WILL DO ALL WORK INTO THE APPDIR
HOME="$(dirname "$(readlink -f $0)")" 

# DOWNLOAD AND INSTALL JUNEST (DON'T TOUCH THIS)
git clone https://github.com/fsquillace/junest.git ~/.local/share/junest
./.local/share/junest/bin/junest setup

# ENABLE MULTILIB (optional)
#echo "
#[multilib]
#Include = /etc/pacman.d/mirrorlist" >> ./.junest/etc/pacman.conf

# ENABLE CHAOTIC-AUR
#./.local/share/junest/bin/junest -- sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
#./.local/share/junest/bin/junest -- sudo pacman-key --lsign-key 3056513887B78AEB
#./.local/share/junest/bin/junest -- sudo pacman --noconfirm -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
#echo "
#[chaotic-aur]
#Include = /etc/pacman.d/chaotic-mirrorlist" >> ./.junest/etc/pacman.conf

# CUSTOM MIRRORLIST, THIS SHOULD SPEEDUP THE INSTALLATION OF THE PACKAGES IN PACMAN (COMMENT EVERYTHING TO USE THE DEFAULT MIRROR)
COUNTRY=$(curl -i ipinfo.io | grep country | cut -c 15- | cut -c -2)
rm -R ./.junest/etc/pacman.d/mirrorlist
wget -q https://archlinux.org/mirrorlist/?country="$(echo $COUNTRY)" -O - | sed 's/#Server/Server/g' >> ./.junest/etc/pacman.d/mirrorlist

# UPDATE ARCH LINUX IN JUNEST
./.local/share/junest/bin/junest -- sudo pacman -Syy
./.local/share/junest/bin/junest -- sudo pacman --noconfirm -Syu

# INSTALL THE PROGRAM USING YAY
./.local/share/junest/bin/junest -- yay -Syy
./.local/share/junest/bin/junest -- yay --noconfirm -S gnu-free-fonts $(echo "$BASICSTUFF $COMPILERS $DEPENDENCES $APP")

# SET THE LOCALE (DON'T TOUCH THIS)
#sed "s/# /#>/g" ./.junest/etc/locale.gen | sed "s/#//g" | sed "s/>/#/g" >> ./locale.gen # UNCOMMENT TO ENABLE ALL THE LANGUAGES
#sed "s/#$(echo $LANG)/$(echo $LANG)/g" ./.junest/etc/locale.gen >> ./locale.gen # ENABLE ONLY YOUR LANGUAGE, COMMENT IF YOU NEED MORE THAN ONE
#rm ./.junest/etc/locale.gen
#mv ./locale.gen ./.junest/etc/locale.gen
rm ./.junest/etc/locale.conf
#echo "LANG=$LANG" >> ./.junest/etc/locale.conf
sed -i 's/LANG=${LANG:-C}/LANG=$LANG/g' ./.junest/etc/profile.d/locale.sh
#./.local/share/junest/bin/junest -- sudo pacman --noconfirm -S glibc gzip
#./.local/share/junest/bin/junest -- sudo locale-gen

# ...ADD THE ICON AND THE DESKTOP FILE AT THE ROOT OF THE APPDIR...
rm -R -f ./*.desktop
LAUNCHER=$(grep -iRl $BIN ./.junest/usr/share/applications/* | grep ".desktop" | head -1)
cp -r "$LAUNCHER" ./
ICON=$(cat $LAUNCHER | grep "Icon=" | cut -c 6-)
cp -r ./.junest/usr/share/icons/hicolor/22x22/apps/*$ICON* ./ 2>/dev/null
cp -r ./.junest/usr/share/icons/hicolor/24x24/apps/*$ICON* ./ 2>/dev/null
cp -r ./.junest/usr/share/icons/hicolor/32x32/apps/*$ICON* ./ 2>/dev/null
cp -r ./.junest/usr/share/icons/hicolor/48x48/apps/*$ICON* ./ 2>/dev/null
cp -r ./.junest/usr/share/icons/hicolor/64x64/apps/*$ICON* ./ 2>/dev/null
cp -r ./.junest/usr/share/icons/hicolor/128x128/apps/*$ICON* ./ 2>/dev/null
cp -r ./.junest/usr/share/icons/hicolor/192x192/apps/*$ICON* ./ 2>/dev/null
cp -r ./.junest/usr/share/icons/hicolor/256x256/apps/*$ICON* ./ 2>/dev/null
cp -r ./.junest/usr/share/icons/hicolor/512x512/apps/*$ICON* ./ 2>/dev/null
cp -r ./.junest/usr/share/icons/hicolor/scalable/apps/*$ICON* ./ 2>/dev/null
cp -r ./.junest/usr/share/pixmaps/*$ICON* ./ 2>/dev/null

# TEST IF THE DESKTOP FILE AND THE ICON ARE IN THE ROOT OF THE FUTURE APPIMAGE (./*AppDir/*)
if test -f ./*.desktop; then
	echo "The .desktop file is available in $APP.AppDir/"
else 
	cat <<-HEREDOC >> "./$APP.desktop"
	[Desktop Entry]
	Version=1.0
	Type=Application
	Name=NAME
	Comment=
	Exec=BINARY
	Icon=tux
	Categories=Utility;
	Terminal=true
	StartupNotify=true
	HEREDOC
	sed -i "s#BINARY#$BIN#g" ./$APP.desktop
	sed -i "s#Name=NAME#Name=$(echo $APP | tr a-z A-Z)#g" ./$APP.desktop
	wget https://raw.githubusercontent.com/Portable-Linux-Apps/Portable-Linux-Apps.github.io/main/favicon.ico -O ./tux.png
fi

# ...AND FINALLY CREATE THE APPRUN, IE THE MAIN SCRIPT TO RUN THE APPIMAGE!
# EDIT THE FOLLOWING LINES IF YOU THINK SOME ENVIRONMENT VARIABLES ARE MISSING
rm -R -f ./AppRun
cat >> ./AppRun << 'EOF'
#!/bin/sh
HERE="$(dirname "$(readlink -f $0)")"
export UNION_PRELOAD=$HERE
export JUNEST_HOME=$HERE/.junest
export PATH=$HERE/.local/share/junest/bin/:$PATH
mkdir -p $HOME/.cache
EXEC=$(grep -e '^Exec=.*' "${HERE}"/*.desktop | head -n 1 | cut -d "=" -f 2- | sed -e 's|%.||g')
$HERE/.local/share/junest/bin/junest proot -n -b "--bind=/home --bind=/home/$(echo $USER) --bind=/media --bind=/mnt --bind=/opt --bind=/usr/lib/locale --bind=/etc --bind=/usr/share" 2> /dev/null -- $EXEC "$@"
EOF
chmod a+x ./AppRun

# REMOVE "READ-ONLY FILE SYSTEM" ERRORS
sed -i 's#${JUNEST_HOME}/usr/bin/junest_wrapper#${HOME}/.cache/junest_wrapper.old#g' ./.local/share/junest/lib/core/wrappers.sh
sed -i 's/rm -f "${JUNEST_HOME}${bin_path}_wrappers/#rm -f "${JUNEST_HOME}${bin_path}_wrappers/g' ./.local/share/junest/lib/core/wrappers.sh
sed -i 's/ln/#ln/g' ./.local/share/junest/lib/core/wrappers.sh

# EXIT THE APPDIR
cd ..

# REMOVE SOME BLOATWARES
find ./$APP.AppDir/.junest/usr/share/locale/*/*/* -not -iname "*$BIN*" -a -not -name "." -delete

mkdir save
cp -r ./$APP.AppDir/.junest/usr/bin/ghb ./save/
cp -r ./$APP.AppDir/.junest/usr/bin/bash ./save/
cp -r ./$APP.AppDir/.junest/usr/bin/env ./save/
cp -r ./$APP.AppDir/.junest/usr/bin/proot* ./save/
cp -r ./$APP.AppDir/.junest/usr/bin/sh ./save/
rm -R -f ./$APP.AppDir/.junest/usr/bin/*
mv ./save/* ./$APP.AppDir/.junest/usr/bin/
rmdir save

rm -R -f ./$APP.AppDir/.junest/usr/include
rm -R -f ./$APP.AppDir/.junest/usr/lib/*.a
rm -R -f ./$APP.AppDir/.junest/usr/lib/audit
rm -R -f ./$APP.AppDir/.junest/usr/lib/avahi
rm -R -f ./$APP.AppDir/.junest/usr/lib/awk
rm -R -f ./$APP.AppDir/.junest/usr/lib/bash
rm -R -f ./$APP.AppDir/.junest/usr/lib/bellagio
rm -R -f ./$APP.AppDir/.junest/usr/lib/bfd-plugins
rm -R -f ./$APP.AppDir/.junest/usr/lib/binfmt.d
rm -R -f ./$APP.AppDir/.junest/usr/lib/cairo
rm -R -f ./$APP.AppDir/.junest/usr/lib/cmake
rm -R -f ./$APP.AppDir/.junest/usr/lib/coreutils
rm -R -f ./$APP.AppDir/.junest/usr/lib/cryptsetup
rm -R -f ./$APP.AppDir/.junest/usr/lib/d3d
rm -R -f ./$APP.AppDir/.junest/usr/lib/dbus-1.0
rm -R -f ./$APP.AppDir/.junest/usr/lib/depmod.d
rm -R -f ./$APP.AppDir/.junest/usr/lib/dri
rm -R -f ./$APP.AppDir/.junest/usr/lib/e2fsprogs
rm -R -f ./$APP.AppDir/.junest/usr/lib/engines-3
rm -R -f ./$APP.AppDir/.junest/usr/lib/environment.d
rm -R -f ./$APP.AppDir/.junest/usr/lib/gawk
rm -R -f ./$APP.AppDir/.junest/usr/lib/gconv
rm -R -f ./$APP.AppDir/.junest/usr/lib/getconf
rm -R -f ./$APP.AppDir/.junest/usr/lib/gettext
rm -R -f ./$APP.AppDir/.junest/usr/lib/gio
rm -R -f ./$APP.AppDir/.junest/usr/lib/girepository-1.0
rm -R -f ./$APP.AppDir/.junest/usr/lib/git-core
rm -R -f ./$APP.AppDir/.junest/usr/lib/glib-2.0
rm -R -f ./$APP.AppDir/.junest/usr/lib/gnome-settings-daemon-3.0
rm -R -f ./$APP.AppDir/.junest/usr/lib/gnupg
rm -R -f ./$APP.AppDir/.junest/usr/lib/graphene-1.0
rm -R -f ./$APP.AppDir/.junest/usr/lib/gtk-2.0
rm -R -f ./$APP.AppDir/.junest/usr/lib/gtk-3.0
rm -R -f ./$APP.AppDir/.junest/usr/lib/icu
rm -R -f ./$APP.AppDir/.junest/usr/lib/initcpio
rm -R -f ./$APP.AppDir/.junest/usr/lib/kernel
rm -R -f ./$APP.AppDir/.junest/usr/lib/krb5
rm -R -f ./$APP.AppDir/.junest/usr/lib/libasan*
rm -R -f ./$APP.AppDir/.junest/usr/lib/libfakeroot
rm -R -f ./$APP.AppDir/.junest/usr/lib/libgo.s*
rm -R -f ./$APP.AppDir/.junest/usr/lib/libgphobos*
rm -R -f ./$APP.AppDir/.junest/usr/lib/libLLVM*
rm -R -f ./$APP.AppDir/.junest/usr/lib/libmfx*
rm -R -f ./$APP.AppDir/.junest/usr/lib/libnl
rm -R -f ./$APP.AppDir/.junest/usr/lib/libOSMesa*
rm -R -f ./$APP.AppDir/.junest/usr/lib/libopencv_*
rm -R -f ./$APP.AppDir/.junest/usr/lib/libPy*
rm -R -f ./$APP.AppDir/.junest/usr/lib/libproxy
rm -R -f ./$APP.AppDir/.junest/usr/lib/locale
rm -R -f ./$APP.AppDir/.junest/usr/lib/modprobe.d
rm -R -f ./$APP.AppDir/.junest/usr/lib/modules-load.d
rm -R -f ./$APP.AppDir/.junest/usr/lib/*.o
rm -R -f ./$APP.AppDir/.junest/usr/lib/omxloaders
rm -R -f ./$APP.AppDir/.junest/usr/lib/ossl-modules
rm -R -f ./$APP.AppDir/.junest/usr/lib/p11-kit
rm -R -f ./$APP.AppDir/.junest/usr/lib/pam.d
rm -R -f ./$APP.AppDir/.junest/usr/lib/perl5
rm -R -f ./$APP.AppDir/.junest/usr/lib/pkcs11
rm -R -f ./$APP.AppDir/.junest/usr/lib/pkgconfig
rm -R -f ./$APP.AppDir/.junest/usr/lib/python3.11
rm -R -f ./$APP.AppDir/.junest/usr/lib/sasl2
rm -R -f ./$APP.AppDir/.junest/usr/lib/security
rm -R -f ./$APP.AppDir/.junest/usr/lib/sysctl.d
rm -R -f ./$APP.AppDir/.junest/usr/lib/systemd
rm -R -f ./$APP.AppDir/.junest/usr/lib/sysusers.d
rm -R -f ./$APP.AppDir/.junest/usr/lib/tmpfiles.d
rm -R -f ./$APP.AppDir/.junest/usr/lib/tracker3
rm -R -f ./$APP.AppDir/.junest/usr/lib/tracker-3.0
rm -R -f ./$APP.AppDir/.junest/usr/lib/udev
rm -R -f ./$APP.AppDir/.junest/usr/lib/utempter
rm -R -f ./$APP.AppDir/.junest/usr/lib/xkbcommon
rm -R -f ./$APP.AppDir/.junest/usr/lib/xtables

mkdir save
cp -r ./$APP.AppDir/.junest/usr/share/gdb ./save/
cp -r ./$APP.AppDir/.junest/usr/share/*gst* ./save/
cp -r ./$APP.AppDir/.junest/usr/share/locale ./save/
rm -R -f ./$APP.AppDir/.junest/usr/share/*
mv ./save/* ./$APP.AppDir/.junest/usr/share/
rmdir save

rm -R -f ./$APP.AppDir/.junest/var/*

# ADDITIONAL REMOVALS

# REMOVE THE INBUILT HOME
rm -R -f ./$APP.AppDir/.junest/home

# ENABLE MOUNTPOINTS
mkdir -p ./$APP.AppDir/.junest/home
mkdir -p ./$APP.AppDir/.junest/media
mkdir -p ./$APP.AppDir/.junest/usr/share/fonts
mkdir -p ./$APP.AppDir/.junest/usr/share/themes

# CREATE THE APPIMAGE
ARCH=x86_64 ./appimagetool -n ./$APP.AppDir
mv ./*AppImage ./"$(cat ./$APP.AppDir/*.desktop | grep 'Name=' | head -1 | cut -c 6- | sed 's/ /-/g')"_"$VERSION".AppImage
