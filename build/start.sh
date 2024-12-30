function check_user(){
    cur_user=$(id -u)
    if [ "$cur_user" != "0" ]
    then
        echo "Adding randomly generated uid to passwd file..."
        sed -i '/postgres/d' /etc/passwd
        if ! whoami &> /dev/null; then
          if [ -w /etc/passwd ]; then
            echo "postgres:x:$(id -u):0:postgres user:/var/lib/pgsql/data/postgresql_${POD_IDENTITY}:/sbin/nologin" >> /etc/passwd
          fi
        fi
    fi
#    fix_backrest_permissions "$cur_user"
}

function fix_backrest_permissions(){
    chmod 750 /var/lib/pgbackrest
    chmod 750 /var/log/pgbackrest
    chmod 750 /var/spool/pgbackrest
    chown $1:$1 /var/lib/pgbackrest
    chown $1:$1 /var/log/pgbackrest
    chown $1:$1 /var/spool/pgbackrest
}

check_user
/usr/local/bin/pgbackrest-sidecar