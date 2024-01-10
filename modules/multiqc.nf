process MULTIQC_GRCh38 {

    publishDir "results/${params.out_dir}/multiQC_output", mode: "copy", overwrite: true

    label 'tiny'

    input:
        path(multiqc_input)
        path(multiqc_config)
        path(contamination)
        path(reads_reports)
    
    output: 
       path "*"

    script:
        """    
        multiqc -c $multiqc_config -n multiQC_report.html .
        """
}

process MULTIQC_CHM13 {

    publishDir "results/${params.out_dir}/multiqc_output", mode: "copy", overwrite: true

    label 'tiny'

    input:
        path(multiqc_input)
        path(multiqc_config)
        path(contamination)
        path(reads_reports)
    
    output: 
        path "*"

    script:
        """    
        multiqc -c $multiqc_config -n multiQC_report.html .
        """
}
