#!/bin/sh

if [ ! -d "/mnt/ram/fft" ] ; then
  /examples/fft/bin/setup_target_fft_env.sh 
fi

if [ ! -f "/home/root/.fft_triangle" ] ; then
  num=256
  echo 4096 > /home/root/.fft_triangle
else
  num=`cat /home/root/.fft_triangle`
  if [ $num == 256 ] ; then
    echo 4096 > /home/root/.fft_triangle
  else
    echo 256 > /home/root/.fft_triangle
  fi        
fi

#rerun demo
pushd /mnt/ram/fft 
if [ $num == 256 ] ; then
  ./c16_256 --input=input_waveforms/ne10cpx_short_triangle256.bin --output=output_waveforms/c16_256_triangle.bin > /home/root/triangle.log
  cat output_waveforms/c16_256_triangle.bin | ./ne10cpx_short_to_text > output_waveforms/c16_256_triangle.txt

  ./fftdma_256 --input=input_waveforms/ne10cpx_short_triangle256.bin --output=output_waveforms/fftdma_256_triangle.bin >> /home/root/triangle.log
  cat output_waveforms/fftdma_256_triangle.bin | ./ne10cpx_long_to_text > output_waveforms/fftdma_256_triangle.txt
else
  ./c16_4096 --input=input_waveforms/ne10cpx_short_triangle4096.bin --output=output_waveforms/c16_4096_triangle.bin > /home/root/triangle.log
  cat output_waveforms/c16_4096_triangle.bin | ./ne10cpx_short_to_text > output_waveforms/c16_4096_triangle.txt

  ./fftdma_4096 --input=input_waveforms/ne10cpx_short_triangle4096.bin --output=output_waveforms/fftdma_4096_triangle.bin >> /home/root/triangle.log
  cat output_waveforms/fftdma_4096_triangle.bin | ./ne10cpx_long_to_text > output_waveforms/fftdma_4096_triangle.txt
fi
popd

cat /mnt/ram/fft/output_waveforms/fft_${num}_triangle.txt | perl -p -e "s/\t[-\d]+/,/; s/real//; s/imag//; s/[\r\n]//g; s/\s+//g;" 
printf "%.0f" `grep "(us)" /home/root/triangle.log | head -1 | perl -p -e "s/^.*: //; s/[\r\n]//g;"`
echo -n ","
printf "%.0f" `grep "(us)" /home/root/triangle.log | tail -1 | perl -p -e "s/^.*: //;"`


#echo $! > /home/root/.fft_triangle_pid
