#!/bin/bash
#
# LDAP Installer & Pré-Config
#
#Bash Colors
pret='\E[0;30m'   # Black
verm='\E[0;31m'   # Red
verd='\E[0;32m'   # Green
amar='\E[0;33m'   # Yellow
azul='\E[0;34m'   # Blue
mage='\E[0;35m'   # Magenta
cian='\E[0;36m'   # Ciano
bran='\E[0;37m'   # White
bold='\033[37;4;1m' #BOLD
und='\033[37;4m'
rese=$(tput sgr0) # No color.

chk() {
if [ $? -gt 0 ]; then
 echo -e "${verm}Erro, verifique.${rese}"
  else
  echo -e "${verd}OK!${rese}"
fi
}

chkinit() {
if [ $? -gt 0 ]; then
  echo -e "${verm}Erro na inicializacao${rese}"
   else
   echo -e "${verd}OK!${rese}"
fi
}

cab() {
clear
printf "
###############################################
        Bem vindo ao Instalador LDAP
     Com pré-configurações para o PI-2016
###############################################"
}
#
#Instalação dos pacotes necessários;
echo -e "Instalando os pacotes LDAP & PHP"
yum -y install openldap-servers openldap-clients >2&1 /dev/null
chk
#
#Movendo o arquivo de configuração para o "banco" (dbconfig).
echo -e "Configurando o banco"
cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG >2&1 /dev/null
chk
#
# Setando permissões.
echo -e "Configurando as permissoes"
chown ldap. /var/lib/ldap/DB_CONFIG >2&1 /dev/null
chk
#
#Iniciando e habilitando o serviço
#
echo -e "Iniciando e habilitando startup LDAP"
systemctl start slapd >2&1 /dev/null
echo -e "Ldap Iniciado ${verd}[OK]${rese}"
systemctl enable slapd >2&1 /dev/null
echo -e "Startup Habilitado ${verd}OK${rese}"
chkinit
