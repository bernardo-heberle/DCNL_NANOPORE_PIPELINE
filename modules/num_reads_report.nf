process MAKE_QC_REPORT {
    
    publishDir "results/${params.out_dir}/intermediate_qc_reports/number_of_reads/", pattern: "*num_reads.tsv", mode: "copy", overwrite: true
    publishDir "results/${params.out_dir}/intermediate_qc_reports/read_length/", pattern: "*length.tsv", mode: "copy", overwrite: true
    publishDir "results/${params.out_dir}/intermediate_qc_reports/quality_score_thresholds/", pattern: "*thresholds.tsv", mode: "copy", overwrite: true
    
    label 'cpu'

    input:
        val(id)
        path(unfiltered_flagstat)
        path(filtered_flagstat)
        path(unfiltered_pyco_json)
        path(filtered_pyco_json)
        val(mapq)
        val(qscore_thresh)

    output:
        path("${id}_num_reads.tsv"), emit: num_reads
        path("${id}_read_length.tsv"), emit: read_length
        path("${id}_quality_thresholds.tsv"), emit: qscore_thresh

    script:
        """
        num_all_reads=\$(jq '.["All Reads"].basecall.reads_number' "${unfiltered_pyco_json}")
 
        num_pass_reads=\$(jq '.["Pass Reads"].basecall.reads_number' "${unfiltered_pyco_json}") 
      
        num_primary_alignments=\$(grep "primary mapped" "${unfiltered_flagstat}" | awk {'print \$1}')

        num_primary_alignments_filtered=\$(grep "primary mapped" "${filtered_flagstat}" | awk '{print \$1}')
       
        N50_fastq_all=\$(jq '.["All Reads"].basecall.N50' "${unfiltered_pyco_json}")

        median_read_length_fastq_all=\$(jq '.["All Reads"].basecall.len_percentiles[50]' "${unfiltered_pyco_json}")
        
        N50_fastq_pass=\$(jq '.["Pass Reads"].basecall.N50' "${unfiltered_pyco_json}")

        median_read_length_fastq_pass=\$(jq '.["Pass Reads"].basecall.len_percentiles[50]' "${unfiltered_pyco_json}")

        N50_alignment_unfiltered=\$(jq '.["All Reads"].alignment.N50' "${unfiltered_pyco_json}")
       
        median_read_length_alignment_unfiltered=\$(jq '.["All Reads"].alignment.len_percentiles[50]' "${unfiltered_pyco_json}")
       
        N50_alignment_filtered=\$(jq '.["All Reads"].alignment.N50' "${filtered_pyco_json}")
       
        median_read_length_alignment_filtered=\$(jq '.["All Reads"].alignment.len_percentiles[50]' "${filtered_pyco_json}")
        
        echo "${id}\t\${num_all_reads}\t\${num_pass_reads}\t\${num_primary_alignments}\t\${num_primary_alignments_filtered}" > "${id}_num_reads.tsv"
       
        echo "${id}\t\${N50_fastq_all}\t\${median_read_length_fastq_all}\t\${N50_fastq_pass}\t\${median_read_length_fastq_pass}\t\${N50_alignment_unfiltered}\t\${median_read_length_alignment_unfiltered}\t\${N50_alignment_filtered}\t\${median_read_length_alignment_filtered}" > "${id}_read_length.tsv"
       
        echo "${id}\t${qscore_thresh}\t${mapq}" > "${id}_quality_thresholds.tsv"
       
        """

}

process MERGE_QC_REPORT {

    publishDir "${params.steps_2_and_3_input_directory}/reads_report/", pattern: "*", mode: "copy", overwrite: true

    label 'cpu'

    input:
        path(num_reads)
        path(read_length)
        path(qscore_thresh)

    output:
        path("*")

    script:
        """
        
        echo "# plot_type: 'table'" >> "Number_of_Reads_mqc.tsv"
        echo "# id: 'number of reads custom'" >> "Number_of_Reads_mqc.tsv" 
        echo "# section_name: 'Number of reads per sample'" >> "Number_of_Reads_mqc.tsv" 
        echo "Sample_ID\tAll Reads\tPass Reads\tPrimary Alignments\tFiltered Primary Alignments (MAPQ)" >> "Number_of_Reads_mqc.tsv" 
        cat $num_reads >> "Number_of_Reads_mqc.tsv"


        
        echo "# plot_type: 'table'" >> "Read_Length_mqc.tsv"
        echo "# id: 'read length custom'" >> "Read_Length_mqc.tsv" 
        echo "# section_name: 'Read lengths per sample'" >> "Read_Length_mqc.tsv"
        echo "Sample_ID\tN50 All Reads\tMedian Read Length All Reads\tN50 Pass Reads\tMedian Read Length Pass Reads\tN50 Primary Alignments\tMedian Read Length Primary Alignments\tN50 Filtered Primary Alignments\tMedian Read Length Filtered Primary Alignments" >> "Read_Length_mqc.tsv"
        cat $read_length >> "Read_Length_mqc.tsv"


        echo "# plot_type: 'table'" >> "Quality_Thresholds_mqc.tsv"
        echo "# id: 'quality threholds'" >> "Quality_Thresholds_mqc.tsv" 
        echo "# section_name: 'Quality thresholds for each sample'" >> "Quality_Thresholds_mqc.tsv"
        echo "Sample_ID\tRead Mean Base Quality Score Threshold (PHRED)\tMapping Quality Threshold (MAPQ)" >> "Quality_Thresholds_mqc.tsv"
        cat $qscore_thresh >> "Quality_Thresholds_mqc.tsv"
       
        """

}
