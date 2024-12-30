# Copyright 2024-2025 NetCracker Technology Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
/usr/local/bin/pgskipper-pgbackrest-sidecar