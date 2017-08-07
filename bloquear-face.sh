#!/bin/bash


# bkp.sh v1.0.0
# Script bloqueia facebook via iptables
#
# Alisson Oliveira  
# linukiss@gmail.com
# Twitter = @linukiss

# Tool URL = git comming soon
# 

# Baseado em posts de https://www.vivaolinux.com.br/topico/Squid-Iptables/BLOQUEIO-DEFINITO-FACEBOOK-E-OUTROS-SITES-HTTPS
# Creditos para https://www.vivaolinux.com.br/~kil-linux

# politica de versao
# * funcionalide
# + adicionado funcao
# - remocao de funcao
# Changelog 
# 1.0.0
# * bloquear facebook e outros sites para todos, menos os que estão em ip liberado
#para gerar a lista atualizada do facebook 
# whois -h whois.radb.net -- '-i origin AS32934' | awk '/^route:/ {print $2;}' | sort | uniq > facebook.ip


##############################################################################################################
######### BLOQUEIA SITES HTTPS###########
#for ip in `cat /etc/squid/bloqueados/ip_liberados`; do
#/sbin/iptables -t nat -I POSTROUTING -s $ip -m string --algo bm --string "facebook.com" -j MASQUERADE

#done
#/sbin/iptables -I FORWARD -m string --algo bm --string "facebook.com" -j DROP
#Lista de IPs liberados para acessar o Facebook
IPS_ACCEPT=$(cat /etc/squid/controle/ip_liberados)

#Sub-rede interna do ambiente em questão
REDE_INTERNA="192.168.254.0/24"

#Criando nova regra FACEBOOK
/sbin/iptables -N FACEBOOK

#Transferindo todo tráfego fonte da rede interna para a regra FACEBOOK
/sbin/iptables -I FORWARD -s $REDE_INTERNA -j FACEBOOK

#Percorre o arquivo dos IPs do Facebook (facebook.txt) e vai colocando REJECT em todos os IPs da rede interna, exceto os liberados.
for i in `cat /home/sbf/facebook.ip`; do

        #O acesso dos IPs (que caíram na regra FACEBOOK) ao Facebook vai ser rejeitado
	    /sbin/iptables -A FACEBOOK -d $i -j REJECT
	    		

    #Percorre lista de IPs liberados e vai colocando ACCEPT neles
        for liberados in $IPS_ACCEPT; do
	#for liberados in $REDE_INTERNA ; do

        /sbin/iptables -I FORWARD -s $liberados -d $i -j ACCEPT
    done

done




############ FIM ###########
