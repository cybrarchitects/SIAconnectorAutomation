 systemctl stop cyberark-dpa-connector
 systemctl disable cyberark-dpa-connector
 rm /etc/systemd/system/cyberark-dpa-connector.service
 rm -r /opt/cyberark/connector
 systemctl daemon-reload
 userdel cyberark-dpa-connector