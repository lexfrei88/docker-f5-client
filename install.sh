#!/bin/bash

# SOURCE DIRECTORY
CWD="$(cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"

if [[ -f /usr/bin/sap-vpn ]]; then
    echo Already insatlled.
    read -p 'Would you like to change configuration?'
    if [[ $REPLY =~ '[y|Y|([y|Y]es)]' ]]; then
        git -C $CWD checkout -f master
    else
        exit 0
    fi
fi

HOST='https://connectwdf11.sap.com'
CUSER=''
PIN=''
MODE='gateway'

# HOST
read -p "Enter VPN host to connect[Press enter to use default = $HOST]:"
if [[ -n $REPLY ]]; then
    HOST=$REPLY
fi

# USER
read -p "Enter your C/D/I-user:"
CUSER="$REPLY"

# PIN
read -p "Enter your PIN[4 digits]:"
PIN=$REPLY

# MODE
read -p "Enter default mode for VPN connection[client|gateway]:"
if [[ -n $REPLY ]]; then
    MODE="${REPLY}"
fi

FILE=$CWD/sap-vpn
sed -i "s,{{CWD}},$CWD,g" $FILE
sed -i "s/{{CUSER}}/$CUSER/g" $FILE
sed -i "s,{{HOST}},$HOST,g" $FILE
sed -i "s/{{PIN}}/$PIN/g" $FILE
sed -i "s/{{MODE}}/$MODE/g" $FILE

chmod a+x $FILE 
sudo cp $FILE /usr/bin/ 

