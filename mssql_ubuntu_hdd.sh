#!/bin/bash -e

# Use the following variables to control your install:

# Password for the SA user (required)
MSSQL_SA_PASSWORD='SfwefEWFL#o0jKEJ'

# Product ID of the version of SQL server you're installing
# Must be evaluation, developer, express, web, standard, enterprise, or your 25 digit product key
# Defaults to developer
MSSQL_PID='express'

# Enable SQL Server Agent (recommended)
SQL_ENABLE_AGENT='y'

# Install SQL Server Full Text Search (optional)
SQL_INSTALL_FULLTEXT='y'

# Create an additional user with sysadmin privileges (optional)
# SQL_INSTALL_USER='<Username>'
# SQL_INSTALL_USER_PASSWORD='<YourStrong!Passw0rd>'

if [ -z $MSSQL_SA_PASSWORD ]
then
  echo Environment variable MSSQL_SA_PASSWORD must be set for unattended install
  exit 1
fi

echo Adding Microsoft repositories...
sudo curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
repoargs="$(curl https://packages.microsoft.com/config/ubuntu/20.04/mssql-server-2019.list)"
sudo add-apt-repository "${repoargs}"
repoargs="$(curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list)"
sudo add-apt-repository "${repoargs}"

echo Running apt-get update -y...
sudo apt-get update -y

echo Installing SQL Server...
sudo apt-get install -y mssql-server

echo Running mssql-conf setup...
sudo MSSQL_SA_PASSWORD=$MSSQL_SA_PASSWORD \
     MSSQL_PID=$MSSQL_PID \
     /opt/mssql/bin/mssql-conf -n setup accept-eula

echo Installing mssql-tools and unixODBC developer...
sudo ACCEPT_EULA=Y apt-get install -y mssql-tools unixodbc-dev

# Add SQL Server tools to the path by default:
echo Adding SQL Server tools to your path...
echo PATH="$PATH:/opt/mssql-tools/bin" >> ~/.bash_profile
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
source ~/.bashrc

# Optional Enable SQL Server Agent:
if [ ! -z $SQL_ENABLE_AGENT ]
then
  echo Enabling SQL Server Agent...
  sudo /opt/mssql/bin/mssql-conf set sqlagent.enabled true
fi

# Optional SQL Server Full Text Search installation:
if [ ! -z $SQL_INSTALL_FULLTEXT ]
then
    echo Installing SQL Server Full-Text Search...
    sudo apt-get install -y mssql-server-fts
fi

# Configure firewall to allow TCP port 1433:
echo Configuring UFW to allow traffic on port 1433...
sudo ufw allow 1433/tcp
sudo ufw allow 22/tcp
sudo ufw reload

# Optional example of post-installation configuration.
# Trace flags 1204 and 1222 are for deadlock tracing.
# echo Setting trace flags...
# sudo /opt/mssql/bin/mssql-conf traceflag 1204 1222 on

# Restart SQL Server after installing:
echo Stoping SQL Server...
sudo systemctl stop mssql-server


# Format disku
echo formatuji disky sdb,sdc a sdd....

pvcreate /dev/sdb /dev/sdc /dev/sdd
vgcreate sql_data /dev/sdb
vgcreate sql_log /dev/sdc
vgcreate sql_bkp /dev/sdd

lvcreate -l 100%FREE sql_bkp
lvcreate -l 100%FREE sql_data
lvcreate -l 100%FREE sql_log

mkfs.xfs -f /dev/sql_data/lvol0
mkfs.xfs -f /dev/sql_log/lvol0
mkfs.xfs -f /dev/sql_bkp/lvol0

# Vytvoreni a prava na slozky data a log
echo vytvarim slozky data a log....
mkdir /var/opt/mssql/data_disk
mkdir /var/opt/mssql/log_disk
mkdir /var/opt/mssql/bkp_disk


#Vlozi disky do fstab souboru
echo vkladam zaznam od discich do fstab.....

cat <<EOF>> /etc/fstab

/dev/mapper/sql_log-lvol0 /var/opt/mssql/data_disk xfs rw,attr2,noatime 0 0
/dev/mapper/sql_data-lvol0 /var/opt/mssql/log_disk xfs rw,attr2,noatime 0 0
/dev/mapper/sql_bkp-lvol0 /var/opt/mssql/bkp_disk xfs rw,attr2,noatime 0 0
EOF

#Mount disku v systemu
echo pripojuji nove disky do systemu
mount -a


sudo /opt/mssql/bin/mssql-conf set filelocation.defaultdatadir /var/opt/mssql/data_disk
sudo /opt/mssql/bin/mssql-conf set filelocation.defaultlogdir /var/opt/mssql/log_disk
sudo /opt/mssql/bin/mssql-conf set filelocation.defaultbackupdir /var/opt/mssql/bkp_disk


#Opravneni pro zapis na disky pro uzivatele mssql
echo Prideluji opravneni pro uzivatele mssql pro zapis na disky...

chown -R mssql:mssql /var/opt/mssql/data_disk
chown -R mssql:mssql /var/opt/mssql/log_disk
chown -R mssql:mssql /var/opt/mssql/bkp_disk

echo Zmena collation DB
sudo systemctl stop mssql-server
echo Pro Pohodu je potreba !!!czech_ci_as!!!
printf 'czech_ci_as' | sudo /opt/mssql/bin/mssql-conf set-collation

#Start MSSQL
echo Startuji MSSQL....
sudo systemctl start mssql-server


echo Done!
