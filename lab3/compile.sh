#!/bin/bash

# Get the input filename
input_file_1="$1"
input_file_2="$2"
# input_file_3="$3"

# Use the 'basename' and 'cut' commands to extract the filename without extension
filename1=$(basename "$input_file_1" | cut -d. -f1)
filename2=$(basename "$input_file_2" | cut -d. -f1)
# filename3=$(basename "$input_file_3" | cut -d. -f1)

nasm -f bin -o "$filename1.bin" "$filename1.asm"
mv "$filename1.bin" "$filename1.img"

nasm -I lab3/utils/string -f bin -o "$filename2.bin" "$filename2.asm"
mv "$filename2.bin" "$filename2.img"

# nasm -f bin -o "$filename3.bin" "$filename3.asm"
# mv "$filename3.bin" "$filename3.img"

cat "$filename1.img" "$filename2.img" > "bootable.img"

truncate -s 1474560 "bootable.img"

rm "$filename1.img" "$filename2.img"

# Echo the filename without extension
echo "File: 'boot.img' is compiled"
