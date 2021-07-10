## Genome assembly notes

### Assembly with Canu

The genome of *C. fulvum* race 5 was assembled with Canu v1.8. The following code (SLURM script) was used to call Canu with the adjusted parameters.

```bash
module load jdk/1.8
module load perl/5.18.4

export PATH="/home/azacca/programs/canu-1.8/Linux-amd64/bin/:$PATH"

READS=/home/azacca/projects/Cfulvum/data/pacbio_reads/m54048_180421_080651.subreads.fasta

time canu -p CfulvR5 -d Cfulv_canu_tweaked_01 \
	genomeSize=70m            \
	-pacbio-raw $READS        \
	useGrid=false             \
	corOutCoverage=60         \
	minReadLength=5000        \
	minOverlapLength=3000     \
	corMinCoverage=5          \
	corMhapSensitivity=normal \
	correctedErrorRate=0.03
```



### Polishing with Arrow

The assembly was then polished with Arrow (using long reads) and Pilon (using short reads). Polishing with Arrow v2.3.3 was carried out with the `genomicconsensus` package and the PacBio aligner `pbmm2` v1.0.0, both installed via conda: 

 ```bash
 conda install -c bioconda genomicconsensus pbmm2 
 ```

First, PacBio subreads were aligned to the assembly with pbmm2:

```bash
pbmm2 align $REF $SUBREADSS_BAM $OUT_BAM   \
      --sort -j 20 -J 2                    \
      --log-level INFO --log-file pbmm2.log
```

Assembly and BAM files were indexed with SAMtools and pbindex, respectively:

```bash
samtools faidx $REF
pbindex $OUT_BAM
```

Arrow was then called:

```bash
arrow --referenceFilename $REF  \
      -o $ARROW_OUT.fasta       \
      -o $ARROW_OUT.vcf         \
      --log-level INFO -j 20 $OUT_BAM
```

### Polishing with Pilon

After polishing with Arrow, Pilon v1.23 was used to polish the assembly with short Illumina reads. Reads were mapped to the Arrow-polished genome with BWA-mem v0.7.17-r1188.

```bash
bwa mem -t 18 $ARROW_POLISHED $READ1 $READ2 -o $OUT_SAM
```

The alignment was processed with SAMtols with flag `-F 2308` to suppress unmapped reads and supplementary alignments.

```bash
samtools view -Sb -F 2308 $OUT_SAM | samtools sort -@ 4 -o $OUT_BAM
```

PCR duplicates were marked with `MarkDuplicates` v2.20.5 from Picard tools:

```bash
java -jar picard.jar MarkDuplicates   \
   I=$OUT_BAM O=$DEDUP_BAM M=dedup.log
```

Pilon was then called:

```bash
java -Xmx32G -jar pilon-1.23.jar \
   --genome $REF                 \
   --frags $BAM                  \
   --output $OUT_PREFIX          \
   --outdir $OUT_DIR             \
   --changes                     \
   --vcf                         \
   --tracks                      \
   --verbose | tee pilon.log
```

This procedure was repeated twice (i.e., two rounds of polishing).

