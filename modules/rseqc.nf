process RSEQC {

    publishDir "results/${params.out_dir}/multiQC_input/RseQC/", mode: "copy", overwrite: true, pattern: "*geneBody*"

 
    label "medium_large"

    input:
        val(id)
        path(bam)
        path(bai)
        path(housekeeping)

    output:
        path "*geneBody*", emit: multiQC

    script:
        """
        geneBody_coverage.py -i $bam -r $housekeeping -o "${id}_geneBody_coverage"
        """
}
