process PYCOQC_NO_FILTER {

    publishDir "results/${params.out_dir}/pycoqc_no_filter/", mode: 'copy', overwrite: true, pattern: "*-Unfiltered_pycoqc*"

    label 'cpu'

    input:
        val(id)
        path(total_bam)
        path(total_bai)
        path(filtered_bam)
        path(filtered_bai)
        path(unfiltered_flagstat)
        path(filtered_flagstat)
	path(seq_summary)
        val(quality_score)

    output:
        val("${id}"), emit: id
        path("${filtered_bam}"), emit: filtered_bam
        path("${filtered_bai}"), emit: filtered_bai
        path("${unfiltered_flagstat}"), emit: unfiltered_flagstat
        path("${filtered_flagstat}"), emit: filtered_flagstat
        path("${seq_summary}"), emit: txt
        path("*.html"), emit: unfiltered_pyco_html
        path("*.json"), emit: unfiltered_pyco_json
         

    script:
        """

	
        pycoQC -f "${seq_summary}" \
            -v \
            -a "${total_bam}" \
            --min_pass_qual "${quality_score}" \
            -o "./${id}-Unfiltered_pycoqc.html" \
            -j "./${id}-Unfiltered_pycoqc.json"

        """
}

process PYCOQC_FILTER {


    publishDir "results/${params.out_dir}/pycoqc_filtered/", mode: 'copy', overwrite: true, pattern: "*-Filtered_pycoqc*"

    label 'cpu'

    input:
        val(id)
        path(filtered_bam)
        path(filtered_bai)
        path(unfiltered_flagstat)
        path(filtered_flagstat)
	path(seq_summary)
        val(quality_score)
        path(unfiltered_pyco_json)


    output:
        val("${id}"), emit: id
        path("${unfiltered_flagstat}"), emit: unfiltered_flagstat
        path("${filtered_flagstat}"), emit: filtered_flagstat
        path("${unfiltered_pyco_json}"), emit: unfiltered_pyco_json
        path("*-Filtered*.html"), emit: filtered_pyco_html
        path("*-Filtered*.json"), emit: filtered_pyco_json
         

    script:
        """
	
        pycoQC -f "${seq_summary}" \
            -v \
            -a "${filtered_bam}" \
            --min_pass_qual "${quality_score}" \
            -o "./${id}-Filtered_pycoqc.html" \
            -j "./${id}-Filtered_pycoqc.json"

        """
}
