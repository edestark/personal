#!/bin/bash
#
# YLMF-PC Botnet Script Blocker.
# 
# Created by Edegard S.
# Hostgator Brasil 2017
#
#################################
# BASHCSS
pret='\E[0;30m'   # Black
verm='\E[0;31m'   # Red
verd='\E[0;32m'   # Green
amar='\E[0;33m'   # Yellow
bran='\E[0;37m'   # White
rese=$(tput sgr0) # No color.
#
# Header
cab() {
clear
echo -e "---------------------------------------------------------"
echo -e "                                                         "
echo -e "            ${bran}YLMF-PC BOT PROTECTION SCRIPT${rese}  "
echo -e "                                                         "    
echo -e "---------------------------------------------------------"
}
#
# Calls the header
#
cab
#
# Tests if file heloblocks already exists, also creating the file and adding the string if it doesn't.
if [ ! -f /etc/heloblocks ]; then 
	echo -e "O arquivo ainda não existe, criando...\n";
		echo "ylmf-pc" >> /etc/heloblocks > /dev/null 2>&1
			echo -e "${verd}[OK]${rese}\n"
else
	echo "O arquivo já existe, adicionando o bot ylmf-pc... (Se não existir).\n"
		grep --color "ylmf-pc" /etc/heloblocks
			[ $? -gt 0 ] && echo "ylmf-pc" >> /etc/heloblocks
fi
# Tests the if the ACL file exits, and creates with the string if it doesn't exists.
if [ ! -f /usr/local/cpanel/etc/exim/acls/ACL_SMTP_HELO_BLOCK/custom_begin_smtp_helo ]; then
echo -e "O arquivo ainda não existe, criando....\n";
printf 'drop 
  condition = ${lookup{$sender_helo_name}lsearch{/etc/heloblocks}{yes}{no}} 
  log_message = HELO/EHLO - HELO on heloblocks Blocklist 
  message = HELO on heloblocks Blocklist 
accept' >> /usr/local/cpanel/etc/exim/acls/ACL_SMTP_HELO_BLOCK/custom_begin_smtp_helo
echo -e "${verd}[OK]${rese}\n"
else
	echo -e "O arquivo já existe, adicionando a ${amar}ACL${rese}...\n"
		grep --color "/etc/heloblocks" /usr/local/cpanel/etc/exim/acls/ACL_SMTP_HELO_BLOCK/custom_begin_smtp_helo > /dev/null 2>&1
                        [ $? -gt 0 ] && printf 'drop 
  condition = ${lookup{$sender_helo_name}lsearch{/etc/heloblocks}{yes}{no}} 
  log_message = HELO/EHLO - HELO on heloblocks Blocklist 
  message = HELO on heloblocks Blocklist 
accept' >> /usr/local/cpanel/etc/exim/acls/ACL_SMTP_HELO_BLOCK/custom_begin_smtp_helo
fi
#
# Restarts exim to apply modifications.
service exim restart
#
# Test guide information
#
printf "\nProcedimento finalizado, realize o teste abaixo:
telnet mail.dominio_do_servidor.com 25
Após conectar, digite helo ylmf-pc\n\n"
#
