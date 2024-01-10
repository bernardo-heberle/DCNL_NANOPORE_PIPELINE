process UNZIP_AND_CONCATENATE {

    publishDir "results/${params.out_dir}/concatenated_fastq_and_sequencing_summary_files/", mode: 'copy', overwrite: true, pattern: "*.fastq"
    
    label "medium"

    input:
        tuple val(id), file(reads)

    output:
        tuple val("$id"), path("${id}.fastq")

    script:
    """

        find -L . -maxdepth 1 -name "*.fastq.gz" | parallel -j 16 'gunzip --keep --force {}'
        
        find . -type f -maxdepth 1 -name "*.fastq" ! -name "${id}.fastq" -exec cat {} \\; >> "${id}.fastq"

        find . -maxdepth 1 -type f -name "*.fastq" ! -name "${id}.fastq" -exec rm {} \\;
    
    """
}

process FIX_SEQUENCING_SUMMARY_NAME {

    publishDir "results/${params.out_dir}/concatenated_fastq_and_sequencing_summary_files/", mode: 'copy', overwrite: true, pattern: "*.txt"

    label "small"

    input: 
        tuple val(id), file(txt)

    output:
        path "${id}.txt"

    script:
    """
    
        mv $txt "${id}.txt"
    
    """

}
