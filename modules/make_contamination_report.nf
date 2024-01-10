process MAKE_CONTAMINATION_REPORT_1 {

    publishDir "results/${params.out_dir}/intermediate_qc_reports/contamination/", mode: "copy", pattern: "*.tsv"   

    label 'small'

    input:
        val(id)
        val(num_reads)
        val(num_unmapped_reads_before_chm13)
        val(num_unmapped_reads_after_chm13)
        val(num_contaminant_reads)

    output:
        path("*.tsv")

    shell:
        '''
        
        reads="!{num_reads}"
        unmapped_reads_before_chm13="!{num_unmapped_reads_before_chm13}"
        unmapped_reads_after_chm13="!{num_unmapped_reads_after_chm13}"
        mapped_to_contaminant="!{num_contaminant_reads}"
        ID="!{id}"
        
        mapped_chm13=$(awk -v var1=$unmapped_reads_before_chm13 -v var2=$unmapped_reads_after_chm13 'BEGIN { print  ( var1 - var2 ) }')
        mapped_to_target=$(awk -v var1=$unmapped_reads_before_chm13 -v var2=$reads 'BEGIN { print  ( var2 - var1 ) }')
        unmapped=$(awk -v var1=$unmapped_reads_after_chm13 -v var2=$mapped_to_contaminant 'BEGIN { print  ( var2 - var1 ) }')

        echo "${ID}\t${mapped_to_target}\t${mapped_chm13}\t${mapped_to_contaminant}\t${unmapped}" > "${ID}.tsv"
        '''

}

process MAKE_CONTAMINATION_REPORT_2 {

    publishDir "results/${params.out_dir}/multiQC_input/contamination/", mode: "copy", pattern: "*"

    label 'small'

    input:
        path(report)

    output:
        path("*")

    script:
        """
        
        echo "Sample ID\tMapped to Target\tMapped to CHM13\tMapped to Contaminant\tUnmapped" >> "Percent_Contaminant_Reads_mqc.tsv"
        cat $report >> "Percent_Contaminant_Reads_mqc.tsv"

        """

}

