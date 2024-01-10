process MAKE_INDEX_cDNA {

    label 'large'

    input:
        path(ref)

    output:
        path("${ref}.mmi")


    script:
        """
        minimap2 -t 8 -ax splice -uf -d "${ref}.mmi" $ref
        """
}

process MAKE_INDEX_dRNA {

    label 'large'

    input:
        path(ref)

    output:
        path("${ref}.mmi")


    script:
        """
        minimap2 -t 8 -k14 -ax splice -uf -d "${ref}.mmi" $ref
        """
}


process MAKE_INDEX_cDNA_CONTAMINATION_CHM13 {

    label 'large'

    output:
        path("chm13v2.0.mmi")


    script:
        """

        wget https://s3-us-west-2.amazonaws.com/human-pangenomics/T2T/CHM13/assemblies/analysis_set/chm13v2.0.fa.gz

        gzip -d chm13v2.0.fa.gz

        minimap2 -t 8 -ax splice -uf -d "chm13v2.0.mmi" "chm13v2.0.fa"
        """
}

process MAKE_INDEX_dRNA_CONTAMINATION_CHM13 {

    label 'large'

    output:
        path("chm13v2.0.mmi")


    script:
        """

        wget https://s3-us-west-2.amazonaws.com/human-pangenomics/T2T/CHM13/assemblies/analysis_set/chm13v2.0.fa.gz

        gzip -d chm13v2.0.fa.gz

        minimap2 -t 8 -k14 -ax splice -uf -d "chm13v2.0.mmi" "chm13v2.0.fa"
        """
}
