// Import Modules

include {FAST5_to_POD5; BASECALL_CPU; BASECALL_CPU_DEMUX; BASECALL_GPU; BASECALL_GPU_DEMUX} from '../modules/basecall.nf'
include {PYCOQC} from '../modules/pycoqc.nf'
include {FILTER_BAM} from '../modules/filter_bam.nf'

workflow BASECALLING {
        
    take:
        pod5_path
        fast5_path
        speed
        modifications
        config
        trim
        quality_score
        trim_barcode
	devices
	ref

    main:


    FAST5_to_POD5(fast5_path)
    pod5_path = FAST5_to_POD5.out.mix(pod5_path)


    if (params.basecall_compute?.equalsIgnoreCase("cpu")) {
        
        if (params.basecall_demux == true) {

            BASECALL_CPU_DEMUX(pod5_path, speed, modifications, config, trim, quality_score, trim_barcode, devices, ref)

       	    bams = BASECALL_CPU_DEMUX.out.bam.toSortedList( { a, b -> a[0] <=> b[0] } ).flatten().buffer(size:2)
	    txts = BASECALL_CPU_DEMUX.out.txt.toSortedList( { a, b -> a.baseName <=> b.baseName } ).flatten()

        } else {
            
            BASECALL_CPU(pod5_path, speed, modifications, config, trim, quality_score, devices, ref)

       	    bams = BASECALL_CPU.out.bam.toSortedList( { a, b -> a[0] <=> b[0] } ).flatten().buffer(size:2)
	    txts = BASECALL_CPU.out.txt.toSortedList( { a, b -> a.baseName <=> b.baseName } ).flatten()

    
        }
    
    } else if (params.basecall_compute?.equalsIgnoreCase("gpu")) {
        
        if (params.basecall_demux == true) {

            BASECALL_GPU_DEMUX(pod5_path, speed, modifications, config, trim, quality_score, trim_barcode, devices, ref)

       	    bams = BASECALL_GPU_DEMUX.out.bam.toSortedList( { a, b -> a.baseName <=> b.baseName } ).flatten()
	    txts = BASECALL_GPU_DEMUX.out.txt.toSortedList( { a, b -> a.baseName <=> b.baseName } ).flatten()

        } else {

            BASECALL_GPU(pod5_path, speed, modifications, config, trim, quality_score, devices, ref)
       	    
	    bams = BASECALL_GPU.out.bam.toSortedList( { a, b -> a[0] <=> b[0] } ).flatten().buffer(size:2)
	    txts = BASECALL_GPU.out.txt.toSortedList( { a, b -> a.baseName <=> b.baseName } ).flatten()

        }

    }


    PYCOQC(bams, txts, quality_score)
    FILTER_BAM(bams, mapq)


}
