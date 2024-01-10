process BAMBU_PREP {

    publishDir "results/${params.out_dir}/", mode: "copy", overwrite: true

    label 'bambu_prep_job'

    input:
        val(id)
        val(mapq)
        path(bam)
        path(bai)
        path(ref)
        path(gtf)
        path(fai)
        val(track_reads)

    output:
        path("bambu_prep/*.rds")

    script:
        """
        mkdir -p bambu_prep

        bambu_prep.R $bam $ref $gtf $track_reads

        mv ./bambu_prep/*.rds "./bambu_prep/${id}_mapq_${mapq}.rds"
        """
}

process BAMBU_DISCOVERY {

    publishDir "results/${params.out_dir}/", mode: "copy", overwrite: true

    label 'huge_long'

    input:
        path(rc_files)
        path(ref)
        path(gtf)
        path(fai)
        val(NDR)
        val(track_reads)
        

    output:
        path("./bambu_discovery/extended_annotations.gtf"), emit:gtf
        path("bambu_discovery/*"), emit: outty

    shell:
        '''
        mkdir bambu_discovery

        dummy="!{rc_files}"

        rc_files2="$(tr ' ' ',' <<<$dummy)"
    
        bambu_discovery.R $rc_files2 "!{ref}" "!{gtf}" "!{NDR}" "!{track_reads}"
        '''
}


process BAMBU_QUANT {

    publishDir "results/${params.out_dir}/", mode: "copy", overwrite: true

    label 'huge_long'

    input:
        path(rc_files)
        path(ref)
        path(gtf)
        path(fai)
        

    output:
        path("./bambu_quant/extended_annotations.gtf"), emit:gtf
        path("bambu_quant/*"), emit: outty

    shell:
        '''
        mkdir bambu_quant

        dummy="!{rc_files}"

        rc_files2="$(tr ' ' ',' <<<$dummy)"
    
        bambu_quant.R $rc_files2 "!{ref}" "!{gtf}"
        '''
}
