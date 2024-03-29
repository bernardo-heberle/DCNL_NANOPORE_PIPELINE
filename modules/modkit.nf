process MODKIT {

    publishDir "${params.steps_2_and_3_input_directory}/modkit/", mode: "copy", pattern: "*", overwrite: true
     

    label 'cpu'

    input:
        tuple val(id), path(bam)     
        path(bai)

    output:
        path("*")

    script:
        """
        
        ## Make Methylation TSV file
        modkit extract "${bam}" "${id}_modkit_output.tsv" --read-calls "${id}_modkit_calls.tsv"

        ## Make Methylation Table
        modkit pileup -t 12 "${bam}" "${id}_modkit_pileup.bed" --log-filepath "${id}_modkit_pileup.log"

        ## Make Summary
        modkit summary ${bam} --no-sampling > "${id}_modkit_summary.txt"


        """

}

