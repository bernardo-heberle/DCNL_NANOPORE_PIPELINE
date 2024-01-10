process MAKE_QC_REPORT {
    
    publishDir "results/${params.out_dir}/intermediate_qc_reports/number_of_reads/", pattern: "*num_reads.tsv", mode: "copy", overwrite: true
    publishDir "results/${params.out_dir}/intermediate_qc_reports/read_length/", pattern: "*length.tsv", mode: "copy", overwrite: true
    publishDir "results/${params.out_dir}/intermediate_qc_reports/quality_score_thresholds/", pattern: "*thresholds.tsv", mode: "copy", overwrite: true
    
    label 'small'

    input:
        tuple val(id), val(num_trimmed_fastq), val(mapq), path(json), path(flagstat)
        val(qscore_thresh)

    output:
        path("${id}_num_reads.tsv"), emit: num_reads
        path("${id}_read_length.tsv"), emit: read_length
        path("${id}_quality_thresholds.tsv"), emit: qscore_thresh

    script:
        """
        echo "hi"

        reads_number_fastq_all=\$(jq '.["All Reads"].basecall.reads_number' "${json}")
        
        echo "hi"

        reads_number_aligned=\$(jq '.["All Reads"].alignment.reads_number' "${json}")
       
        echo "hi"

        reads_number_aligned_filtered=\$(grep "primary mapped" "${flagstat}" | awk '{print \$1}')
       
        echo "hi"

        N50_fastq=\$(jq '.["All Reads"].basecall.N50' "${json}")
       
        echo "hi"

        median_read_length_fastq=\$(jq '.["All Reads"].basecall.len_percentiles[50]' "${json}")
       
        echo "hi"

        N50_alignment=\$(jq '.["All Reads"].alignment.N50' "${json}")
       
        echo "hi"

        median_read_length_alignment=\$(jq '.["All Reads"].alignment.len_percentiles[50]' "${json}")
       
        echo "hi"

        echo "${id}\t\${reads_number_fastq_all}\t${num_trimmed_fastq}\t\${reads_number_aligned}\t\${reads_number_aligned_filtered}" > "${id}_num_reads.tsv"
       
        echo "hi"

        echo "${id}\t\${N50_fastq}\t\${median_read_length_fastq}\t\${N50_alignment}\t\${median_read_length_alignment}" > "${id}_read_length.tsv"
       
        echo "hi"

        echo "${id}\t${qscore_thresh}\t${mapq}" > "${id}_quality_thresholds.tsv"
       
        echo "hi"
        """

}

process MERGE_QC_REPORT {

    publishDir "results/${params.out_dir}/multiQC_input/reads_report/", pattern: "*", mode: "copy", overwrite: true

    label 'small'

    input:
        path(num_reads)
        path(read_length)
        path(qscore_thresh)

    output:
        path("*")

    script:
        """

        echo "Sample_ID\tAll_Reads\tFiltered_Reads\tAligned_Reads\tFiltered_Aligned_Reads\t" >> "Number_of_Reads_mqc.tsv"
        cat $num_reads >> "Number_of_Reads_mqc.tsv"


        echo "Sample_ID\tN50_FASTQ\tMedian_Read_Length_FASTQ\tN50_BAM\tMedian_Read_Length_BAM\t" >> "Read_Length_mqc.tsv"
        cat $read_length >> "Read_Length_mqc.tsv"


        echo "Sample_ID\tRead_Mean_Base_Quality_Score_Threshold_(PHRED)\tMapping_Quality_Threshold_(MAPQ)" >> "Quality_Thresholds_mqc.tsv"
        cat $qscore_thresh >> "Quality_Thresholds_mqc.tsv"
       
        """

}
