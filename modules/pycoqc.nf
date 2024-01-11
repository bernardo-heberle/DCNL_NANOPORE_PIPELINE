process PYCOQC {

    publishDir "results/${params.out_dir}/pycoqc/", mode: 'copy', overwrite: true, pattern: "*pycoqc*"
    publishDir "results/${params.out_dir}/basecalling_output/", mode: 'copy', overwrite: true, pattern: "*bai"

    label 'cpu'

    input:
        path(total_bam)
	path(seq_summary)
        val(quality_score)

    output:
        path "*"

    script:
        """

	file="${total_bam}"
	id="\${file%%.*}"
	
	samtools index "${total_bam}"


        pycoQC -f "${seq_summary}" \
            -v \
            -a $total_bam \
            --min_pass_qual $quality_score \
            -o "./\${id}_pycoqc.html" \
            -j "./\${id}_pycoqc.json"
        """
}

