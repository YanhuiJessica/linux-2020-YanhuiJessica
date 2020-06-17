#!/usr/bin/env bash

if ! [[ $(command -v named) ]]; then
    echo "bind9 is uninstalled. Installing..."
    apt install bind9 -y || { echo "Failed to install bind9. Exiting..."; exit 1; }
fi

named_option=/etc/bind/named.conf.options
named_local=/etc/bind/named.conf.local

bash "$CODE_PATH/backup.sh" "$named_option" 'named.conf.options' || exit 1
cat > "$named_option" << EOF
acl "allowed" {
    192.168.233.0/24;
};
options {
        directory "/var/cache/bind";

        forwarders {
            114.114.114.114;
            8.8.8.8;
        };

        dnssec-validation auto;

        # defines whether the server should answer authoritatively
        auth-nxdomain no;
};
EOF

bash "$CODE_PATH/backup.sh" "$named_local" 'named.conf.local' || exit 1
cat > "$named_local" << EOF
zone "cuc.edu.cn" IN {
    type master;
    file "cuc.edu.cn.db";
};
EOF

cuc_conf=/var/cache/bind/cuc.edu.cn.db
bash "$CODE_PATH/backup.sh" "$cuc_conf" 'cuc.edu.cn' || exit 1
cat > "$cuc_conf" << EOF
$TTL    86400
@       IN      SOA     ns.cuc.edu.cn. root.cuc.edu.cn. (
                202006       ; serial
                7200         ; refresh after 2 hours
                3600         ; retry after 1 hour
                604800       ; expire after 1 week
                86400 )      ; minimum TTL of 1 day
;
; Primary nameserver
    IN  NS  ns.cuc.edu.cn.
; Define A records (forward lookups)
ns        IN  A       192.168.233.1
wp.sec    IN  A       192.168.56.13
dvwa.sec  IN  CNAME   wp.sec
EOF

service bind9 restart