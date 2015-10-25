#!/bin/bash
sudo debootstrap --arch=i386 trusty chr
sudo mount --bind /dev chr/dev
sudo cp /etc/apt/sources.list chr/etc/apt/sources.list
sudo chroot chr
	mount none -t proc /proc
	mount none -t sysfs /sys
	mount none -t devpts /dev/pts
	export HOME=/root
	export LC_ALL=C
	sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 3E5C1192
	sudo apt-key adv --keyserver keys.gnupg.net --recv-keys 886DDD89
	apt-get update
	apt-get install --yes dbus
	dbus-uuidgen > /var/lib/dbus/machine-id
	dpkg-divert --local --rename --add /sbin/initctl
	apt-get --yes upgrade
	apt-get install --yes ubuntu-standard casper lupin-casper
	apt-get install --yes discover laptop-detect os-prober
	apt-get install --yes linux-generic
	echo "deb http://deb.torproject.org/torproject.org trusty main" > etc/apt/sources.list.d/torproject.list
	echo "deb-src http://deb.torproject.org/torproject.org trusty main" > etc/apt/sources.list.d/torproject.list
	apt-get install ssh tor deb.torproject.org-keyring

