#!/bin/bash -e

: ${MYUNAME:=builder}
: ${MYUID:=1000}

if ! id $MYUNAME; then
	echo "setup $MYUNAME ..."
	mkdir -p /home/$MYUNAME
	usermod -l $MYUNAME -d /home/$MYUNAME builder 
	rm -f /mySSH
	ln -s /home/$MYUNAME/.ssh /mySSH
	echo "$MYUNAME ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers
	if [ ! -e /home/$MYUNAME/.bashrc ]; then
		rsync -av /etc/skel/ /home/$MYUNAME/
	fi
	chown $MYUNAME /home/$MYUNAME -R
fi

mkdir -p /localdisk/config
chown $MYUID:cgts /localdisk/config
echo "$MYUID:$MYUNAME" > /localdisk/config/usr.lst
chown $MYUID:cgts /localdisk/config/usr.lst

mkdir -p /localdisk/designer
chown $MYUID:cgts /localdisk/designer
mkdir -p /localdisk/designer/$MYUNAME
chown $MYUID:cgts /localdisk/designer/$MYUNAME

mkdir -p /localdisk/loadbuild
chown $MYUID:cgts /localdisk/loadbuild
mkdir -p /localdisk/loadbuild/$MYUNAME
chown $MYUID:cgts /localdisk/loadbuild/$MYUNAME

mkdir -p /localdisk/loadbuild/mock
chmod 775 /localdisk/loadbuild/mock
chown root:mock /localdisk/loadbuild/mock
mkdir -p /localdisk/loadbuild/mock-cache
chmod 775 /localdisk/loadbuild/mock-cache
chown root:mock /localdisk/loadbuild/mock-cache

/usr/sbin/sshd -D
