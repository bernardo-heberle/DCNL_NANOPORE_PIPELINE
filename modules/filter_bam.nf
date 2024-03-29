process FILTER_BAM {

    publishDir "${params.steps_2_and_3_input_directory}/bam_filtering/", mode: "copy", pattern: "*.ba*", overwrite: true
    publishDir "${params.steps_2_and_3_input_directory}/multiqc_input/minimap2/", mode: "copy", pattern: "*.*stat", overwrite: true
     

    label 'cpu'

    input:
        tuple val(id), path(bam)     
        path(txt)
	val(mapq)

    output:
        val("${id}"), emit: id
        path("*-Unfiltered.bam"), emit: total_bam 
        path("*-Unfiltered.bam.bai"), emit: total_bai
        path("*-Filtered*.bam"), emit: filtered_bam
        path("*-Filtered*.bai"), emit: filtered_bai
        path("*-Unfiltered.flagstat"), emit: unfiltered_flagstat
        path("*-Filtered*.flagstat"), emit: filtered_flagstat
        path("${txt}"), emit: txt
        path("*.*stat"), emit: multiqc

    script:
        """
        
        cp "${bam}" "${id}-Unfiltered.bam"
        samtools index "${id}-Unfiltered.bam"

	samtools flagstat "${id}-Unfiltered.bam" > "${id}-Unfiltered.flagstat"
        samtools idxstats "${id}-Unfiltered.bam" > "${id}-Unfiltered.idxstat"      

        samtools view -b -q $mapq -F 2304 -@ 12 $bam > "intermediate.bam"
        samtools sort -@ 12 "intermediate.bam" -o "${id}-Filtered_primary_mapq_${mapq}.bam"
        samtools index "${id}-Filtered_primary_mapq_${mapq}.bam"
        samtools flagstat "${id}-Filtered_primary_mapq_${mapq}.bam" > "${id}-Filtered_primary_mapq_${mapq}.flagstat"
        samtools idxstats "${id}-Filtered_primary_mapq_${mapq}.bam" > "${id}-Filtered_primary_mapq_${mapq}.idxstat"

        rm "intermediate.bam"

        """

}

