// Import Modules

include {MULTIQC} from '../modules/multiqc.nf'
include {MODKIT} from '../modules/modkit.nf'
include {MERGE_QC_REPORT} from '../modules//num_reads_report.nf'
include {CALCULATE_COVERAGE; MERGE_COVERAGE} from "../modules/calculate_coverage.nf"

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

	CALCULATE_COVERAGE(filtered_bams, filtered_bais)

	MERGE_COVERAGE(CALCULATE_COVERAGE.out.collect())

        MERGE_QC_REPORT(num_reads.collect(), read_length.collect(), quality_thresholds.collect())
        
        MULTIQC(multiqc_input.concat(MERGE_QC_REPORT.out.flatten()).collect(), MERGE_COVERAGE.out.mqc, multiqc_config)
        
        MODKIT(filtered_bams, filtered_bais)

}
