#!/bin/sh

if [ ! -f "$1" ]
then
	echo "File not found: '$1'"
	exit 1
fi

DEB=$( readlink -f "$1" )
WORKING_DIR=$( dirname "$DEB" )
SCRIPT_DIR=$( dirname "$( readlink -f "$0" )" )

APP_PNAME=$( dpkg-deb -I "$DEB" | sed -n "s/^ Package: \(.*\)/\1/p" )
UNPACKED_DEB="$APP_PNAME-unpacked"
dpkg-deb -x "$DEB" "$WORKING_DIR/$UNPACKED_DEB"
dpkg-deb -e "$DEB" "$WORKING_DIR/$UNPACKED_DEB/DEBIAN"

APP_VERSION=$( sed -n "s/^Version: \(.*\)/\1/p" "$WORKING_DIR/$UNPACKED_DEB/DEBIAN/control" )
PATCH_PNAME="$APP_PNAME-rooted"
APP_DNAME=$( ls "$WORKING_DIR/$UNPACKED_DEB/usr/share/applications/" | sed -n "s/\(.*\)\.desktop/\1/p" )
PATCH_DNAME="$APP_DNAME-rooted"
APP_SNAME=$( sed -n "s/^Name=\(.*\)/\1/p" "$WORKING_DIR/$UNPACKED_DEB/usr/share/applications/$APP_DNAME.desktop" )
PATCH_SNAME="Rooted $APP_SNAME"
APP_ICON=$( sed -n "s/^Icon=\(.*\)/\1/p" "$WORKING_DIR/$UNPACKED_DEB/usr/share/applications/$APP_DNAME.desktop" )
YEAR=$( date +"%Y" )

mkdir -p "$WORKING_DIR/$PATCH_PNAME/"
cp "$SCRIPT_DIR/template/makefile" "$WORKING_DIR/$PATCH_PNAME/"
cp "$SCRIPT_DIR/template/template_patch_dname.desktop" "$WORKING_DIR/$PATCH_PNAME/$PATCH_DNAME.desktop"
cp -r "$SCRIPT_DIR/template/debian/" "$WORKING_DIR/$PATCH_PNAME/"

sed -i "s/^Name=.*/Name=$PATCH_SNAME/" "$WORKING_DIR/$PATCH_PNAME/$PATCH_DNAME.desktop"
sed -i "s,^Icon=.*,Icon=$APP_ICON," "$WORKING_DIR/$PATCH_PNAME/$PATCH_DNAME.desktop"
sed -i "s/template_patch_dname/$PATCH_DNAME/" "$WORKING_DIR/$PATCH_PNAME/makefile"
sed -i "s/template_patch_pname/$PATCH_PNAME/" "$WORKING_DIR/$PATCH_PNAME/debian/changelog"
sed -i "s/template_patch_pname/$PATCH_PNAME/" "$WORKING_DIR/$PATCH_PNAME/debian/control"
sed -i "s/template_app_pname (version)/$APP_PNAME (>= $APP_VERSION)/" "$WORKING_DIR/$PATCH_PNAME/debian/control"
sed -i "s/template_app_sname/$APP_SNAME/" "$WORKING_DIR/$PATCH_PNAME/debian/control"
sed -i "s/template_app_sname/$APP_SNAME/" "$WORKING_DIR/$PATCH_PNAME/debian/copyright"
sed -i "s/template_app_pname/$APP_PNAME/" "$WORKING_DIR/$PATCH_PNAME/debian/postinst"
sed -i "s/template_patch_pname/$PATCH_PNAME/" "$WORKING_DIR/$PATCH_PNAME/debian/postinst"
sed -i "s/template_app_dname/$APP_DNAME/" "$WORKING_DIR/$PATCH_PNAME/debian/postinst"
sed -i "s/template_patch_dname/$PATCH_DNAME/g" "$WORKING_DIR/$PATCH_PNAME/debian/postinst"


