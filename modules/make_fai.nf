process MAKE_FAI {

    publishDir "results/${params.out_dir}/fai/", mode: "copy", overwrite: true

    label 'tiny'

    input:
        path ref

    output:
        path '*.fai'

    script:
        """
        samtools faidx $ref
        """
}
