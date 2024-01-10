process MAP_CONTAMINATION_cDNA {

    publishDir "results/${params.out_dir}/contamination_report/${id}", mode: "copy", pattern: "*"

    label 'contamination'

    input:
        val(id)
        tuple path(bam), path(index_contaminants), path(index_chm13)
        path(bai)
        val(num_reads)

    output:
        val("$id"), emit: id
        val("$num_reads"), emit: num_reads
        env(NUM_UNMAPPED_READS_BEFORE_CHM13), emit: num_unmapped_reads_before_chm13
        env(NUM_UNMAPPED_READS_AFTER_CHM13), emit: num_unmapped_reads_after_chm13
        env(NUM_CONTAMINANT_READS), emit: num_contaminant_reads
        path("${id}*"), emit: outty

    script:
        """
        samtools view -h -b -f 4 "${bam}" > "${id}_unmapped.bam"
        samtools fastq "${id}_unmapped.bam" > "${id}_unmapped_reads.fastq"

        NUM_UNMAPPED_READS_BEFORE_CHM13=\$(samtools view -F 0x40 "${id}_unmapped.bam" | cut -f1 | sort | uniq | wc -l)
        
         minimap2 -t 50 -ax splice \
            -uf \
            $index_chm13 \
            "${id}_unmapped_reads.fastq" > "${id}_chm13.bam" 


        samtools view -h -b -f 4 "${id}_chm13.bam" > "${id}_unmapped_chm13.bam"
        samtools fastq "${id}_unmapped_chm13.bam" > "${id}_unmapped_reads_chm13.fastq"
        NUM_UNMAPPED_READS_AFTER_CHM13=\$(samtools view -F 0x40 "${id}_unmapped_chm13.bam" | cut -f1 | sort | uniq | wc -l)

        minimap2 -t 50 -ax splice \
            --split-prefix /tmp/tmp_name \
            -uf \
            $index_contaminants \
            "${id}_unmapped_reads_chm13.fastq" > "${id}_contaminants_unsorted.bam" 

        samtools view -b -F 260 "${id}_contaminants_unsorted.bam" > "${id}_contaminants_unsorted_primary.bam"
        samtools sort -@ 12 "${id}_contaminants_unsorted_primary.bam" -o "${id}_contaminants_sorted_primary.bam"
        samtools index "${id}_contaminants_sorted_primary.bam"

        samtools idxstat "${id}_contaminants_sorted_primary.bam" > "tmp.tsv"
        awk '{print \$1,\$3}' "tmp.tsv" > "tmp2.tsv"
        sort -k2nr "tmp2.tsv" > "${id}_number_of_mapped_reads_per_contaminant.tsv"

        NUM_CONTAMINANT_READS=\$(samtools view -F 0x40 "${id}_contaminants_sorted_primary.bam" | cut -f1 | sort | uniq | wc -l)

        rm "${id}_contaminants_unsorted.bam" "${id}_unmapped.bam" "${id}_contaminants_unsorted_primary.bam" "tmp.tsv" "tmp2.tsv" "${id}_chm13.bam" "${id}_unmapped_chm13.bam" "${id}_unmapped_reads_chm13.fastq"
        """

}

process MAP_CONTAMINATION_dRNA {

    publishDir "results/${params.out_dir}/contamination_report/${id}", mode: "copy", pattern: "*"

    label 'contamination'

    input:
        val(id)
        tuple path(bam), path(index_contaminants), path(index_chm13)
        path(bai)
        val(num_reads)

    output:
        val("$id"), emit: id
        val("$num_reads"), emit: num_reads
        env(NUM_UNMAPPED_READS_BEFORE_CHM13), emit: num_unmapped_reads_before_chm13
        env(NUM_UNMAPPED_READS_AFTER_CHM13), emit: num_unmapped_reads_after_chm13
        env(NUM_CONTAMINANT_READS), emit: num_contaminant_reads
        path("${id}*"), emit: outty

    script:
         """
        samtools view -h -b -f 4 "${bam}" > "${id}_unmapped.bam"
        samtools fastq "${id}_unmapped.bam" > "${id}_unmapped_reads.fastq"

        NUM_UNMAPPED_READS_BEFORE_CHM13=\$(samtools view -F 0x40 "${id}_unmapped.bam" | cut -f1 | sort | uniq | wc -l)
        
         minimap2 -t 50 -ax splice \
            -k14 -uf \
            $index_chm13 \
            "${id}_unmapped_reads.fastq" > "${id}_chm13.bam" 


        samtools view -h -b -f 4 "${id}_chm13.bam" > "${id}_unmapped_chm13.bam"
        samtools fastq "${id}_unmapped_chm13.bam" > "${id}_unmapped_reads_chm13.fastq"
        NUM_UNMAPPED_READS_AFTER_CHM13=\$(samtools view -F 0x40 "${id}_unmapped_chm13.bam" | cut -f1 | sort | uniq | wc -l)

        minimap2 -t 50 -ax splice \
            --split-prefix /tmp/tmp_name \
            -k14 -uf \
            $index_contaminants \
            "${id}_unmapped_reads_chm13.fastq" > "${id}_contaminants_unsorted.bam" 

        samtools view -b -F 260 "${id}_contaminants_unsorted.bam" > "${id}_contaminants_unsorted_primary.bam"
        samtools sort -@ 12 "${id}_contaminants_unsorted_primary.bam" -o "${id}_contaminants_sorted_primary.bam"
        samtools index "${id}_contaminants_sorted_primary.bam"

        samtools idxstat "${id}_contaminants_sorted_primary.bam" > "tmp.tsv"
        awk '{print \$1,\$3}' "tmp.tsv" > "tmp2.tsv"
        sort -k2nr "tmp2.tsv" > "${id}_number_of_mapped_reads_per_contaminant.tsv"

        NUM_CONTAMINANT_READS=\$(samtools view -F 0x40 "${id}_contaminants_sorted_primary.bam" | cut -f1 | sort | uniq | wc -l)

        rm "${id}_contaminants_unsorted.bam" "${id}_unmapped.bam" "${id}_contaminants_unsorted_primary.bam" "tmp.tsv" "tmp2.tsv" "${id}_chm13.bam" "${id}_unmapped_chm13.bam" "${id}_unmapped_reads_chm13.fastq"
        """

   

}
