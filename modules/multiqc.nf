process MULTIQC {

    publishDir "${params.steps_2_and_3_input_directory}/multiQC_output", mode: "copy", overwrite: true

    label 'cpu'

    input:
        path(multiqc_input)
        path(multiqc_config)
    
    output: 
       path "*"

    script:
        """    
        multiqc -c $multiqc_config -n multiQC_report.html .
        """
}
