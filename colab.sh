#!/bin/bash
for i in `seq 0 18` # for colab Pro
do
    echo "[$i]" ` date '+%y/%m/%d %H:%M:%S'` "connected."
    start "https://colab.research.google.com/drive/118TixGPT43NX8PwrpK-Q-skjMFLqkkn9?hl=ja#scrollTo=bDs3KZudqQt4"
    sleep 3600
done