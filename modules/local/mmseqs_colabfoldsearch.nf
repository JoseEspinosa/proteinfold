process MMSEQS_COLABFOLDSEARCH {
    tag "$meta.id"
    label 'process_high_memory'

    // Exit if running this module with -profile conda / -profile mamba
    if (workflow.profile.tokenize(',').intersect(['conda', 'mamba']).size() >= 1) {
        error("Local MMSEQS_COLABFOLDSEARCH module does not support Conda. Please use Docker / Singularity / Podman instead.")
    }

    container "nf-core/proteinfold_colabfold:1.1.0"

    input:
    tuple val(meta), path(fasta)
    path ('db/params')
    path colabfold_db
    path uniref30

    output:
    tuple val(meta), path("${meta.id}.a3m"), emit: a3m
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def VERSION = '1.5.2' // WARN: Version information not provided by tool on CLI. Please update this string when bumping container versions.

    """
    ln -r -s $uniref30/uniref30_* ./db
    ln -r -s $colabfold_db/colabfold_envdb* ./db

    /localcolabfold/colabfold-conda/bin/colabfold_search \\
        $args \\
        --threads $task.cpus ${fasta} \\
        ./db \\
        "result/"

    cp result/0.a3m ${meta.id}.a3m

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        colabfold_search: $VERSION
    END_VERSIONS
    """

    stub:
    def VERSION = '1.5.2' // WARN: Version information not provided by tool on CLI. Please update this string when bumping container versions.
    """
    touch ${meta.id}.a3m

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        colabfold_search: $VERSION
    END_VERSIONS
    """
}
