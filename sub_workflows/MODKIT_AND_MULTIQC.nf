// Import Modules

include {MULTIQC} from '../modules/multiqc.nf'
include {MODKIT} from '../modules/modkit.nf'
include {MERGE_QC_REPORT} from '../modules//num_reads_report.nf'

workflow MODKIT_AND_MULTIQC {
        
    take:
        filtered_bams
        filtered_bais
        num_reads
        read_length
        quality_thresholds
        multiqc_config
        multiqc_input



    main:

        MERGE_QC_REPORT(num_reads.collect(), read_length.collect(), quality_thresholds.collect())
        
        MULTIQC(multiqc_input.concat(MERGE_QC_REPORT.out.flatten()).collect(), multiqc_config)
        
        MODKIT(filtered_bams, filtered_bais)

}
