rule merge_bam:
    input:
        control_bam = 'data/control.bam',
        control_bai = 'data/control.bam.bai',
        native_bam = 'data/native.bam',
        native_bai = 'data/native.bam.bai',
    output:
        bam='results/merged.bam',
        bai='results/merged.bam.bai',
    conda:
        '../envs/samtools.yaml'
    threads: config['threads']['samtools']
    shell:
        'samtools merge -o {output.bam}.tmp -@ {threads} {input.control_bam} {input.native_bam} && '
        'samtools sort -@ {threads} -o {output.bam} {output.bam}.tmp && '
        'samtools index {output.bam} && '
        'rm {output.bam}.tmp'

rule merge_blow5:
    input:
        control_blow5 = 'data/control.blow5',
        native_blow5 = 'data/native.blow5',
    output:
        blow5='results/merged.blow5',
    threads: config['threads']['slow5tools']
    conda:
        '../envs/slow5tools.yaml'
    shell:
        'slow5tools merge -o {output.blow5} {input.control_blow5} {input.native_blow5}'

rule merge_fastq:
    input:
        control_fastq = 'data/control.fastq.gz',
        native_fastq = 'data/native.fastq.gz',
    output:
        fastq='results/merged.fastq.gz',
    conda:
        '../envs/samtools.yaml'
    shell:
        'zcat {input.control_fastq} {input.native_fastq} > {output.fastq}'

rule blow5_index:
    input:
        blow5='results/merged.blow5',
    output:
        blow5_index='results/merged.blow5.idx',
    conda:
        "../envs/slow5tools.yaml"
    threads: config['threads']['slow5tools']
    shell:
        "slow5tools index {input.blow5}"


rule get_all_reads:
    input:
        blow5='results/merged.blow5',
        blow5_index='results/merged.blow5.idx',
        fastq='results/merged.fastq.gz',
        bam='results/merged.bam',
        bai='results/merged.bam.bai',
    output:
        all_reads='results/all_reads.txt',
    log:
        'logs/get_all_reads.log',
    conda:
        "../envs/python.yaml"
    script:
        "../scripts/get_all_reads.py"
