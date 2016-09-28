#!/bin/bash
#
# Script Instalador do Ambiente LAMP.
# 
# Criado por Edegard Santos.
#
#
# BASHCSS
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
#
# CABECALHO
cab() {
clear
echo -e "---------------------------------------------------------"
echo -e "                                                         "
echo -e "          Sistema instalador do ambiente para o PI       "
echo -e "                      \033[1mAmbiente LAMP PI \033[0m\n  "
echo -e "---------------------------------------------------------"
}
#
# CAB FASE 1, BANCO DE DADOS.
#
fase1() {
echo -e "---------------------------------------------------------"
echo -e "                   INICIANDO FASE 1                      "
echo -e "                  Instalando ${bold}MariaDB${rese}       "
echo -e "---------------------------------------------------------"
}
#
# CAB FASE 2, APACHE2..
#
fase2() {
echo -e "---------------------------------------------------------"
echo -e "                   INICIANDO FASE 2                      "
echo -e "                  Instalando ${bold}APACHE2${rese}       "
echo -e "---------------------------------------------------------"
}
#
# CAB FASE 3, INSTALAR PHP.
#
fase3() {
echo -e "---------------------------------------------------------"
echo -e "                   INICIANDO FASE 3                      "
echo -e "                 Instalando ${bold}PHP5.4.16${rese}      "
echo -e "---------------------------------------------------------"
}
#
# CAB FASE 4, PHP-TEST.
#
fase4() {
echo -e "---------------------------------------------------------"
echo -e "                   INICIANDO FASE 4                      "
echo -e "                 Testando o ${bold}PHP5.4.16${rese}      "
echo -e "---------------------------------------------------------"
}
#
# CAB FASE 5, PHP-MYSQL.
#
fase5() {
echo -e "---------------------------------------------------------"
echo -e "                   INICIANDO FASE 5                      "
echo -e "             Instalando Modulos ${bold}PHP-MySQL${rese}  "
echo -e "---------------------------------------------------------"
}
#
# CAB FASE 6, PHPMYADMIN.
#
fase6() {
echo -e "---------------------------------------------------------"
echo -e "                   INICIANDO FASE 6                      "
echo -e "                Instalando ${bold}PhpMyAdmin${rese}      "
echo -e "---------------------------------------------------------"
}

chkinst() {
if [ $? -gt 0 ]; then
 echo -e "${verm}Erro na instalacao${rese}"
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
#
cab
#
#
#Importando a chave GNU Privacy Guard (GPG)
#
echo -e "Importando a chave ${bold}GPG${rese}"
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY*
if [ $? -gt 0 ]; then
  echo -e "${verm}Erro ao importar chave${rese}"
  else 
  echo -e "${verd}OK!${rese}"
fi
#
#Adicionando os repositórios EPEL
#
echo -e "Adicionando os repositorios ${bold}EPEL${rese}"
yum -y install epel-release > /dev/null 2>&1
chkinst
#
#Instalando o banco de dados (MariaDB)
#
fase1
echo -e "Instalando o banco de dados ${bold}(MariaDB)${rese}"
yum -y install mariadb-server mariadb > /dev/null 2>&1
chkinst
#
#INCIANDO SERVICOS, CONFIGURANDO INICIALIZACAO.
#
echo -e "Inciando e configurando o servico"
systemctl start mariadb.service
systemctl enable mariadb.service
if [ $? -gt 0 ]; then
  echo -e "${verm}Erro na inicializacao${rese}"
   else
   echo -e "${verd}OK!${rese}"
   echo -e "${azul}Startup Config - Abaixo${rese}"
fi
mysql_secure_installation
#
#Instalando o APACHE
#
fase2
echo -e "Instalando o servidor web ${bold}Apache2${rese}"
yum -y install httpd > /dev/null 2>&1
chkinst
#
# INCIANDO O SERVICO E CONFIGURANDO A INICIALIZACAO
#
systemctl start httpd.service
systemctl enable httpd.service
chkinit
#
# CONFIGURACAO INICIAL DO FIREWALL (LIBERAR APACHE).
#
echo -e "Instalando ${bold}Firewall-CMD${rese}"
yum -y install firewalld.noarch > /dev/null 2>&1
if [ $? -gt 0 ]; then
  echo -e "${verm}Erro na instalacao${rese}"
   else
echo -e "${verd}OK!${rese}"
echo -e "Adicionando as regras de liberação ${bold}HTTP e HTTPS${rese}"
systemctl start firewalld.service
systemctl enable firewalld.service
chkinit
firewall-cmd --permanent --zone=public --add-service=http 
firewall-cmd --permanent --zone=public --add-service=https
firewall-cmd --reload
fi
#
# INSTALANDO O PHP
#
fase3
echo -e "Instalando o ${bold}PHP 5.4.16${rese}"
yum -y install php > /dev/null 2>&1
chkinst
echo -e "Reiniciando o Apache..."
systemctl restart httpd.service
chkinit
#
# VERIFICACAO DA VERSAO PHP
#
fase4
echo -e "O Arquivo /var/www/html/info.php sera criado"
echo "<?php phpinfo();?>" >> /var/www/html/info.php
if [ $? -gt 0 ]; then
  echo -e "${verm}Falha ao escrever no arquivo${rese}"
   else
echo -e "${verd}Codigo Adicionado${rese}"
echo -e "Teste o php em ${cian}http://$(ip addr | grep inet | grep enp0s3 | awk -F" " '{print $2}'| sed -e 's/\/.*$//')/info.php${rese}"
fi
#
# INSTALANDO OS MODULOS PHP-MYSQL
#
fase5
echo -e "Instalando o ${bold}PHP-MySQL e CMS Modules${rese}"
echo -e "Passo 1, PHP-MySQL"
yum -y install php-mysql > /dev/null 2>&1
chkinst
echo -e "Passo 2, CMS Modules"
yum -y install php-gd php-ldap php-odbc php-pear php-xml php-xmlrpc php-mbstring php-snmp php-soap curl curl-devel > /dev/null 2>&1
chkinst
echo -e "Reiniciando o Apache..."
systemctl restart httpd.service
chkinit
#
# INSTALANDO O PHPMYADMIN
#
fase6
echo -e "Instalando o ${bold}PhpMyAdmin${rese}"
yum -y install phpMyAdmin > /dev/null 2>&1
chkinst
#
echo -e "Lembre-se de modificar os arquivos /etc/phpMyAdmin/config.inc.php & /etc/httpd/conf.d/phpMyAdmin.conf"
#
echo -e "Reiniciando o Apache..."
systemctl restart httpd.service
chkinit
echo -e "${cian}Instalação Finalizada...${rese}"
echo -e "${bold}${bran}Tecle para sair${rese}"
read -n 1 -p "" AB && exit 0
