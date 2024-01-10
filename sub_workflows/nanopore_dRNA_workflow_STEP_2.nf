// Import Modules
include {MAKE_FAI} from '../modules/make_fai'
include {MAKE_INDEX_dRNA ; MAKE_INDEX_dRNA_CONTAMINATION_CHM13} from '../modules/make_index'
include {MAKE_INDEX_dRNA as MAKE_INDEX_CONTAMINANTS} from '../modules/make_index'
include {CHM13_GTF; CHM13_GTF_ERCC} from '../modules/chm13_gff3_to_gtf'
include {PYCOQC_dRNA} from '../modules/pycoqc'
include {MINIMAP2_dRNA; FILTER_BAM} from '../modules/minimap2'
include {RSEQC} from '../modules/rseqc'
include {BAMBU_PREP} from '../modules/bambu'
include {MAP_CONTAMINATION_dRNA} from '../modules/contamination'
include {MAKE_CONTAMINATION_REPORT_1} from '../modules/make_contamination_report.nf'
include {TRIM_dRNA} from '../modules/trim_dRNA.nf'
include {CONVERT_U_TO_T} from '../modules/convert_U_to_T.nf'
include {MAKE_QC_REPORT} from '../modules/num_reads_report.nf'

workflow NANOPORE_dRNA_STEP_2 {

    take:
        ref
        annotation
        housekeeping
        ont_reads_txt
        ont_reads_fq
        ercc
        cdna_kit
        track_reads
        mapq
        contamination_ref
        quality_score

    main:
        MAKE_FAI(ref)
        MAKE_INDEX_dRNA(ref)
        CONVERT_U_TO_T(ont_reads_fq, ont_reads_txt, quality_score)
        

        if (params.trim_dRNA == true) { 
            
            TRIM_dRNA(CONVERT_U_TO_T.out.fastq, CONVERT_U_TO_T.out.txt)
            MINIMAP2_dRNA(TRIM_dRNA.out.fastq,  MAKE_INDEX_dRNA.out, TRIM_dRNA.out.txt)

        } else {
    
            MINIMAP2_dRNA(CONVERT_U_TO_T.out.fastq,  MAKE_INDEX_dRNA.out, CONVERT_U_TO_T.out.txt)
    
        }
       

        FILTER_BAM(MINIMAP2_dRNA.out.id, mapq, MINIMAP2_dRNA.out.bam, MINIMAP2_dRNA.out.bai)
        

        if (params.contamination_ref != "None") {
      
            MAKE_INDEX_CONTAMINANTS(contamination_ref)

            MAKE_INDEX_dRNA_CONTAMINATION_CHM13()
                  
            BAM_AND_INDEX = MINIMAP2_dRNA.out.bam.combine(MAKE_INDEX_CONTAMINANTS.out).combine(MAKE_INDEX_dRNA_CONTAMINATION_CHM13.out)
                              
            MAP_CONTAMINATION_dRNA(MINIMAP2_dRNA.out.id, BAM_AND_INDEX, MINIMAP2_dRNA.out.bai, MINIMAP2_dRNA.out.num_reads)
        
            MAKE_CONTAMINATION_REPORT_1(MAP_CONTAMINATION_dRNA.out.id, MAP_CONTAMINATION_dRNA.out.num_reads, MAP_CONTAMINATION_dRNA.out.num_unmapped_reads_before_chm13,
            MAP_CONTAMINATION_dRNA.out.num_unmapped_reads_after_chm13, MAP_CONTAMINATION_dRNA.out.num_contaminant_reads)
        
        }
        
        if ((params.ont_reads_txt != "None") || (params.path != "None")) {
           
            PYCOQC_dRNA(MINIMAP2_dRNA.out.id, MINIMAP2_dRNA.out.fastq, MINIMAP2_dRNA.out.txt, MINIMAP2_dRNA.out.bam, MINIMAP2_dRNA.out.bai,
                         quality_score, mapq, FILTER_BAM.out.QC)
            
            MAKE_QC_REPORT(PYCOQC_dRNA.out.num_reads_report, quality_score)

        }

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

        else
        {
            RSEQC(FILTER_BAM.out.id, FILTER_BAM.out.bam, FILTER_BAM.out.bai, housekeeping)
        }
       
        BAMBU_PREP(FILTER_BAM.out.id, mapq, FILTER_BAM.out.bam, FILTER_BAM.out.bai, ref, annotation, MAKE_FAI.out, track_reads)

}
