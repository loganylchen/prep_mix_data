rule select_reads:
    input:
        control_bam = 'data/control.bam',
        control_bai = 'data/control.bam.bai',
        native_bam = 'data/native.bam',
        native_bai = 'data/native.bam.bai',
    output:
        control_read_file = 'results/splited_data/{depth}/{ratio}_{replicate}/control_reads.txt',
        native_read_file = 'results/splited_data/{depth}/{ratio}_{replicate}/native_reads.txt',
    conda:
        '../envs/pysam.yaml'
    script:
        "../scripts/select_reads.py"

rule select_blow5:
    input:
        control_read_file='results/splited_data/{depth}/{ratio}_{replicate}/control_reads.txt',
        native_read_file='results/splited_data/{depth}/{ratio}_{replicate}/native_reads.txt',
        merge_blow5='results/merged.blow5',
    output:
        control_blow5='results/splited_data/{depth}/{ratio}/data/control_{replicate}/blow5/nanopore.blow5',
        native_blow5='results/splited_data/{depth}/{ratio}/data/native_{replicate}/blow5/nanopore.blow5',
    params:
        control_blow5_dir='results/splited_data/{depth}/{ratio}/data/control_{replicate}/blow5/',
        native_blow5_dir='results/splited_data/{depth}/{ratio}/data/native_{replicate}/blow5/'
    threads: config['threads']['slow5tools']
    conda:
        "../envs/slow5tools.yaml"
    shell:
        "mkdir -p {params.control_blow5_dir} {params.native_blow5_dir} && "
        "slow5tools get -t {threads} -o {output.control_blow5} {input.merge_blow5} --list {input.control_read_file} &&"
        "slow5tools get -t {threads} -o {output.native_blow5} {input.merge_blow5} --list {input.native_read_file}"