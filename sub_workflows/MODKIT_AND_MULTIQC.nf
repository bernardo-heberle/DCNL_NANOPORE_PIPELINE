// Import Modules

include {MULTIQC} from '../modules/multiqc.nf'
include {MODKIT} from '../modules/modkit.nf'

workflow MODKIT_AND_MULTIQC {
        
    take:
        pod5_path
        fast5_path

    main:


    PYCOQC(bams, txts, quality_score)
    FILTER_BAM(bams, mapq)


}
