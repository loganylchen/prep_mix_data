import pysam
import random
import os
from collections import defaultdict


depth = int(snakemake.wildcards.depth)
ratio = float(snakemake.wildcards.ratio)
replicate = int(snakemake.wildcards.replicate)

control_bam = snakemake.input.control_bam
native_bam = snakemake.input.native_bam


def get_read_number(depth,ratio):
    return int(depth * ratio), int(depth * (1 - ratio)), depth
def extract_reads(control_bam_file, native_bam_file):
    reads_dict= defaultdict(list)
    with pysam.AlignmentFile(control_bam_file, "rb") as control_bam, pysam.AlignmentFile(native_bam_file, "rb") as native_bam:
        transcripts = set(control_bam.references).intersection(set(native_bam.references))
        for transcript in transcripts:
            control_reads = [read.query_name for read in control_bam.fetch(transcript)]
            native_reads = [read.query_name for read in native_bam.fetch(transcript)]

            native_depth, control_in_native_depth, control_depth = get_read_number(depth, ratio)


            if len(control_reads) >= control_depth+control_in_native_depth:
                select_control_reads = random.sample(control_reads, control_depth+control_in_native_depth)
            else:
                select_control_reads = control_reads

            if len(native_reads) >= native_depth:
                select_native_reads = random.sample(native_reads, native_depth)
            else:
                select_native_reads = native_reads

            if len(select_control_reads) > control_depth:
                reads_dict['control'] += select_control_reads[:control_depth]
                reads_dict['native'] += select_control_reads[control_depth:]
                reads_dict['native'] += select_native_reads
            else:
                reads_dict['control'] += select_control_reads
                reads_dict['native'] += select_control_reads[:min(control_in_native_depth,len(select_control_reads))]
                reads_dict['native'] += select_native_reads

    return reads_dict

outdir = snakemake.output.outdir
os.makedirs(os.path.join(outdir,depth,f'{ratio}_{replicate}'), exist_ok=True)

reads_dict = extract_reads(control_bam, native_bam)

with open(os.path.join(outdir,depth,f'{ratio}_{replicate}','control_reads.txt'),'w') as control_reads_file:
    control_reads_file.write('\n'.join(list(set(reads_dict['control']))))
with open(os.path.join(outdir,depth,f'{ratio}_{replicate}','native_reads.txt'),'w') as native_reads_file:
    native_reads_file.write('\n'.join(list(set(reads_dict['native']))))

