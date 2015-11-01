#!/bin/bash
CHR=tmp/chr
mkdir -vp "$CHR"
sudo debootstrap --arch=i386 trusty "$CHR"
sudo mount --bind /dev "$CHR/dev"
sudo cp /etc/apt/sources.list "$CHR/etc/apt/sources.list"
sudo chroot "$CHR"
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
	apt-get install --yes ssh tor deb.torproject.org-keyring
	mkdir -vp /srv/onion/ssh/tor
	vi etc/tor/torrc
		echo "HiddenServiceDir /srv/onion/ssh/tor"
		echo "HiddenServicePort 22 127.0.0.1:22"
	chown -c debian-tor:ssh /srv/onion/ssh/tor
	chmod -c go-rwx /srv/onion/ssh/tor
	/etc/init.d/tor restart
	apt-get install --yes vim git bash-completion bashburn
	apt-get install --yes syslinux squashfs-tools genisoimage
	apt-get install --yes debootstrap
	mkdir -vp /root/.ssh
	chmod -c go-rwx /root/.ssh
	echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDB5Y4c4hy0ubK3fi0oXy9aIJQQz8ewGxKl0Cyp6LWUInKq+Y4WEJ/dNf5BIPbfO5qwBUAl1MQDMNmZY9rhm4fEI6FtIHNfnIvxloBpB6EuzSuDhhGf3BTxouhvDJRU9EIbnrg5g7RiJLe9OYV0YUgZFNoEow6/s0EIAtJ4+EEqkLn8e9gvjFdXfpzr1GItcfewwo8clCmPyg3mBedwUIFQmLDN2XO32j2jb0OVL2c/ovtZE37oHLqPRKJ1dDu9HcUunYrJiY6uekpuNov4bDcQ1Lr6LcX4ywWAwLXLusRAblOoa+WQtq5MBKfWJgDifh3AY3PCu+WlCiLS1KUTVOrDoslyeADW/OeB9i5lNGxMufJHMLF3GueZ/rWEzotTvF9VyBvUHjXhwc/gKGr+82q7dVz7AnFP7OSELaNHvh+PmBBzC8DH3YPWl1vySIUA6/XxuufKctcQ86bpYeqBkRqU6fcEo90JW53QVN036y52yOoZYulr07wZvNXBwyO8+Qk= sebo@UbuntuTrusty-VBX" >> /root/.ssh/authorized_keys
	echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCf8gmXCgueBiL9d8hXRh+Fjyl6UEJhhPx2j1zImZyNdHjs0a56kLKTN4CKnnOW25UTY0aipohKNyGWaXufUzktMGC0kTWnFUQgxXbM6ifgo7xkv0MSCKjcIlw6rJWo022ua90/l6ENEgQ6WRnp4//Z/IVmSs7btpjInYtDRU6W2JY2EU8mIpsdVf62mRqZBN0jRO1KmjRzE8I9NqMQWyjHb4HF45wPlc0msavECy743feDm7agtrdYonw9pygnXg1jo79+gfohFjggwggfJhCONgJtD5t/NxhOnl31mMu5LGeykxTaul599R4V0OgkhcnTInzOky7ctLbkncTYxgBtYqdBuaOib0eqbTeR6jLkDIpZiJBR6fGjBIxTtw0VJOLperdNQIb0HMizhLfG+Hx5NrF6N1XFFawNvl4i8gik0vL1ZAysXtJ79P2JJBJlQV2UGzd4ymLXB8U81plRXLTbJYcDTLBGifTcg0uNvM435FWFOfEy306+rjZPDm1ssNU= sebo@C6833" >> /root/.ssh/authorized_keys
	apt-get install --yes screen
	git config --system --add user.name "Sebastian Sawicki (PGP:0x5CB361E552FB0D10)"
	git config --system --add user.email "Sebo.PL+UbuntuLiveCD@gMail.com"
	git config --system --add core.editor vim
	git config --system --add push.default simple
	rm -vf /var/lib/dbus/machine-id
	#rm /sbin/initctl
	dpkg-divert --rename --remove /sbin/initctl
	apt-get clean
	rm -rvf /tmp/*
	rm -vf /etc/resolv.conf
	umount -lf /proc
	umount -lf /sys
	umount -lf /dev/pts
	exit
sudo umount -lf "$CHR/dev"
mkdir -p img/{casper,isolinux,install}
sudo cp -v "$CHR/boot/vmlinuz-3.13.0-66-generic" img/casper/vmlinuz
cp -v "$CHR/boot/initrd.img-3.13.0-66-generic" img/casper/initrd.lz
cp -v /usr/lib/syslinux/isolinux.bin img/isolinux/
cp -v /boot/memtest86+.bin img/install/memtest
printf "\x18" > img/isolinux/isolinux.txt
echo "splash.rle" >> img/isolinux/isolinux.txt
[ -r src/isolinux.txt ] && cat src/isolinux.txt >> img/isolinux/isolinux.txt
[ -r src/splash.bmp ] && {
 bmptoppm splash.bmp | ppmtolss16 '#ffffff=7' > splash.rle
}
cat src/isolinux.cfg > img/isolinux/isolinux.cfg
sudo chroot "$CHR" dpkg-query -W --showformat='${Package} ${Version}\n' | sudo tee img/casper/filesystem.manifest
sudo cp -v img/casper/filesystem.manifest img/casper/filesystem.manifest-desktop
for i in ubiquity ubiquity-frontend-gtk ubiquity-frontend-kde casper lupin-casper live-initramfs user-setup discover1 xresprobe os-prober libdebian-installer4
 do
  sudo sed -i "/${i}/d" img/casper/filesystem.manifest-desktop
done
sudo mksquashfs "$CHR" img/casper/filesystem.squashfs
printf $(sudo du -sx --block-size=1 chr | cut -f1) > img/casper/filesystem.size
cat src/README.diskdefines > img/README.diskdefines
echo -n "" > img/ubuntu
mkdir -p img/.disk
echo -n "" > img/.disk/base_installable
echo "full_cd/single" > img/.disk/cd_type
echo "Ubuntu Remix 14.04.3" > img/.disk/info
echo "http//ampvslp3mpp6ngul.onion/" > release_notes_url
sudo -s
	(cd img && find . -type f -print0 | xargs -0 md5sum | grep -v "\./md5sum.txt" > md5sum.txt)
	exit
cd img
sudo mkisofs -r -V "Ubuntu 14.04.3LTSi386 SrvOnline" -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o ../ubuntu-online-live-rescure.iso .
cd ..

