// Import Modules

include {PYCOQC_NO_FILTER ; PYCOQC_FILTER} from '../modules/pycoqc.nf'
include {FILTER_BAM} from '../modules/filter_bam.nf'

workflow FILTERING_AND_QC {
        
    take:
        bams
        txts
        mapq

    main:


    PYCOQC_NO_FILTER(bams, txts, quality_score)
    FILTER_BAM(bams, mapq)
    PYCOQC_FILTER(FILTER_BAM.out.)


}
