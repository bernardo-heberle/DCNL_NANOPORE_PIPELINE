// Import Modules
include {MAKE_FAI} from '../modules/make_fai.nf'
include {CHM13_GTF; CHM13_GTF_ERCC} from '../modules/chm13_gff3_to_gtf'
include {FILTER_BAM_ONLY} from '../modules/minimap2'
include {BAMBU_PREP} from '../modules/bambu'

workflow NANOPORE_STEP_2_BAM {

    take:
        ref
        annotation
        bam
        bai
        ercc
        track_reads
        mapq

    main:
        
        MAKE_FAI(ref)

        FILTER_BAM_ONLY(bam, bai, mapq)
        
        if (params.is_chm13 == true)
        {
            if (params.ercc == "None") 
            { 
                CHM13_GTF(annotation)
                annotation = CHM13_GTF.out.collect()
            }
            
            else 
            {
                CHM13_GTF_ERCC(annotation, ercc)
                annotation = CHM13_GTF_ERCC.out.collect()
            }
        }

        BAMBU_PREP(FILTER_BAM_ONLY.out.id, mapq, FILTER_BAM_ONLY.out.bam, FILTER_BAM_ONLY.out.bai, ref, annotation, MAKE_FAI.out, track_reads)

}
