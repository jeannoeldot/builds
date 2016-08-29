#!/bin/sh

# => Passe en root
if [ ! $( id -u ) -eq 0 ]; then
echo "Entrer mot de passe root: "
exec su -c "${0} ${CMDLN_ARGS}"
exit ${?}
fi


# => Mise a Jour
cd
mkarchroot -u /home/jnd/05-builds/0-chroot/root

# => makechrootpkg
cd
cd /home/jnd/05-builds/pokerth
makechrootpkg -c -r /home/jnd/05-builds/0-chroot

# => Modif proprietaire
chown jnd:jnd PokerTH-0.6.4-src.tar.bz2
chown jnd:jnd pokerth.install


exit