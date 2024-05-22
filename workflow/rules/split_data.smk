rule select_reads:
    input:
        control_bam = 'data/control.bam',
        control_bai = 'data/control.bam.bai',
        native_bam = 'data/native.bam',
        native_bai = 'data/native.bam.bai',
        all_reads='results/all_reads.txt',
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
    log:
        'logs/select_blow5_{depth}_{ratio}_{replicate}.log'
    threads: config['threads']['select_blow5']
    conda:
        "../envs/python.yaml"
    script:
        "../scripts/select_blow5.py"

rule generate_split_fastq:
    input:
        fastq='results/merged.fastq.gz',
        control_read_file='results/splited_data/{depth}/{ratio}_{replicate}/control_reads.txt',
        native_read_file='results/splited_data/{depth}/{ratio}_{replicate}/native_reads.txt',
    output:
        control_fastq='results/splited_data/{depth}/{ratio}/data/control_{replicate}/fastq/pass.fq.gz',
        native_fastq='results/splited_data/{depth}/{ratio}/data/native_{replicate}/fastq/pass.fq.gz',
    conda:
        "../envs/seqtk.yaml"
    shell:
        "seqtk subseq {input.fastq} {input.control_read_file} | gzip -c > {output.control_fastq} && "
        "seqtk subseq {input.fastq} {input.native_read_file} | gzip -c > {output.native_fastq}  "