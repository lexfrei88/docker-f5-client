#!/bin/bash

if [[ -f /usr/bin/sap-vpn ]]; then
    echo Already insatlled.
    exit 0
fi

HOST='https://connectwdf11.sap.com'
CUSER=''
PIN=''

read -p "Enter VPN host to connect[Press enter to use default = $HOST]:"
if [[ -n $REPLY ]]; then
    HOST=$REPLY
fi
read -p "Enter your C/D/I-user:"
CUSER="$REPLY"
read -p "Enter your PIN[4 digits]:"
PIN=$REPLY
read -p "Enter default mode for VPN connection[client|gateway]:"
MODE="${REPLY}"
CWD="$(cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"

FILE=$CWD/sap-vpn
sed -i "s,{{CWD}},$CWD,g" $FILE
sed -i "s/{{CUSER}}/$CUSER/g" $FILE
sed -i "s,{{HOST}},$HOST,g" $FILE
sed -i "s/{{PIN}}/$PIN/g" $FILE
sed -i "s/{{MODE}}/$MODE/g" $FILE

chmod a+x $FILE 
sudo cp $FILE /usr/bin/ 

