#!/bin/sh
# DADOS DO SERVIDOR
SQUID_SERVER=”192.168.100.1"
#PLACA DE REDE LIGADA A INTERNET
INTERNET=”enp0s3"
#ENDEREÇO DA SUA REDE LOCAL
LOCAL=”192.168.100.0/24"
#PORTA DO SQUID
SQUID_PORT=”3128"
#LIMPANDO REGRAS ANTIGAS DO FIREWALL QUE VOCE PODERIA TER
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X
#Habilitando ip Forward
echo 1 > /proc/sys/net/ipv4/ip_forward
#Configurando filtros padrão
iptables -P INPUT DROP
iptables -P OUTPUT ACCEPT
#Se tornando um roteador para toda rede
iptables -t nat -A POSTROUTING -o $INTERNET -j MASQUERADE
iptables -A FORWARD -s $LOCAL -j ACCEPT
#Acesso ilimitado ao loopback iptables -A INPUT -i lo -j ACCEPT iptables -A OUTPUT -o lo -j ACCEPT
#Permitir UDP/DNS e FTP PASSIVO iptables -A INPUT -i $INTERNET -m state —state ESTABLISHED,RELATED -j ACCEPT
#Acesso ilimitado a rede iptables -A INPUT -s $LOCAL -j ACCEPT iptables -A OUTPUT -s $LOCAL -j ACCEPT
# Regra para tornar o squid transparente encaminhando todas as requisições da porta 80 para a 3128 do squid
iptables -t nat -A PREROUTING -s $LOCAL -p tcp —dport 80 -j DNAT —to $SQUID_SERVER:$SQUID_PORT iptables -t nat -A PREROUTING -i $INTERNET -p tcp —dport 80 -j REDIRECT —to-port $SQUID_PORT
#Permitir tudo e fazer log
iptables -A INPUT -j LOG
iptables -A INPUT -j DROP
#Abrir tudo iptables -A INPUT -i $INTERNET -j ACCEPT iptables -A OUTPUT -o $INTERNET -j ACCEPT
