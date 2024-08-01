#!/usr/bin/env python3

import sys
import pandas as pd

def merge_files(input_files, output_file):
    dataframes = []
    for file in input_files:
        df = pd.read_csv(file, sep='\t')
        df.columns = ['Chromosome', file.split('/')[-1].replace('.tsv', '')]
        dataframes.append(df)

    merged_df = dataframes[0]
    for df in dataframes[1:]:
        merged_df = pd.merge(merged_df, df, on='Chromosome', how='outer')

    merged_df.to_csv(output_file, sep='\t', index=False)

if __name__ == "__main__":
    input_files = sys.argv[1:-1]
    output_file = sys.argv[-1]
    merge_files(input_files, output_file)
