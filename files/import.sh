#!/bin/bash
# a comment that I amended
cd /usr/share/doc/zabbix-server-mysql-$(rpm -q zabbix-server-mysql | awk -F- '{print $4}')/create

if [ ! $? -eq 0 ]; then
  echo "Could not cd to $(/usr/share/doc/zabbix-server-mysql-$(rpm -q zabbix-server-mysql | awk -F- '{print $4}')/create)"
  exit 1
fi
if [ -f .done ]; then
  exit 0
fi
FOO=0
sql[0]=schema.sql
sql[1]=images.sql
sql[2]=data.sql
echo $sql[0]
for i in {0..2}; do
  echo "Processing ${sql[$i]}"
  if [ ! -f ${sql[$i]}.done ]
    then
      mysql -uroot zabbix < ${sql[$i]}
      if [ $? -eq 0 ]; then
        touch ${sql[$i]}.done
      else
        FOO=1
      fi
  fi
done

if [ ! $FOO -eq 1 ]
  then
    touch .done
    exit 0
  else
    exit 1
fi
