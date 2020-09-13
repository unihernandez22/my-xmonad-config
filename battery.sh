#!/bin/sh


if [ $1 == '-level' ]; then
  while true; do
    percent=$(cat /sys/class/power_supply/BAT0/capacity)
    echo $percent | sed 's/$/%/'
    sleep 5
  done
elif [ $1 == '-icon' ]; then
  while true; do
    percent=$(cat /sys/class/power_supply/BAT0/capacity)
    state=$(cat /sys/class/power_supply/BAT0/status)
    if [ $state == 'Charging' ]; then
      echo 
    elif [[ $percent > 95 ]] || [ $percent -eq 100 ]; then
      echo 
    elif [[ $percent > 75 ]]; then
      echo 
    elif [[ $percent > 50 ]]; then
      echo 
    elif [[ $percent > 30 ]]; then
      echo 
    elif [[ $percent > 15 ]]; then
      echo 
    else
      echo 
    fi
    sleep 5
  done
fi
