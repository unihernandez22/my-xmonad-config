#!/bin/sh

for (( ; ; ))
do
	ssid=$(connmanctl services | grep '*A.' | sed 's/*\w\w //' | sed 's/\s\+wifi.\+//')
	[[ ${#ssid} -le "10" ]] || ssid=$(echo $ssid | cut -c -8)"..."
	[[ $ssid == "" ]] && ssid="N/A" 
	echo $ssid
	sleep 5
done
