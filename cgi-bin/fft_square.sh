#!/bin/sh

if [ ! -d "/mnt/ram/fft" ] ; then
  /examples/fft/bin/setup_target_fft_env.sh 
fi

if [ ! -f "/home/root/.fft_square" ] ; then
  num=256
  echo 4096 > /home/root/.fft_square
else
  num=`cat /home/root/.fft_square`
  if [ $num == 256 ] ; then
    echo 4096 > /home/root/.fft_square
  else
    echo 256 > /home/root/.fft_square
  fi        
fi

#rerun demo
pushd /mnt/ram/fft 
if [ $num == 256 ] ; then
  ./c16_256 --input=input_waveforms/ne10cpx_short_square256.bin --output=output_waveforms/c16_256_square.bin > /home/root/square.log
  cat output_waveforms/c16_256_square.bin | ./ne10cpx_short_to_text > output_waveforms/c16_256_square.txt

  ./fftdma_256 --input=input_waveforms/ne10cpx_short_square256.bin --output=output_waveforms/fftdma_256_square.bin >> /home/root/square.log
  cat output_waveforms/fftdma_256_square.bin | ./ne10cpx_long_to_text > output_waveforms/fftdma_256_square.txt
else
  ./c16_4096 --input=input_waveforms/ne10cpx_short_square4096.bin --output=output_waveforms/c16_4096_square.bin > /home/root/square.log
  cat output_waveforms/c16_4096_square.bin | ./ne10cpx_short_to_text > output_waveforms/c16_4096_square.txt

  ./fftdma_4096 --input=input_waveforms/ne10cpx_short_square4096.bin --output=output_waveforms/fftdma_4096_square.bin >> /home/root/square.log
  cat output_waveforms/fftdma_4096_square.bin | ./ne10cpx_long_to_text > output_waveforms/fftdma_4096_square.txt
fi
popd

cat /mnt/ram/fft/output_waveforms/fft_${num}_square.txt | perl -p -e "s/\t[-\d]+/,/; s/real//; s/imag//; s/[\r\n]//g; s/\s+//g;" 
printf "%.0f" `grep "(us)" /home/root/square.log | head -1 | perl -p -e "s/^.*: //; s/[\r\n]//g;"`
echo -n ","
printf "%.0f" `grep "(us)" /home/root/square.log | tail -1 | perl -p -e "s/^.*: //;"`


#echo $! > /home/root/.fft_square_pid
