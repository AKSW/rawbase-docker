#!/bin/sh

echo "Starting Virtuoso"
$VIRTUOSO -c $VIRTUOSO_CFG
sleep 3s
echo "Starting R&Wbase"
$RAWBASE_HOME/rawbase-server.sh 80
