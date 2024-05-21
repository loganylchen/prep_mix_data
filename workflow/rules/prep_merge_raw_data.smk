rule merge_bam:
    input:
        control_bam = 'data/control.bam',
        control_bai = 'data/control.bam.bai',
        native_bam = 'data/native.bam',
        native_bai = 'data/native.bam.bai',
    output:
        bam='results/merged.bam',
        bai='results/merged.bam.bai',
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
    shell:
        'slow5tools merge -o {output.blow5} {input.control_blow5} {input.native_blow5}'

rule merge_fastq:
    input:
        control_fastq = 'data/control.fastq.gz',
        native_fastq = 'data/native.fastq.gz',
    output:
        fastq='results/merged.fastq.gz',
    shell:
        'zcat {input.control_fastq} {input.native_fastq} > {output.fastq}'