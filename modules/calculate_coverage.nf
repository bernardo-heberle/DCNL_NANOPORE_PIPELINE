process CALCULATE_COVERAGE {

    label 'cpu'

    input:
        tuple val(id), path(bam)     
        path(bai)

    output:
        path("*coverage*")

    script:
        """
		
	    echo -e "Chromosome\\t${id}" > ${id}.coverage.tsv
	    samtools depth -a ${bam} | awk '
	    {
		sum[\$1] += \$3;
		count[\$1]++;
	    }
	    END {
		for (chr in sum) {
		    print chr "\\t" sum[chr]/count[chr];
		}
	    }' >> ${id}.coverage.tsv


	"""

}

process MERGE_COVERAGE {

    publishDir "${params.steps_2_and_3_input_directory}/calculate_coverage/", mode: "copy", pattern: "*", overwrite: true 

    label 'cpu'

    input:
    	path(coverage_files)

    output:
    	path("merged_coverage.tsv"), emit: output
	path("*mqc*"), emit: mqc

    script:
    """

    merge_files.py ${coverage_files.join(' ')} merged_coverage.tsv

    echo "# plot_type: 'table'" >> "Chr_Coverage_mqc.tsv"
    echo "# id: 'chromosome coverage custom'" >> "Chr_Coverage_mqc.tsv"
    echo "# section_name: 'Average chromosome coverage per sample'" >> "Chr_Coverage_mqc.tsv"
    cat merged_coverage.tsv >> "Chr_Coverage_mqc.tsv"

    """

}
