process PYCOQC {

    publishDir "results/${params.out_dir}/pycoqc/", mode: 'copy', overwrite: true, pattern: "*pycoqc*"

    label 'cpu'

    input:
        val(id)
        path(seq_summary)
        path(total_bam)
        path(total_bai)
        val(quality_score)

    output:
        path "*"

    script:
        """
        pycoQC -f "${seq_summary}" \
            -v \
            -a $total_bam \
            --min_pass_qual $quality_score \
            -o "./${id}_pycoqc.html" \
            -j "./${id}_pycoqc.json"
        """
}

