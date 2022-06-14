println "Occupancy Analysis Pipeline     "
println "================================="

println "fq_folder            : ${params.fq_folder}"
println "slide             : ${params.slide}"
println "interval             : ${params.interval}"
println "length             : ${params.length}"
//println "sam_file            : ${params.sam_file}"
//println "sam_folder            : ${params.sam_folder}"

//nextflow run main.nf --fq_folder /hwfssz8/MGI_CG_SZ/USER/huangsixing/xu/V350053028_nofilter_r10_outputFq/ --slide V350053028 --interval 100 --length 10 -profile sge

ch = Channel.of( 'L01', 'L02', 'L03', 'L04' )
//ch = Channel.of( 'L01')


process mapping {
    errorStrategy 'ignore'

    input:
    each lane from ch

    output:
    val lane into mapping_out

    //    /share/app/singularity/3.8.1/bin/singularity exec  -B ${params.fq_folder}/${lane}:/app  $workflow.projectDir/andy.sif python /python/analysisAndMapping.py  /app/Metrics/ /app/  ${params.slide}

    script:
    """
    /share/app/singularity/3.8.1/bin/singularity exec  -B ${params.fq_folder}/${lane}:/app  $workflow.projectDir/andy.sif python /python/analysisAndMapping.py  /app/Metrics/ /app/  ${params.slide} -j ${params.interval}
    """
}


process split_sam {
    
    input:
    val lane from mapping_out

    output:
    //path(params.sam_folder) into split_sam_ch
    val lane into split_sam_ch

    ///share/app/singularity/3.8.1/bin/singularity exec -B ${params.fq_folder}/${lane}/FQMAP/:/data $workflow.projectDir/splitsam.sif bash /app/split_sam.sh \$inputsam
    script:
    """
    inputsam=\$(ls ${params.fq_folder}/${lane}/FQMAP/*.sam)
    filename=\$(basename -- "\$inputsam")
    
    /share/app/singularity/3.8.1/bin/singularity exec -B ${params.fq_folder}/${lane}/FQMAP/:/data $workflow.projectDir/splitsam.sif bash /app/split_sam.sh /data/\$filename
    """
}



process subset_excel {
    //publishDir params.collect_dir, mode: 'copy' 
    errorStrategy 'ignore'

    input:
    val lane from split_sam_ch
    

    output:
    val 1 into occu_out

    //path("${params.output}/*_Summary.xlsx") into summary_ch


    //python /hwfssz8/MGI_BCC/USER/huangsixing/occupancy_analysis/occupancy_chip_wrapper.py -d ${params.data} -l ${lane} -o ${params.output} -s ${params.slide} -c ${params.start} -r ${params.range}

    ///share/app/singularity/3.8.1/bin/singularity exec -B /hwfssz8/MGI_BCC/USER/huangsixing/  ./occu.sif python /app/occupancy_chip_wrapper.py -d /hwfssz8/MGI_BCC/USER/huangsixing/Javier/V300098092_lite1.1 -l L01 -o /hwfssz8/MGI_BCC/USER/huangsixing/test -s V300098092 -c 1 -r 8

    //python ${params.script} -d ${params.data} -l ${lane} -o ${params.output} -s ${params.slide} -c ${params.start} -r ${params.range}

    //    /share/app/singularity/3.8.1/bin/singularity exec -B ${params.fq_folder}/${lane}/FQMAP/subset:/app/sam $workflow.projectDir/filt.sif python  /app/filt_discord_table_pct.py /app/sam/ /app/sam/*.sam -l 10

    script:
    """
    /share/app/singularity/3.8.1/bin/singularity exec -B ${params.fq_folder}/${lane}/FQMAP/subset:/app/sam $workflow.projectDir/filt.sif python  /app/filt_discord_table_pct.py /app/sam/ /app/sam/*.sam -l ${params.length}
    """



    ///share/app/singularity/3.8.1/bin/singularity exec -B $HOME  ${params.image} python /app/occupancy_chip_wrapper.py -d ${params.data} -l ${lane} -o ${params.output} -s ${params.slide} -c ${params.start} -r ${params.range} -p ${params.platform}

    //"""
    //python /hwfssz8/MGI_CG_SZ/USER/huangsixing/nextflow/occupancy_analysis_chip_singu/test.py ${params.output}/${params.slide}/Lite/
    //"""

}

