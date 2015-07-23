#!/bin/sh
# if the /mnt/ran/fft does not exist then create it and run all fft demos
if [ ! -d "/mnt/ram/fft" ] ; then
  /examples/fft/bin/setup_target_fft_env.sh 
fi

# choose 256 or 4096 fft
if [ ! -f "/home/root/.fft_sine" ] ; then
  num=256
  echo 4096 > /home/root/.fft_sine
else
  num=`cat /home/root/.fft_sine`
  if [ $num == 256 ] ; then
    echo 4096 > /home/root/.fft_sine
  elif [ $num == 4096 ] ; then
    echo 256x32x128 > /home/root/.fft_sine
  else
    echo 256 > /home/root/.fft_sine
  fi        
fi

size=$num
if [ $size == 256x32x128 ] ; then
        size=1M
fi
#rerun demo
pushd /mnt/ram/fft  
  ./c16_${num} --input=input_waveforms/ne10cpx_short_sine${size}.bin --output=output_waveforms/c16_${num}_sine.bin > /home/root/sine.log
  cat output_waveforms/c16_${num}_sine.bin | ./ne10cpx_short_to_text > output_waveforms/c16_${num}_sine.txt
  rm output_waveforms/c16_${num}_sine.bin 

  ./fftdma_${num} --input=input_waveforms/ne10cpx_short_sine${size}.bin --output=output_waveforms/fftdma_${num}_sine.bin >> /home/root/sine.log
  cat output_waveforms/fftdma_${num}_sine.bin | ./ne10cpx_long_to_text > output_waveforms/fftdma_${num}_sine.txt
  rm output_waveforms/fftdma_${num}_sine.bin 
popd 

if [ $size != 1M ] ; then
cat /mnt/ram/fft/output_waveforms/fftdma_${num}_sine.txt | perl -p -e "s/\t[-\d]+/,/; s/real//; s/imag//; s/[\r\n]//g; s/\s+//g;" 
else
        echo ,
fi
printf "%.0f" `grep "(us)" /home/root/sine.log | head -1 | perl -p -e "s/^.*: //; s/[\r\n]//g;"`
echo -n ","
printf "%.0f" `grep "(us)" /home/root/sine.log | tail -1 | perl -p -e "s/^.*: //;"`

#echo $! > /home/root/.fft_sine_pid
