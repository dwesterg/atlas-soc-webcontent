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
  else
    echo 256 > /home/root/.fft_sine
  fi        
fi

#rerun demo
pushd /mnt/ram/fft 
if [ $num == 256 ] ; then
  ./c16_256 --input=input_waveforms/ne10cpx_short_sine256.bin --output=output_waveforms/c16_256_sine.bin > /home/root/sine.log
  cat output_waveforms/c16_256_sine.bin | ./ne10cpx_short_to_text > output_waveforms/c16_256_sine.txt

  ./fftdma_256 --input=input_waveforms/ne10cpx_short_sine256.bin --output=output_waveforms/fftdma_256_sine.bin >> /home/root/sine.log
  cat output_waveforms/fftdma_256_sine.bin | ./ne10cpx_long_to_text > output_waveforms/fftdma_256_sine.txt
else
  ./c16_4096 --input=input_waveforms/ne10cpx_short_sine4096.bin --output=output_waveforms/c16_4096_sine.bin > /home/root/sine.log
  cat output_waveforms/c16_4096_sine.bin | ./ne10cpx_short_to_text > output_waveforms/c16_4096_sine.txt

  ./fftdma_4096 --input=input_waveforms/ne10cpx_short_sine4096.bin --output=output_waveforms/fftdma_4096_sine.bin >> /home/root/sine.log
  cat output_waveforms/fftdma_4096_sine.bin | ./ne10cpx_long_to_text > output_waveforms/fftdma_4096_sine.txt
fi
popd

cat /mnt/ram/fft/output_waveforms/fft_${num}_sine.txt | perl -p -e "s/\t[-\d]+/,/; s/real//; s/imag//; s/[\r\n]//g; s/\s+//g;" 
printf "%.0f" `grep "(us)" /home/root/sine.log | head -1 | perl -p -e "s/^.*: //; s/[\r\n]//g;"`
echo -n ","
printf "%.0f" `grep "(us)" /home/root/sine.log | tail -1 | perl -p -e "s/^.*: //;"`

#echo $! > /home/root/.fft_sine_pid
