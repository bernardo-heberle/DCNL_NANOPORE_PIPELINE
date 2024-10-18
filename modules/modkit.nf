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
       
	echo "starting modkit"
 
        ## Make Methylation TSV file
        modkit extract --queue-size 1000 -t 4 -i 10000 "${bam}" "${id}_modkit_output.tsv" --read-calls "${id}_modkit_calls.tsv"

	echo "extract successful"
	
        ## Make Methylation Table
        modkit pileup -t 4 -i 10000 --chunk-size 4 "${bam}" "${id}_modkit_pileup.bed" --log-filepath "${id}_modkit_pileup.log"

	echo "pileup successful"

        ## Make Summary
        modkit summary -i 10000 ${bam}  > "${id}_modkit_summary.txt"
	
	echo "summary successful"

        """

}

