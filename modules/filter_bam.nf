process FILTER_BAM {

    publishDir "results/${params.out_dir}/bam_filtering/", mode: "copy", pattern: "*.ba*", overwrite: true
    publishDir "results/${params.out_dir}/multiqc_input/minimap2/", mode: "copy", pattern: "*.*stat", overwrite: true
     

    label 'cpu'

    input:
        tuple val(id), path(bam)     
        path(txt)
	val(mapq)

    output:
        env(id), emit: id, optional: true
        path("*-Unfiltered.bam"), emit: total_bam, optional: true 
        path("*-Unfiltered.bam.bai"), emit: total_bai, optional: true
        path("*-Filtered*.bam"), emit: filtered_bam, optional: true
        path("*-Filtered*.bai"), emit: filtered_bai, optional: true
        path("*-Unfiltered.flagstat"), emit: unfiltered_flagstat, optional: true
        path("*-Filtered*.flagstat"), emit: filtered_flagstat, optional: true
        path("*_sequencing_summary*"), emit: txt, optional: true
        path("*.*stat"), emit: multiqc, optional: true

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


	var=\$(awk 'NR==8 {print \$1}' "${id}-Filtered_primary_mapq_${mapq}.flagstat")	

	## If flagstat file says there are no mapped reads then delete bam and bai files.
        ## Since we passed optional on the output statement lines the script should still run fine even
	## When the files are deleted. However, I never used optional before so I am not 100% sure
	if [ \$var -lt "${params.min_mapped_reads_thresh}" ]; then
 		rm ${id}-*
	else
        	id="${id}"
		cp "${txt}" "${id}_sequencing_summary.txt"
        fi

        rm "intermediate.bam"

        """

}

