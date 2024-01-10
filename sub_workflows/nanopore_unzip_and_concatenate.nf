// Import Modules
include {UNZIP_AND_CONCATENATE; FIX_SEQUENCING_SUMMARY_NAME} from '../modules/unzip_and_concatenate.sh'

workflow NANOPORE_UNZIP_AND_CONCATENATE {
        
    take:
        fastq_path
        txt_path
    main:

        UNZIP_AND_CONCATENATE(fastq_path)
        FIX_SEQUENCING_SUMMARY_NAME(txt_path)

        fastq_final = UNZIP_AND_CONCATENATE.out.toSortedList( { a, b -> a[0] <=> b[0] } ).flatten().buffer(size:2)
        txt_final = FIX_SEQUENCING_SUMMARY_NAME.out.toSortedList( { a, b -> a.baseName <=> b.baseName } ).flatten()
        

    emit:
        fastq_final
        txt_final
}
