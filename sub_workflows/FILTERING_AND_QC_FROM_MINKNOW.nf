// Import Modules

include {PYCOQC_NO_FILTER ; PYCOQC_FILTER} from '../modules/pycoqc.nf'
include {FILTER_BAM} from '../modules/filter_bam.nf'
include {MAKE_QC_REPORT} from '../modules/num_reads_report.nf'
include {CONVERT_INPUT_FROM_MINKNOW} from '../modules/convert_input_from_minknow.nf' 

workflow FILTERING_AND_QC_FROM_MINKNOW {
        
    take:
        input
        mapq
        quality_score

    main:
	 
    CONVERT_INPUT_FROM_MINKNOW(input)

    FILTER_BAM(CONVERT_INPUT_FROM_MINKNOW.out.bam.flatten().map {file -> tuple(file.baseName, file) }.toSortedList( { a, b -> a[0] <=> b[0] } ).flatten().buffer(size:2),
	CONVERT_INPUT_FROM_MINKNOW.out.txt.toSortedList( { a, b -> a.baseName <=> b.baseName } ).flatten(), mapq)

    PYCOQC_NO_FILTER(FILTER_BAM.out.id, FILTER_BAM.out.total_bam, FILTER_BAM.out.total_bai, FILTER_BAM.out.filtered_bam, 
    FILTER_BAM.out.filtered_bai, FILTER_BAM.out.unfiltered_flagstat, FILTER_BAM.out.filtered_flagstat, FILTER_BAM.out.txt,  quality_score)

    PYCOQC_FILTER(PYCOQC_NO_FILTER.out.id, PYCOQC_NO_FILTER.out.filtered_bam, PYCOQC_NO_FILTER.out.filtered_bai, PYCOQC_NO_FILTER.out.unfiltered_flagstat, 
                    PYCOQC_NO_FILTER.out.filtered_flagstat, PYCOQC_NO_FILTER.out.txt, quality_score, PYCOQC_NO_FILTER.out.unfiltered_pyco_json)

    MAKE_QC_REPORT(PYCOQC_FILTER.out.id, PYCOQC_FILTER.out.unfiltered_flagstat, PYCOQC_FILTER.out.filtered_flagstat, 
                    PYCOQC_FILTER.out.unfiltered_pyco_json, PYCOQC_FILTER.out.filtered_pyco_json, mapq, quality_score)


}
