// Make this pipeline a nextflow 2 implementation
nextflow.enable.dsl=2

log.info """
                            OXFORD NANOPORE DNA SEQUENCING BASECALLING - Bernardo Aguzzoli Heberle
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
 MAPQ filtering threshold							: ${params.mapq}

 Output directory                                                               : ${params.out_dir}
 =====================================================================================================================================================================================
 
 """ 



// Import Workflows
include {BASECALLING} from '../sub_workflows/BASECALLING'


// Define initial files and channels


if (params.prefix == "None") {

	fast5_path = Channel.fromPath("${params.basecall_path}/**.fast5").map{file -> tuple(file.parent.toString().split("/")[-2] + "_" + file.simpleName.split('_')[0] + "_" + file.simpleName.split('_')[-3..-2].join("_"), file) }.groupTuple()
    
	pod5_path = Channel.fromPath("${params.basecall_path}/**.pod5").map{file -> tuple(file.parent.toString().split("/")[-2] + "_" + file.simpleName.split('_')[0] + "_" + file.simpleName.split('_')[-3..-2].join("_"), file) }.groupTuple()

} else {

	fast5_path = Channel.fromPath("${params.basecall_path}/**.fast5").map{file -> tuple("${params.prefix}_" + file.parent.toString().split("/")[-2] + "_" + file.simpleName.split('_')[0] + "_" + file.simpleName.split('_')[-3..-2].join("_"), file) }.groupTuple()

	pod5_path = Channel.fromPath("${params.basecall_path}/**.pod5").map{file -> tuple("${params.prefix}_" +  file.parent.toString().split("/")[-2] + "_" + file.simpleName.split('_')[0] + "_" + file.simpleName.split('_')[-3..-2].join("_"), file) }.groupTuple()

}   

ref = file(params.ref)
mapq = Channel.value(params.mapq)
quality_score = Channel.value(params.qscore_thresh)
basecall_speed = Channel.value(params.basecall_speed)
basecall_mods = Channel.value(params.basecall_mods)
basecall_config = Channel.value(params.basecall_config)
basecall_trim = Channel.value(params.basecall_trim)
basecall_compute = Channel.value(params.basecall_compute)
trim_barcode = Channel.value(params.trim_barcode)
devices = Channel.value(params.gpu_devices)



workflow {
	
    BASECALLING(pod5_path, fast5_path, basecall_speed, basecall_mods, basecall_config, basecall_trim, quality_score, trim_barcode, devices, mapq, ref)

}
