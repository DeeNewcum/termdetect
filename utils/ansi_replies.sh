#!/bin/sh

# show how the current terminal responds to various ANSI queries
#
# see http://paperlined.org/apps/terminals/queries.html


echo "======== CPR - cursor position report ========"
./ansi_reply.pl  '\e[6n' R
echo


echo "======== query extended cursor position ========"
./ansi_reply.pl  '\e[?6n' R
echo


echo "======== DSR - device status report ========"
./ansi_reply.pl  '\e[5n' n
echo


echo "======== query printer status ========"
./ansi_reply.pl  '\e[?15n' n
echo


echo "======== DA - device attributes ========"
./ansi_reply.pl  '\e[c' c
echo


echo "======== DA - device attributes ========"
./ansi_reply.pl  '\e[6c' c
echo


echo "======== DECID - identify terminal ========"
./ansi_reply.pl  '\eZ' ''
echo


echo "======== query secondary device attributes ========"
./ansi_reply.pl  '\e[>c' ''
echo


echo "======== query tertiary device attributes ========"
./ansi_reply.pl  '\e[=c' ''
echo


echo "======== ENQ (enquire) / answerback ========"
./ansi_reply.pl  '\005' ''
echo



echo "======== query terminal parameters ========"
./ansi_reply.pl  '\e[x' ''

cat <<EOF

response is:
    - parity (1 = none, 2 = space, 3 = mark, 4 = odd, 5 = even)
    - nbits  (1 = 8bit, 2 = 7bit)
    - transmit speed  (0,8,16,24,32,40,48,56,64,72,80,88,96,104,112,120,128 correspond to speeds of
      50,75,110,134.5,150,200,300,600,1200,1800,2000,2400,3600,4800,9600,19200,
        and 38400 baud or above)
    - receive speed
    - clock multiplier
    - flags  (0-15)
EOF
