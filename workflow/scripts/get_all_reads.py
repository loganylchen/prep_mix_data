import pysam
import pyslow5

import sys

def get_all_reads_from_bam(bam_file):
    with pysam.AlignmentFile(bam_file, "rb") as bam:
        reads = {read.query_name for read in bam}
    print(f'{len(reads)} reads in {bam_file}')
    return reads

def get_all_reads_from_blow5(blow5_file):
    slow5 = pyslow5.Open(blow5_file,'r')
    read_ids, num_reads = slow5.get_read_ids()
    print(f'{num_reads} reads in {blow5_file}')
    return set(read_ids)

def get_all_reads_from_fastq(fastq_file):
    with pysam.FastxFile(fastq_file) as fastq:
        reads = {read.name for read in fastq}
    print(f'{len(reads)} reads in {fastq_file}')
    return reads

log = open(snakemake.log, "w")
sys.stderr = log
sys.stdout = log

bam_reads = get_all_reads_from_bam(snakemake.input.bam)
fastq_reads = get_all_reads_from_fastq(snakemake.input.fastq)
blow5_reads = get_all_reads_from_blow5(snakemake.input.blow5)

all_reads = bam_reads.intersection(fastq_reads).intersection(blow5_reads)

print(f'{len(all_reads)} reads in common between bam, fastq and blow5')

with open(snakemake.output.all_reads, 'w') as f:
    for read in all_reads:
        f.write(f'{read}\n')

