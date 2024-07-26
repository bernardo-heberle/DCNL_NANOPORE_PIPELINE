process CONVERT_INPUT_FROM_MINKNOW_BARCODED {

    publishDir "results/${params.out_dir}/minknow_converted_input", mode: "copy", overwrite: true

    label 'cpu'

    input:
        path input
    output:
        path "*.bam", emit: bam
        path "*.txt", emit: txt

    script:
        """
        # Define the input directory path
        input_dir="${input.toString()}"

        # Check if the input directory exists
        if [ -d "\${input_dir}" ]; then
            echo "Input directory exists."
        else
            echo "Input directory does not exist."
            exit 1
        fi

        # Find all 'pass' directories, follow symlinks with -L
	find -L "\${input_dir}" -type d \\( -name 'pass' -o -name '*pass*' \\) -print0 | while IFS= read -r -d '' pass_dir; do 
	    # Find all 'barcode' directories within each 'pass' directory
            find -L "\$pass_dir" -type d -name '*barcode*' -print0 -o -type d -name '*unclassified*' -print0 | while IFS= read -r -d '' barcode_dir; do 
		# Get the name of the directory two levels above the barcode directory
                parent_dir_two_above=\$(basename \$(dirname \$(dirname "\$barcode_dir")))

                # Check if the barcode directory contains any BAM files
	        bam_files=(\$(find -L "\$barcode_dir" -type f -name '*.bam' | grep -v 'iltered'))	
		if [ \${#bam_files[@]} -gt 0 ]; then
                    # Merge BAM files using samtools
                    barcode_name=\$(basename "\$barcode_dir")
                    output_bam="./\${parent_dir_two_above}_\${barcode_name}.bam"
                    samtools merge "./\$output_bam" "\${bam_files[@]}"

                    # Generate summary with dorado
                    dorado summary "\$output_bam" > "./\${parent_dir_two_above}_\${barcode_name}.txt"
                fi
            done
        done
        """
}


process CONVERT_INPUT_FROM_MINKNOW_NOT_BARCODED {

    publishDir "results/${params.out_dir}/minknow_converted_input", mode: "copy", overwrite: true

    label 'cpu'

    input:
        path input
    output:
        path "*.bam", emit: bam
        path "*.txt", emit: txt

    script:
        """
        # Define the input directory path
        input_dir="${input.toString()}"

        # Check if the input directory exists
        if [ -d "\${input_dir}" ]; then
            echo "Input directory exists."
        else
            echo "Input directory does not exist."
            exit 1
        fi

        # Find all 'pass' directories, follow symlinks with -L
	find -L "\${input_dir}" -type d \\( -name 'pass' -o -name '*pass*' \\) -print0 | while IFS= read -r -d '' pass_dir; do 
	    
	    ## Get the name of the input directory for file naming 
	    parent_dir="\${pass_dir%/*}"; parent_dir="\${parent_dir##*/}"
 
                # Check if the pass directory contains any BAM files
	        bam_files=(\$(find -L "\$pass_dir" -type f -name '*.bam' | grep -v 'iltered'))	
		if [ \${#bam_files[@]} -gt 0 ]; then
                    # Merge BAM files using samtools
                    output_bam="./\${parent_dir}.bam"
                    samtools merge "./\$output_bam" "\${bam_files[@]}"

                    # Generate summary with dorado
                    dorado summary "\$output_bam" > "./\${parent_dir}.txt"
                fi
        done
        """
}

