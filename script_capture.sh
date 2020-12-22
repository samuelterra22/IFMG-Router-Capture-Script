#!/bin/bash
################# IFMG Router Capture Script ####################
# AUTHORS:  Samuel Terra Vieira                                 #
#           Matheus Faria Calixto                               #
# ADDRESS:  R. São Luiz Gonzaga, s/n - Bairro São Luiz,         #
#           Formiga - MG, 35577-010                             #
# DATE:     12/2016                                             #
#################################################################

flag=0

while [[ $flag -eq 0 ]]; do

echo -e "\t Select the correct router:"

echo -e "1-\tRouter Lab 3"
echo -e "2-\tRouter L.A.R"
echo -e "3-\tRouter LAB Máquinas"
echo -e "4-\tRouter Xerox"
echo -e "5-\tRouter Biblioteca"
echo -e "6-\tRouter Lab 1"
echo -e "7-\tAnother Custom Router"

read -r -p "Choose an option: " option

if [[ "$option" == "1" ]]; then
	MAC="18:8B:9D:69:D8:D1"
	flag=1

elif [[ "$option" == "2" ]]; then
	MAC="18:8B:9D:69:DC:C1"
	flag=1

elif [[ "$option" == "3" ]]; then
	MAC="18:8b:9d:69:d7:d1"
	flag=1

elif [[ "$option" == "4" ]]; then
	MAC="a4:0c:c3:0c:51:09"
	flag=1

elif [[ "$option" == "5" ]]; then
	MAC="a4:0c:c3:0c:4f:71"
	flag=1

elif [[ "$option" == "6" ]]; then
	MAC="18:8b:9d:69:df:81"
	flag=1

elif [[ "$option" == "7" ]]; then
	read -r -p "Enter the MAC Address: " y
	read -r -p "Enter the SSID: " name
	read -r -p "Enter the Password: " pswd
	PASS=$pswd
	SSID=$name
	MAC=$y
	flag=1

else
	echo -e "Invalid option..."
	sleep 1.6
	clear
fi

if [ "$option" -ge "1" ] && [ "$option" -le "6" ]; then
	PASS="WIFI_PASSWORD_HERE"
	SSID="WIFI_SSID_HERE"
fi

done #End While seleção de roteador.

clear                             # Limpa a tela

contador=1                        # Contador de capturas realizadas

while [[ $contador -le 10 ]]; do  # 10 Capturas

hora=$(date | awk '{print $4}')   # Recebe a hora atual
HOSTS=Hosts-${hora}.txt           # Nome do arquivo de saida
CAPTURA=captura${hora}.pcap       # Nome do arquivo de captura do wireshark
PASTA=Captura-${hora}             # Nomeia a pasta de determinada captura de acordo com a hora
mkdir "${PASTA}"                  # Cria a pasta da captura atual
cd "${PASTA}" || return           # Entra na pasta

touch "${CAPTURA}"                # Cria o arquivo e captura para evitar erros de privilégio
chmod 777 "${CAPTURA}"            # Seta permissões de leitura, escrita e execução para todos os usuários

tshark -a duration:3600 -i mon0 -f "not ether src $MAC and ether dst $MAC and not broadcast" -o wlan.enable_decryption:TRUE -o "uat:80211_keys:\"wpa-pwd\",\"$PASS:$SSID\"" -w ${CAPTURA} #Realiza a filtragem e a captura

tshark -r "${CAPTURA}" > sumary.txt # Salva a captura em um Arquivo Texto

clear

cat sumary.txt | awk '{print $3}' | sort -u > "${HOSTS}" # Salva num arquivo Hosts, apenas os MAC Address dos dispositivos que conectaram (sem repetição)

n_packages=$(awk 'BEGIN{i=1}; END{print $i}' sumary.txt) #Salva a quantidade de pacotes obtidos em uma variável.
n_hosts=$(cat -n "${HOSTS}" | awk 'END{print $1}') # Salva a quantidade de hosts

#Imprime dentro do arquivo Hosts-(xx:xx:xx).txt a qtde de pacotes e de hosts, alem dos hosts encontrados.

echo "------------------------------------------------------" >> "${HOSTS}"
echo "Numero de pacotes capturados: $n_packages" >> "${HOSTS}"
echo "Numero de Hosts conectados: $n_hosts" >> "${HOSTS}"

contador=$(( $contador + 1 ))   # Incrementa o contador de capturas
rm sumary.txt                   # Deleta o arquivo sumary que não é mais necessário.
cd ..                           # Volta no diretório anterior.
done                            # End While.

echo "	[+] Fim da Captura de hoje." # Fim da captura do dia
