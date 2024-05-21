import pysam
import random
import os
from collections import defaultdict


depths = snakemake.params.depths
ratios = snakemake.params.ratios
replicates = snakemake.params.replicates

control_bam = snakemake.input.control_bam
native_bam = snakemake.input.native_bam


def get_read_number(depth,ratio):
    return int(depth * ratio), int(depth * (1 - ratio)), depth
def extract_reads(control_bam_file, native_bam_file, depths, ratios, replicates):
    reads_dict= defaultdict(dict)
    with pysam.AlignmentFile(control_bam_file, "rb") as control_bam, pysam.AlignmentFile(native_bam_file, "rb") as native_bam:
        transcripts = set(control_bam.references).intersection(set(native_bam.references))
        for transcript in transcripts:
            control_reads = [read.query_name for read in control_bam.fetch(transcript)]
            native_reads = [read.query_name for read in native_bam.fetch(transcript)]
            for depth in depths:
                for ratio in ratios:
                    native_depth, control_in_native_depth, control_depth = get_read_number(depth, ratio)
                    for replicate in replicates:
                        key = f"{depth}_{ratio}_{replicate}"
                        if reads_dict[key]['control'] is None:
                            reads_dict[key]['control'] = []
                        if reads_dict[key]['native'] is None:
                            reads_dict[key]['native'] = []
                        if len(control_reads) >= control_depth+control_in_native_depth:
                            select_control_reads = random.sample(control_reads, control_depth+control_in_native_depth)
                        else:
                            select_control_reads = control_reads

                        if len(native_reads) >= native_depth:
                            select_native_reads = random.sample(native_reads, native_depth)
                        else:
                            select_native_reads = native_reads

                        if len(select_control_reads) > control_depth:
                            reads_dict[key]['control'] += select_control_reads[:control_depth]
                            reads_dict[key]['native'] += select_control_reads[control_depth:]
                            reads_dict[key]['native'] += select_native_reads
    return reads_dict

outdir = snakemake.output.outdir

for key in reads_dict:
    os.makedirs(os.path.join(outdir,key), exist_ok=True)
    with open(os.path.join(outdir,key,'control_reads.txt'),'w') as control_reads_file:
        control_reads_file.write('\n'.join(list(set(reads_dict[key]['control']))))
    with open(os.path.join(outdir,key,'native_reads.txt'),'w') as native_reads_file:
        native_reads_file.write('\n'.join(list(set(reads_dict[key]['native']))))
with open(snakemake.output.tag,'w') as out:
    out.write('Done')
