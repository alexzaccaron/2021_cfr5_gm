## Gene prediction

RNA-seq was used to support gene prediction 

### Transcritptome assembly

First, RNA-seq reads were trimmed to remove low quality bases and adapter sequences with `fastp` v0.20.1

```bash
fastp -i $IN1 -I $IN2 -o $OUT1 -O $OUT2 --thread 8 --html cfR5_RNA_mix.html --json cfR5_RNA_mix.json --length_required 50
```

Based on the `fastp` report, 96.4% of the reads passed the filters. Reads were then mapped to the genome with HISAT2 v2.2.0. Resulting SAM file was converted to BAM with SAMtools v1.9.

```bash
hisat2 -p 12 \
   --dta     \
   --max-intronlen 3000 \
   -x $INDEX \
   -1 $R1    \
   -2 $R2    \
   --summary-file cfR5_RNA_mix_map.stats \
   -S cfR5_RNA_mix.sam

samtools sort -@ 8 -o cfR5_RNA_mix.bam cfR5_RNA_mix.sam
```

The summary file of HISAT2 indicated 97.13% alignment rate. From the alignment, StringTie v2.1.1 was used to assemble transcripts.

```bash
stringtie -p 8 -o CFR5_RNAmix.gtf -l CFR5_rnamix $BAM
```

StringTie assembled 12,822 transcripts with average length of 3,733 bp.