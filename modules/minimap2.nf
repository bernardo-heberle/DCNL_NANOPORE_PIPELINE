process MINIMAP2_cDNA {

    publishDir "results/${params.out_dir}/mapping_cDNA/", pattern: "*.ba*", mode: "copy", overwrite: true
    publishDir "results/${params.out_dir}/multiQC_input/minimap2/", pattern: "*.*stat", mode: "copy", overwrite: true

    label 'large'

    input:
        val(id)
        path(fastq)
        file(index)
        val(txt)

    output:
        val("$id"), emit: id
        path("$fastq"), emit: fastq
        path("${id}.bam"), emit: bam
        path("${id}.bam.bai"), emit: bai
        path("${id}*stat"), emit: QC_out
        val("$txt"), emit: txt
        env(NUM_READS), emit: num_reads

    script:
        """
        minimap2 -t 50 -ax splice \
            -uf \
            $index \
            $fastq > "${id}_all.bam" \
     

        samtools sort -@ -12 "${id}_all.bam" -o "${id}.bam" 
        samtools index "${id}.bam"
        samtools flagstat "${id}.bam" > "${id}.flagstat"
        samtools idxstats "${id}.bam" > "${id}.idxstat"
        
        NUM_READS=\$(samtools view -F 0x40 "${id}.bam" | cut -f1 | sort | uniq | wc -l)

        rm "${id}_all.bam"
        """

}

process MINIMAP2_dRNA {

    publishDir "results/${params.out_dir}/mapping_dRNA/", pattern: "*.ba*", mode: "copy", overwrite: true
    publishDir "results/${params.out_dir}/multiQC_input/minimap2/", pattern: "*.*stat", mode: "copy", overwrite: true

    label 'large'

    input:
        tuple val(id), path(fastq)
        file(index)
        val(txt)

    output:
        val("$id"), emit: id
        path("$fastq"), emit: fastq
        path("${id}.bam"), emit: bam
        path("${id}.bam.bai"), emit: bai
        path("${id}*stat"), emit: QC_out
        val("${txt}"), emit: txt
        env(NUM_READS), emit: num_reads

    script:
        """
        
        minimap2 -t 50 -ax splice \
            -k14 -uf \
            $index \
            $fastq > "${id}_all.bam" \


        samtools sort -@ -12 "${id}_all.bam" -o "${id}.bam"
        samtools index "${id}.bam"
        samtools flagstat "${id}.bam" > "${id}.flagstat"
        samtools idxstats "${id}.bam" > "${id}.idxstat"

        NUM_READS=\$(samtools view -F 0x40 "${id}.bam" | cut -f1 | sort | uniq | wc -l)

        rm "${id}_all.bam"
        """

}


process FILTER_BAM {

    publishDir "results/${params.out_dir}/bam_filtering/", mode: "copy", pattern: "*.*stat"
    
    label 'medium_small'

    input:
        val(id)
        val(mapq)
        path(bam)
        path(bai)

    output:
        val("$id"), emit: id
        path("${id}_filtered_mapq_${mapq}.bam"), emit: bam
        path("${id}_filtered_mapq_${mapq}.bam.bai"), emit: bai
        path("*.*stat"), emit: QC

    script:
        """
        
        samtools view -b -q $mapq -F 2304 -@ 12 $bam > 'intermediate.bam'
        samtools sort -@ 12 "intermediate.bam" -o '${id}_filtered_mapq_${mapq}.bam'
        samtools index '${id}_filtered_mapq_${mapq}.bam'
        samtools flagstat "${id}_filtered_mapq_${mapq}.bam" > "${id}_filtered_mapq_${mapq}.flagstat"
        samtools idxstats "${id}_filtered_mapq_${mapq}.bam" > "${id}_filtered_mapq_${mapq}.idxstat"

        rm "intermediate.bam"
        """

}



process FILTER_BAM_ONLY {

    publishDir "results/${params.out_dir}/bam_filtering/", mode: "copy", pattern: "*.*stat"

    label 'medium_small'

    input:
        tuple val(id), path(bam)
        val(bai)
        val(mapq)

    output:
        val("$id"), emit: id
        path("${id}_filtered_mapq_${mapq}.bam"), emit: bam
        path("${id}_filtered_mapq_${mapq}.bam.bai"), emit: bai
        path("*.*stat"), emit: QC

    script:
        """

        samtools view -b -q $mapq -F 2304 -@ 12 $bam > 'intermediate.bam'
        samtools sort -@ 12 "intermediate.bam" -o '${id}_filtered_mapq_${mapq}.bam'
        samtools index '${id}_filtered_mapq_${mapq}.bam'
        samtools flagstat "${id}_filtered_mapq_${mapq}.bam" > "${id}_filtered_mapq_${mapq}.flagstat"
        samtools idxstats "${id}_filtered_mapq_${mapq}.bam" > "${id}_filtered_mapq_${mapq}.idxstat"

        rm "intermediate.bam"
        """

}
