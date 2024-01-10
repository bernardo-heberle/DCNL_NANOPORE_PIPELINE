process CONVERT_U_TO_T {

    label "medium"

    input:
        tuple val(id), file(fastq)
        val(txt) 
        val(qscore)

    output:
        tuple val("$id"), path("${id}_U_to_T_qscore_${qscore}.fastq"), emit: fastq
        path "${id}.txt", emit: txt

    script:
    """
        
        if [[ "${txt}" != "None" ]] &&  [[ "${txt}" != "${id}.txt" ]]; then
            cp "${txt}" "./${id}.txt"
        else
            touch "./${id}.txt"
        fi 
 
        ## convert U to T
        convert_U_to_T.py $fastq "${id}_U_to_T.fastq"

        ## Filter by mean base quality threshold
        filter_by_mean_base_quality.py "${id}_U_to_T.fastq" "${qscore}" "${id}_U_to_T_qscore_${qscore}.fastq"

        ## Delete intermediate files
        rm "${id}_U_to_T.fastq"

    """
}
