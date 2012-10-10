foscorder
=========

Simple DVR for recording streams Foscam to NAS

perl -I lib bin/recorder.pl --name=FrontDoorCam --url=http://192.168.0.20 --username=readonlyuser --password=readonlypass

    Alias /foscorder/ "/home/foscorder/www/"
    <Directory "/home/foscorder/www/">
        Options Indexes MultiViews FollowSymLinks ExecCGI
        AllowOverride All
        AddHandler cgi-script .cgi
    </Directory>

/foscorder/foscorder.cgi?action=play&file=FrontDoorCam/2012/10/10/BackYard_2012-10-10-104440.mjpeg
