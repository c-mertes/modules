// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

def VERSION = '2.2.0'

process HISAT2_EXTRACTSPLICESITES {
    tag "$gtf"
    label 'process_medium'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), meta:[:], publish_by_meta:[]) }

    conda (params.enable_conda ? 'bioconda::hisat2=2.2.1' : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "https://depot.galaxyproject.org/singularity/hisat2:2.2.1--h1b792b2_3"
    } else {
        container "quay.io/biocontainers/hisat2:2.2.1--h1b792b2_3"
    }

    input:
    path gtf

    output:
    path "*.splice_sites.txt", emit: txt
    path "*.version.txt"     , emit: version

    script:
    def software = getSoftwareName(task.process)
    """
    hisat2_extract_splice_sites.py $gtf > ${gtf.baseName}.splice_sites.txt
    echo $VERSION > ${software}.version.txt
    """
}
