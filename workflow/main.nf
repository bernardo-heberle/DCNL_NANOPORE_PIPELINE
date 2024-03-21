// Make this pipeline a nextflow 2 implementation
nextflow.enable.dsl=2

println params.step

if (params.step == 1) {
log.info """
                        STEP 1 - OXFORD NANOPORE DNA SEQUENCING BASECALLING AND ALIGNMENT - Bernardo Aguzzoli Heberle
======================================================================================================================================================================================

path containing samples and files to be basecalled (basecall only)             : ${params.basecall_path}
basecall speed (basecall only)                                                 : ${params.basecall_speed}
basecall modifications  (basecall only)                                        : ${params.basecall_mods}
basecall config (If "false" the basecaller will automatically pick one)        : ${params.basecall_config}
basecall read trimming option                                                  : ${params.basecall_trim}
basecall quality score threshold for basecalling                               : ${params.qscore_thresh}
basecall demultiplexing                                                        : ${params.basecall_demux}
trim barcodes during demultiplexing                                            : ${params.trim_barcode}
submission output file prefix                                                  : ${params.prefix}
GPU device for submission							: ${params.gpu_devices}

Output directory                                                               : ${params.out_dir}

======================================================================================================================================================================================
 
 """ 
 } else if (params.step == 2) {

"""
                           STEP 2 - FILTERING AND QUALITY CONTROL - Bernardo Aguzzoli Heberle
======================================================================================================================================================================================

Input directory - should be the Output Directory from step 1                                            : ${params.steps_2_and_3_input_directory}

Basecall quality score threshold for basecalling (make sure it is the same as in step 1)	        : ${params.qscore_thresh}
 
MAPQ filtering threshold							                        : ${params.mapq}

======================================================================================================================================================================================
 
"""


 } else if (params.step == 3) {


"""
                        STEP 3 - METHYLATION CALLING AND MULTIQC REPORT - Bernardo Aguzzoli Heberle
=======================================================================================================================================================================================
 
Input directory - should be the Output Directory from step 1 and Input Directory from step 2           : ${params.steps_2_and_3_input_directory}

MultiQC configuration file (provided, but may need to be altered for different use cases)              : ${params.multiqc_config}


======================================================================================================================================================================================
 
"""



 } else {

    println "ERROR: You must set parameter --step to an integer between 1 and 3" 
    System.exit(1)

 }



// Import Workflows
include {BASECALLING} from '../sub_workflows/BASECALLING'
include {FILTERING_AND_QC} from '../sub_workflows/FILTERING_AND_QC.nf'
include {MODKIT_AND_MULTIQC} from '../sub_workflows/MODKIT_AND_MULTIQC.nf'


// Define initial files and channels

if (params.step == 1) {

    if (params.prefix == "None") {

            fast5_path = Channel.fromPath("${params.basecall_path}/**.fast5").map{file -> tuple(file.parent.toString().split("/")[-2] + "_" + file.simpleName.split('_')[0] + "_" + file.simpleName.split('_')[-3..-2].join("_"), file) }.groupTuple()
        
            pod5_path = Channel.fromPath("${params.basecall_path}/**.pod5").map{file -> tuple(file.parent.toString().split("/")[-2] + "_" + file.simpleName.split('_')[0] + "_" + file.simpleName.split('_')[-3..-2].join("_"), file) }.groupTuple()

    } else {

            fast5_path = Channel.fromPath("${params.basecall_path}/**.fast5").map{file -> tuple("${params.prefix}_" + file.parent.toString().split("/")[-2] + "_" + file.simpleName.split('_')[0] + "_" + file.simpleName.split('_')[-3..-2].join("_"), file) }.groupTuple()

            pod5_path = Channel.fromPath("${params.basecall_path}/**.pod5").map{file -> tuple("${params.prefix}_" +  file.parent.toString().split("/")[-2] + "_" + file.simpleName.split('_')[0] + "_" + file.simpleName.split('_')[-3..-2].join("_"), file) }.groupTuple()

    }   

    ref = file(params.ref)
    quality_score = Channel.value(params.qscore_thresh)
    basecall_speed = Channel.value(params.basecall_speed)
    basecall_mods = Channel.value(params.basecall_mods)
    basecall_config = Channel.value(params.basecall_config)
    basecall_trim = Channel.value(params.basecall_trim)
    basecall_compute = Channel.value(params.basecall_compute)
    trim_barcode = Channel.value(params.trim_barcode)
    devices = Channel.value(params.gpu_devices)

}

else if (params.step == 2) {

    total_bams = Channel.fromPath("${params.steps_2_and_3_input_directory}/basecalling_output/*.bam").toSortedList( { a, b -> a[0] <=> b[0] } ).flatten().buffer(size:2)
    txts = Channel.fromPath("${params.steps_2_and_3_input_directory}/basecalling_output/*.txt").toSortedList( { a, b -> a.baseName <=> b.baseName } ).flatten()
    mapq = Channel.value(params.mapq)
    quality_score = Channel.value(params.qscore_thresh)

}


else if (params.step == 3) {

    
    filtered_bams = Channel.fromPath("${params.steps_2_and_3_input_directory}/bam_filtering/*-Filtered*.bam").toSortedList( { a, b -> a[0] <=> b[0] } ).flatten().buffer(size:2) 
    filtered_bais = Channel.fromPath("${params.steps_2_and_3_input_directory}/bam_filtering/*-Filtered*.bam.bai").toSortedList( { a, b -> a.baseName <=> b.baseName } ).flatten() 
    num_reads = Channel.fromPath("${params.steps_2_and_3_input_directory}/intermediate_qc_reports/number_of_reads/*")
    read_length = Channel.fromPath("${params.steps_2_and_3_input_directory}/intermediate_qc_reports/read_length/*") 
    quality_thresholds = Channel.fromPath("${params.steps_2_and_3_input_directory}/intermediate_qc_reports/quality_score_thresholds/*")
    multiqc_config = Channel.fromPath(params.multiqc_config)
    multiqc_input = Channel.fromPath("${params.steps_2_and_3_input_directory}/multiqc_input/**", type: "file")

    
}



workflow {

    if (params.step == 1) {

        BASECALLING(pod5_path, fast5_path, basecall_speed, basecall_mods, basecall_config, basecall_trim, quality_score, trim_barcode, devices, ref)
    }

    else if (params.step == 2) {

        FILTERING_AND_QC(total_bams, txts, mapq, quality_score)

    }

    else if (params.step == 3) {
    
        MODKIT_AND_MULTIQC(filtered_bams, filtered_bais, num_reads, read_length, quality_thresholds, multiqc_config, multiqc_input)

    }

}
