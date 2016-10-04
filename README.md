# Gentoo portage overlay for libreoffice-online ebuilds 
Gentoo portage overlay for libreoffice-online ebuilds
[![Build Status](https://travis-ci.org/timeraider4u/libreoffice-online.svg?branch=master)](https://travis-ci.org/timeraider4u/libreoffice-online)

## Usage
You may used some commands similiar to the following:
````bash
cd /usr/local/
git clone https://github.com/timeraider4u/libreoffice-online.git
echo "PORTDIR_OVERLAY=\"\${PORTDIR_OVERLAY} /usr/local/libreoffice-online/\"" \
	>> /etc/portage/make.conf
cp keywords/libreoffice-online /etc/portage/package.keywords/
emerge -v www-servers/libreoffice-online
````

## About LibreOffice online
LibreOffice online is mainly developed by Collabora.
Docker files and more information can be found at
https://www.collaboraoffice.com/code/

LibreOffice online source code repository can be found here:
https://github.com/LibreOffice/online
or
https://gerrit.libreoffice.org/gitweb?p=online.git;a=summary

## Ebuild details
npm.eclass taken from 
https://github.com/neurogeek/gentoo-overlay/blob/master/eclass/npm.eclass

dev-nodejs/ package ebuilds generated with g-npm-with-java which can be found at
https://github.com/timeraider4u/g-npm-with-java.git

## More interesting information
Forum posts which are connected to installing LibreOffice online:
https://forum.owncloud.org/viewtopic.php?t=32040

Information about OwnCloud/NextCloud integration with LibreOffice online
can be found here:
https://owncloud.org/blog/libreoffice-online-has-arrived-in-owncloud/
https://github.com/owncloud/richdocuments
https://apps.owncloud.com/content/show.php/Collabora+Online+connector?content=174727
and 
https://nextcloud.com/blog/nextcloud-and-collabora-bring-online-office-to-everybody/
https://nextcloud.com/collaboraonline/

The following guide (in german) describes how to install libreoffice online 
to work with NextCloud and a Let's encrypt certificate on Arch-Linux:
https://help.nextcloud.com/t/libreoffice-online-mit-nextcloud-unter-arch-linux-mit-let-s-encrypt-zertifikat-schnellanleitung-ohne-docker-aktualisiert-02-09-2016/1548
