// Make this pipeline a nextflow 2 implementation
nextflow.enable.dsl=2

if (params.step == 1) {

log.info """
                            OXFORD NANOPORE cDNA/dRNA SEQUENCING PIPELINE - STEP 1: BASECALLING - Bernardo Aguzzoli Heberle - EBBERT LAB - University of Kentucky
======================================================================================================================================================================================
 path containing samples and files to be basecalled (basecall only)             : ${params.basecall_path}
 basecall speed (basecall only)                                                 : ${params.basecall_speed}
 basecall modifications  (basecall only)                                        : ${params.basecall_mods}
 basecall config (If "None" the basecaller will automatically pick one)         : ${params.basecall_config}
 basecall read trimming option                                                  : ${params.basecall_trim}
 basecall quality score threshold for basecalling                               : ${params.qscore_thresh}
 basecall demultiplexing                                                        : ${params.basecall_demux}
 trim barcodes during demultiplexing                                            : ${params.trim_barcode}
 submission output file prefix                                                  : ${params.prefix}

 step: 1 = basecalling, 2 = mapping, 3 = quantification                         : ${params.step}
 Output directory                                                               : ${params.out_dir}
 =====================================================================================================================================================================================
 
 """
} else if ((params.step == 2) && (params.bam == "None")) {

log.info """
            OXFORD NANOPORE cDNA/dRNA SEQUENCING PIPELINE - STEP 2: QC, Alignment, and Bambu pre-processing - Bernardo Aguzzoli Heberle - EBBERT LAB - University of Kentucky
======================================================================================================================================================================================
 RAW unzipped nanopore fastq.gz file path                                       : ${params.path}

 nanopore fastq files                                                           : ${params.ont_reads_fq}
 nanopore sequencing summary files                                              : ${params.ont_reads_txt}
 submission output file prefix                                                  : ${params.prefix}

 reference genome                                                               : ${params.ref}
 reference annotation                                                           : ${params.annotation}
 housekeeping genes 3' bias assessment                                          : ${params.housekeeping}
 nanopore library prep kit (cDNA only)                                          : ${params.cdna_kit}
 reference genome is CHM13                                                      : ${params.is_chm13}
 path to ERCC annotations (CHM13 only)                                          : ${params.ercc}

 quality score threshold for fastq reads                                        : ${params.qscore_thresh}
 MAPQ value for filtering bam file                                              : ${params.mapq}

 Is this a direct RNAseq dataset?                                               : ${params.is_dRNA}
 Trim dRNA adapters?                                                            : ${params.trim_dRNA}

 Reference for contamination analysis                                           : ${params.contamination_ref}

 step: 1 = basecalling, 2 = mapping, 3 = quantification                         : ${params.step}
 Output directory                                                               : ${params.out_dir}
 =====================================================================================================================================================================================
 
"""

} else if ((params.step == 2) && (params.bam != "None")) {

log.info """
            OXFORD NANOPORE cDNA/dRNA SEQUENCING PIPELINE - STEP 2 - Filtering BAM  - Bernardo Aguzzoli Heberle - EBBERT LAB - University of Kentucky
======================================================================================================================================================================================
 bam files                                                                      : ${params.bam}
 bai files                                                                      : ${params.bai}
 submission output file prefix                                                  : ${params.prefix}

 reference genome                                                               : ${params.ref}
 reference annotation                                                           : ${params.annotation}

 reference genome is CHM13                                                      : ${params.is_chm13}
 path to ERCC annotations (CHM13 only)                                          : ${params.err}


 MAPQ value for filtering bam file                                              : ${params.mapq}


 step: 1 = basecalling, 2 = mapping, 3 = quantification                         : ${params.step}
 Output directory                                                               : ${params.out_dir}
 =====================================================================================================================================================================================
 
"""

} else {

log.info """
            OXFORD NANOPORE cDNA/dRNA SEQUENCING PIPELINE - STEP 3: Transcript Quantification and/or Discovery -  Bernardo Aguzzoli Heberle - EBBERT LAB - University of Kentucky
======================================================================================================================================================================================
 
 reference genome                                                               : ${params.ref}
 reference annotation                                                           : ${params.annotation}
 reference genome is CHM13                                                      : ${params.is_chm13}

 multiqc configuration file                                                     : ${params.multiqc_config}
 multiqc input path                                                             : ${params.multiqc_input} 
 intermediate qc file paths                                                     : ${params.intermediate_qc}

 transcript discovery status                                                    : ${params.is_discovery}
 NDR Value for Bambu (Novel Discovery Rate)                                     : ${params.NDR}
 Track read_ids with bambu?                                                     : ${params.track_reads}
 Path to pre-processed bambu RDS files                                          : ${params.bambu_rds}

 step: 1 = basecalling, 2 = mapping, 3 = quantification                         : ${params.step}
 Output directory                                                               : ${params.out_dir}
 =====================================================================================================================================================================================
 


"""

}



// Import Workflows
include {NANOPORE_UNZIP_AND_CONCATENATE} from '../sub_workflows/nanopore_unzip_and_concatenate.nf'
include {NANOPORE_STEP_1} from '../sub_workflows/nanopore_workflow_STEP_1'
include {NANOPORE_cDNA_STEP_2} from '../sub_workflows/nanopore_cDNA_workflow_STEP_2'
include {NANOPORE_dRNA_STEP_2} from '../sub_workflows/nanopore_dRNA_workflow_STEP_2'
include {NANOPORE_STEP_2_BAM} from '../sub_workflows/nanopore_workflow_STEP_2_BAM'
include {NANOPORE_STEP_3} from '../sub_workflows/nanopore_workflow_STEP_3'


// Define initial files and channels

if (params.prefix == "None") {

    fastq_path = Channel.fromPath("${params.path}/**/fastq_pass/*.fastq.gz").map{file -> tuple("sample_" + file.parent.toString().split("/fastq_pass")[0].split("/")[-2] + "_" + file.simpleName.split('_')[0] + "_" + file.simpleName.split('_')[2..-2].join("_"), file)}.groupTuple()
    txt_path = Channel.fromPath("${params.path}/**/*uencing_summary*.txt").map{file -> tuple("sample_" + file.parent.toString().split("/")[-2] + "_" + file.simpleName.split('_')[2..-1].join("_"), file)}.groupTuple()
    ont_reads_fq = Channel.fromPath(params.ont_reads_fq).map { file -> tuple(file.baseName, file) }
    ont_reads_txt = Channel.fromPath(file(params.ont_reads_txt))
    fast5_path = Channel.fromPath("${params.basecall_path}/**.fast5").map{file -> tuple(file.parent.toString().split("/")[-2] + "_" + file.simpleName.split('_')[0] + "_" + file.simpleName.split('_')[2..-2].join("_"), file) }.groupTuple()
    pod5_path = Channel.fromPath("${params.basecall_path}/**.pod5").map{file -> tuple(file.parent.toString().split("/")[-2] + "_" + file.simpleName.split('_')[0] + "_" + file.simpleName.split('_')[2..-2].join("_"), file) }.groupTuple()
    bam = Channel.fromPath(params.bam).map { file -> tuple(file.baseName, file) }
    bai = Channel.fromPath(params.bai)

} else {

    fastq_path = Channel.fromPath("${params.path}/**/fastq_pass/*.fastq.gz").map{file -> tuple("${params.prefix}_sample_" + file.parent.toString().split("/fastq_pass")[0].split("/")[-2] + "_" + file.simpleName.split('_')[0] + "_" + file.simpleName.split('_')[2..-2].join("_"), file)}.groupTuple()
    txt_path = Channel.fromPath("${params.path}/**/*uencing_summary*.txt").map{file -> tuple("${params.prefix}_sample_" + file.parent.toString().split("/")[-2] + "_" + file.simpleName.split('_')[2..-1].join("_"), file)}.groupTuple()
    ont_reads_fq = Channel.fromPath(params.ont_reads_fq).map { file -> tuple("${params.prefix}_" + file.baseName, file) }
    ont_reads_txt = Channel.fromPath(file(params.ont_reads_txt))
    fast5_path = Channel.fromPath("${params.basecall_path}/**.fast5").map{file -> tuple("${params.prefix}_" + file.parent.toString().split("/")[-2] + "_" + file.simpleName.split('_')[0] + "_" + file.simpleName.split('_')[2..-2].join("_"), file) }.groupTuple()
    pod5_path = Channel.fromPath("${params.basecall_path}/**.pod5").map{file -> tuple("${params.prefix}_" +  file.parent.toString().split("/")[-2] + "_" + file.simpleName.split('_')[0] + "_" + file.simpleName.split('_')[2..-2].join("_"), file) }.groupTuple()
    bam = Channel.fromPath(params.bam).map { file -> tuple("${params.prefix}_" + file.baseName, file) }
    bai = Channel.fromPath(params.bai).map { file -> file.parent.resolve("${params.prefix}_${file.name}") }

}   

ref = file(params.ref)
housekeeping = file(params.housekeeping)
annotation = file(params.annotation)
cdna_kit = Channel.value(params.cdna_kit)
multiqc_config = Channel.fromPath(params.multiqc_config)
NDR = Channel.value(params.NDR)
track_reads = Channel.value(params.track_reads)
mapq = Channel.value(params.mapq)
bambu_rds = Channel.fromPath(params.bambu_rds)
multiqc_input = Channel.fromPath(params.multiqc_input, type: "file")
fai = file(params.fai)
contamination_ref = Channel.fromPath(params.contamination_ref)
quality_score = Channel.value(params.qscore_thresh)
basecall_speed = Channel.value(params.basecall_speed)
basecall_mods = Channel.value(params.basecall_mods)
basecall_config = Channel.value(params.basecall_config)
basecall_trim = Channel.value(params.basecall_trim)
basecall_compute = Channel.value(params.basecall_compute)
trim_barcode = Channel.value(params.trim_barcode)
contamination = Channel.fromPath("${params.intermediate_qc}/contamination/*")
num_reads = Channel.fromPath("${params.intermediate_qc}/number_of_reads/*")
read_length = Channel.fromPath("${params.intermediate_qc}/read_length/*")
quality_thresholds = Channel.fromPath("${params.intermediate_qc}/quality_score_thresholds/*")




if (params.ercc != "None") {
    ercc = Channel.fromPath(params.ercc)
    }
else {
    ercc = params.ercc
    }

if (params.ont_reads_txt == "None") {
    ont_reads_txt = Channel.value(params.ont_reads_txt)
    } else {
    // Make sure ONT sequencing summary and fastq files are in the same order
    ont_reads_txt = ont_reads_txt.toSortedList( { a, b -> a.baseName <=> b.baseName } ).flatten()
    }

if (params.ont_reads_fq != "None") {
    
    // Make sure files are in same order
    ont_reads_fq = ont_reads_fq.toSortedList( { a, b -> a[0] <=> b[0] } ).flatten().buffer(size:2)

    }

if ((params.bam != "None") && (params.bai != "None")) {

    // Make sure bam and bai files are in the correct order
    bam = bam.toSortedList( { a, b -> a[0] <=> b[0] } ).flatten().buffer(size:2)
    bai = bai.toSortedList( { a, b -> a.baseName <=> b.baseName } ).flatten()
    
    }

workflow {

    if ((params.path != "None") && (params.step == 2)) {
        
        NANOPORE_UNZIP_AND_CONCATENATE(fastq_path, txt_path)

        if (params.is_dRNA == false) {

            NANOPORE_cDNA_STEP_2(ref, annotation, housekeeping, NANOPORE_UNZIP_AND_CONCATENATE.out[1], NANOPORE_UNZIP_AND_CONCATENATE.out[0], ercc, cdna_kit, track_reads, mapq, contamination_ref, quality_score)
        
        } else {
        
            NANOPORE_dRNA_STEP_2(ref, annotation, housekeeping, NANOPORE_UNZIP_AND_CONCATENATE.out[1], NANOPORE_UNZIP_AND_CONCATENATE.out[0], ercc, cdna_kit, track_reads, mapq, contamination_ref, quality_score)

        }
    }


    else if (params.step == 1){

        NANOPORE_STEP_1(pod5_path, fast5_path, basecall_speed, basecall_mods, basecall_config, basecall_trim, quality_score, trim_barcode)
    }

    else if ((params.step == 2) && (params.bam == "None") && (params.path == "None")){

        if (params.is_dRNA == false) {
        
            NANOPORE_cDNA_STEP_2(ref, annotation, housekeeping, ont_reads_txt, ont_reads_fq, ercc, cdna_kit, track_reads, mapq, contamination_ref, quality_score)
        }

        else if (params.is_dRNA = true) {

            NANOPORE_dRNA_STEP_2(ref, annotation, housekeeping, ont_reads_txt, ont_reads_fq, ercc, cdna_kit, track_reads, mapq, contamination_ref, quality_score)

        }
    }


    else if ((params.step == 2) && (params.bam != "None") && (params.path == "None")) {
        
        NANOPORE_STEP_2_BAM(ref, annotation, bam, bai, ercc, track_reads, mapq)

    }

    else if(params.step == 3){
        
        NANOPORE_STEP_3(ref, fai, annotation, NDR, track_reads, bambu_rds, multiqc_input, multiqc_config, contamination, num_reads, read_length, quality_thresholds)
    }

}
