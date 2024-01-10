#!/usr/bin/env python3

import sys


def convert_u_to_t_in_sequence(input_file, output_file):
    """
    This function reads a FASTQ file, replaces all occurrences of 'U' with 'T'
    in the sequence lines only, and writes the modified content to a new file.
    """
    try:
        with open(input_file, 'r') as infile, open(output_file, 'w') as outfile:
            line_counter = 0  # To keep track of line numbers

            for line in infile:
                line_counter += 1
                # In FASTQ format, the sequence line is every 2nd line out of sets of 4 lines
                if line_counter % 4 == 2:
                    # Replace 'U' with 'T' in the sequence line
                    line = line.replace('U', 'T')

                outfile.write(line)

                # Reset the line counter after every set of 4 lines
                if line_counter == 4:
                    line_counter = 0

        return "Conversion successful. Output file created: " + output_file
    except Exception as e:
        return "An error occurred: " + str(e)


# Example usage
input_fastq = sys.argv[1]  # First input from the command line, the input fastq file
output_fastq = sys.argv[2] # Second input from the command line, the name of the output fastq file

# Call the function and print the result
convert_u_to_t_in_sequence(input_fastq, output_fastq)
