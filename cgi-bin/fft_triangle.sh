#!/bin/sh

if [ ! -d "/mnt/ram/fft" ] ; then
  /examples/fft/bin/setup_target_fft_env.sh 
fi

cat /mnt/ram/fft/output_waveforms/fft_4096_triangle.txt | perl -p -e "s/\t[-\d]+/,/; s/real//; s/imag//; s/[\r\n]//g; s/\s+//g;" 
grep "(us)" /mnt/ram/fft/triangle256.log | tail -1 | perl -p -e "s/^.*: //;" 
grep "(us)" /mnt/ram/fft/triangle4096.log | tail -1 | perl -p -e "s/^.*: //;" 
grep "(us)" /mnt/ram/fft/triangle256x32x128.log | tail -1 | perl -p -e "s/^.*: //;" 
#grep "(us)" /mnt/ram/fft/triangle4096.log | tail -1 | perl -p -e "s/^.*: //;" 

#echo $! > /home/root/.fft_triangle_pid
