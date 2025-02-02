process RUN_ESMFOLD {
    tag "$meta.id"
    label 'process_medium'

    if (workflow.profile.tokenize(',').intersect(['conda', 'mamba']).size() >= 1) {
        error("Local RUN_ESMFOLD module does not support Conda. Please use Docker / Singularity / Podman instead.")
    }

    container "nf-core/proteinfold_esmfold:dev"

    input:
    tuple val(meta), path(fasta)
    path ('./checkpoints/')
    val numRec

    output:
    tuple val(meta), path ("${meta.id}_esmfold.pdb")  , emit: pdb
    tuple val(meta), path ("${meta.id}_plddt_mqc.tsv"), emit: multiqc
    path "versions.yml"                               , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def VERSION = '1.0.3' // WARN: Version information not provided by tool on CLI. Please update this string when bumping container versions.

    """
    esm-fold \
        -i ${fasta} \
        -o \$PWD \
        -m \$PWD \
        --num-recycles ${numRec} \
        $args

    mv  *.pdb tmp.pdb
    mv  tmp.pdb ${meta.id}_esmfold.pdb

    awk '{print \$2"\\t"\$3"\\t"\$4"\\t"\$6"\\t"\$11}' ${meta.id}_esmfold.pdb | grep -v 'N/A' | uniq > plddt.tsv
    echo -e Atom_serial_number"\\t"Atom_name"\\t"Residue_name"\\t"Residue_sequence_number"\\t"pLDDT > header.tsv
    cat header.tsv plddt.tsv > ${meta.id}_plddt_mqc.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        esm-fold: $VERSION
    END_VERSIONS
    """

    stub:
    def VERSION = '1.0.3' // WARN: Version information not provided by tool on CLI. Please update this string when bumping container versions.
    """
    touch ./${meta.id}_esmfold.pdb
    touch ./${meta.id}_plddt_mqc.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        esm-fold: $VERSION
    END_VERSIONS
    """
}
