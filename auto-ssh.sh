#!/bin/bash

NUM_OF_NODES=8
NODE1="172.16.1.36" 
NODE2="172.16.1.37"
NODE3="172.16.1.38"
NODE4="172.16.1.39"
NODE5="172.16.1.40"
NODE6="172.16.1.41"
NODE7="172.16.1.42"
NODE8="172.16.1.43"

USER=root
EXPECT=/usr/bin/expect
PASSWD="root.123"
#USER_PROMPT="*$ "
USER_PROMPT="*# "

if [ "x${NODE1}" == "x" -o "x${USER}" == "x" -o "x${PASSWD}" == "x" ]; then
    echo ""
    echo "Please set the NODE INFO, USER and PASSWD"
    echo "then $0 to start..."
    exit 1
fi

declare -i l_i=1
while [ $l_i -le $NUM_OF_NODES ]
do
    eval l_current_node=\$NODE$l_i
    
    $EXPECT <<EOF
    spawn ssh $USER@$l_current_node 
    expect "*(yes/no)?*" {
        send -- "yes\r"
        expect "*?assword:*"
        send -- "$PASSWD\r"
    } "*?assword:*" {send -- "$PASSWD\r"}
    expect "$USER_PROMPT"
    send -- "ssh-keygen -t rsa -q -f ~/.ssh/id_rsa -P '' \r"
    expect "*Overwrite (yes/no)? " {
        send -- "yes\r"
    } "$USER_PROMPT" {send -- "\r"}
    expect "$USER_PROMPT"
    send -- "cat ~/.ssh/id_rsa.pub | ssh $USER@$NODE1 'cat - >> ~/.ssh/authorized_keys' \r"
    expect "*(yes/no)?*" {
        send -- "yes\r"
        expect "*?assword:*" 
        send -- "$PASSWD\r"
    } "*?assword:*" {send -- "$PASSWD\r"}
    expect "$USER_PROMPT"
    send -- "exit\r"
EOF
    ((l_i++))
done

declare -i l_n=1
while [ $l_n -le $NUM_OF_NODES ]
do
    eval l_current_node=\$NODE$l_n
    $EXPECT <<EOF

    spawn ssh $USER@$NODE1
    expect "*?assword:*" {
        send -- "$PASSWD\r"
        expect "$USER_PROMPT"
    } "$USER_PROMPT" {send -- "scp ~/.ssh/authorized_keys $l_current_node:~/.ssh/ \r"}
    expect "*?assword:*"
    send -- "$PASSWD\r"
    expect "$USER_PROMPT"
    send -- "exit\r"
EOF
    ((l_n++))
done
