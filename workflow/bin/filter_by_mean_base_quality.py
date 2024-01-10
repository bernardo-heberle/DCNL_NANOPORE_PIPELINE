#!/usr/bin/env python3

import sys

def calculate_mean_quality(quality_string):
    return sum(ord(char) - 33 for char in quality_string) / len(quality_string)

def filter_fastq(input_file, threshold, output_file):
    with open(input_file, 'r') as infile, open(output_file, 'w') as outfile:
        while True:
            header = infile.readline().strip()
            if not header:
                break
            sequence = infile.readline().strip()
            plus = infile.readline().strip()
            quality = infile.readline().strip()

            if calculate_mean_quality(quality) >= threshold:
                outfile.write(f"{header}\n{sequence}\n{plus}\n{quality}\n")

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python filter_fastq.py <input_file> <quality_threshold> <output_file>")
        sys.exit(1)

    input_fastq = sys.argv[1]
    quality_threshold = float(sys.argv[2])
    output_fastq = sys.argv[3]

    filter_fastq(input_fastq, quality_threshold, output_fastq)
    print(f"Filtered FASTQ file saved to {output_fastq}")
