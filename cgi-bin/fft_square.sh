#!/bin/sh
# if the /mnt/ran/fft does not exist then create it and run all fft demos
if [ ! -d "/mnt/ram/fft" ] ; then
  /examples/fft/bin/setup_target_fft_env.sh 
fi

# choose 256 or 4096 fft
if [ ! -f "/home/root/.fft_square" ] ; then
  num=256
  echo 4096 > /home/root/.fft_square
else
  num=`cat /home/root/.fft_square`
  if [ $num == 256 ] ; then
    echo 4096 > /home/root/.fft_square
  elif [ $num == 4096 ] ; then
    echo 256x32x128 > /home/root/.fft_square
  else
    echo 256 > /home/root/.fft_square
  fi        
fi

size=$num
if [ $size == 256x32x128 ] ; then
        size=1M
fi
#rerun demo
pushd /mnt/ram/fft  
  ./neon32_${num} --input=input_waveforms/ne10cpx_long_square${size}.bin --output=output_waveforms/neon32_${num}_square.bin > /home/root/square.log
  cat output_waveforms/neon32_${num}_square.bin | ./ne10cpx_long_to_text > output_waveforms/neon32_${num}_square.txt
  rm output_waveforms/neon32_${num}_square.bin 

  ./fftdma_${num} --input=input_waveforms/ne10cpx_short_square${size}.bin --output=output_waveforms/fftdma_${num}_square.bin >> /home/root/square.log
  #cat output_waveforms/fftdma_${num}_square.bin | ./ne10cpx_long_to_text > output_waveforms/fftdma_${num}_square.txt
  rm output_waveforms/fftdma_${num}_square.bin 


  if [ $size != 1M ] ; then
      echo "Computation (us): 0" > /home/root/square_fpga.log
      echo "Computation (us): 0" >> /home/root/square_fpga.log
  else
    ./stream_neon32_256x32x128 --input=input_waveforms/ne10cpx_long_square${size}.bin --output=output_waveforms/stream_neon32_${num}_square.bin > /home/root/square_fpga.log
    rm output_waveforms/stream_neon32_${num}_square.bin 
  
    ./stream_fpga_256x32x128 --input=input_waveforms/ne10cpx_short_square${size}.bin --output=output_waveforms/stream_fpga_${num}_square.bin >> /home/root/square_fpga.log
    rm output_waveforms/stream_fpga_${num}_square.bin 
          
  fi
  
popd 

if [ $size != 1M ] ; then
cat /mnt/ram/fft/output_waveforms/neon32_${num}_square.txt | perl -p -e "s/\t[-\d]+/,/; s/real//; s/imag//; s/[\r\n]//g; s/\s+//g;" 
else
        echo ,
fi

printf "%.0f" `grep "(us)" /home/root/square_fpga.log | head -1 | perl -p -e "s/^.*: //; s/[\r\n]//g;"`
echo -n ","
printf "%.0f" `grep "(us)" /home/root/square_fpga.log | tail -1 | perl -p -e "s/^.*: //; s/[\r\n]//g;"`
echo -n ","


printf "%.0f" `grep "(us)" /home/root/square.log | head -1 | perl -p -e "s/^.*: //; s/[\r\n]//g;"`
echo -n ","
printf "%.0f" `grep "(us)" /home/root/square.log | tail -1 | perl -p -e "s/^.*: //;"`

#echo $! > /home/root/.fft_square_pid
