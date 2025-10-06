# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop unpacker xdg

DESCRIPTION="Powerful modern download accelerator and organizer"
HOMEPAGE="https://www.freedownloadmanager.org/"
SRC_URI="https://files2.freedownloadmanager.org/6/latest/freedownloadmanager.deb"

LICENSE="freedownloadmanager"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="bindist mirror strip"

RDEPEND="
	dev-libs/openssl:0=
	media-video/ffmpeg:0=
	net-libs/libtorrent-rasterbar:0=
	media-libs/gst-plugins-base:1.0
	x11-misc/xdg-utils
"

S="${WORKDIR}"

QA_PREBUILT="opt/${PN}/*"

src_unpack() {
	unpack_deb ${A}
}

src_prepare() {
	default

	# Fix desktop file paths
	sed -i \
		-e 's|/opt/freedownloadmanager/icon\.png|freedownloadmanager|g' \
		-e 's|/opt/freedownloadmanager/fdm|/usr/bin/fdm|g' \
		usr/share/applications/freedownloadmanager.desktop || die

	# Add StartupWMClass
	sed -i '/^Exec=/a StartupWMClass=fdm' \
		usr/share/applications/freedownloadmanager.desktop || die
}

src_install() {
	# Install application files
	insinto /opt/${PN}
	doins -r opt/freedownloadmanager/*

	# Make binaries executable
	fperms +x /opt/${PN}/fdm
	fperms +x /opt/${PN}/fdmextension

	# Create symlink for main binary
	dosym ../../opt/${PN}/fdm /usr/bin/fdm

	# Install icon
	doicon -s 256 opt/freedownloadmanager/icon.png
	newicon opt/freedownloadmanager/icon.png freedownloadmanager.png

	# Install desktop file
	domenu usr/share/applications/freedownloadmanager.desktop

	# Install MIME type
	insinto /usr/share/mime/packages
	doins usr/share/mime/packages/freedownloadmanager.xml
}

pkg_postinst() {
	xdg_pkg_postinst

	elog "Free Download Manager has been installed to /opt/${PN}"
	elog "You can launch it using the 'fdm' command or from your application menu."
}
