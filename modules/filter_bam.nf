process FILTER_BAM {

    publishDir "results/${params.out_dir}/bam_filtering/", mode: "copy", pattern: "*"
    
    label 'medium_small'

    input:
        path(bam)
	val(mapq)

    output:
        path("*")

    script:
        """
	
        file="${bam}"
        id="\${file%%.*}"
	
	samtools index "${bam}"

	samtools flagstat "${bam}" > "\${id}.flagstat"
        samtools idxstats "${bam}" > "\${id}.idxstat"      

        samtools view -b -q $mapq -F 2304 -@ 12 $bam > 'intermediate.bam'
        samtools sort -@ 12 "intermediate.bam" -o '\${id}_primary_mapq_${mapq}.bam'
        samtools index '\${id}_primary_mapq_${mapq}.bam'
        samtools flagstat "\${id}_primary_mapq_${mapq}.bam" > "\${id}_f_mapq_${mapq}.flagstat"
        samtools idxstats "\${id}_primary_mapq_${mapq}.bam" > "\${id}_filtered_mapq_${mapq}.idxstat"

        rm "intermediate.bam"
	rm "*.bai"

        """

}

