## Gene prediction

Genes were predicted with Maker v2.31.10. Maker is a pipeline that leverages over predictions obtained from different sources,  and as such Maker's performance depends heavily on its components. In the context of this study, components refer to:

* **EST evidence**: Assembled transcripts from RNA-seq data.

* **Protein homology evidence**: protein sequences from *Zymoseptoria tritici* strain IPO323 (GCF_000219625.1) and *Cercospora beticola* strain 09-40 (GCF_002742065.1) obtained from NCBI.

* ***Ab initio* predictors**: trained SNAP, GeneMark, and Augustus predictors.

* **External predictions**: Gene models predicted with GeMoMa based on mapped RNA-seq data and gene models from *Zymoseptoria tritici* strain IPO323 (GCF_000219625.1), *Cercospora beticola* strain 09-40 (GCF_002742065.1), and C. fulvum race 0 (available at JGI MycoCosm) mapped to the genome.

* **Repeat Masking**: masked repeats in GFF format produced with RepeatMasker using a custom repeat library produced with RepeatModeler.

  

### EST evidence (transcritptome assembly)

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

### Gene models with GeMoMa

Gene models obtained with GeMoMa v1.6.3 were also used within Maker to assist gene prediction. Similar approach was used for both Z. tritici, C. beticola, and C. fulvum race 0 (JGI) to produce gene models:

```bash
pipeline.sh $SEARCH $TARGET $ANNO $REF 12 $OUTDIR $LIB $BAM
```

Where `SEARCH` is the search mode, in this case `SEARCH=tblastn`, `TARGET` is the genome to be annotated, in this case *C. fulvum*, `ANNO` is the annotation in GFF format obtained from NCBI for Z. tritici (GCF_000219625.1) or C. beticola (GCF_002742065.1), `REF` this the reference genome from Z. tritici or C. beticola, `OUTDIR` is the output directory, `LIB=FR_UNSTRANDED` specifies RNA-seq library type (forward/reverse, unstranded), and `BAM` is the BAM file of RNA-seq reads mapped to C. fulvum genome (the same RNA-seq used as EST evidence).

GeMoMa then produces gene models in `OUTDIR/final_annotation.gff`. Before prodicing this GFF file to Maker, it was processed. First, using `GeMoMa.jar` to remove genes isoforms, i.e., keep only one mRNA per gene.

```bash
java -jar $GEMOMAJAR CLI GAF m=1 g=final_annotation.gff
```

Then, using the script `GeMoMa_gff_to_gff3.pl` from EvidenceModeler to convert GFF to GFF3 format:

```bash
GeMoMa_gff_to_gff3.pl filtered_predictions.gff > filtered_predictions_evm.gff
```

The GFF3 was processed with genometools v1.5.9 to identify inconsistencies and fix them when possible. Although here I'd now probably use AGAT insted.

```bash
gt gff3 -tidy -sort -retainids filtered_predictions_evm.gff > filtered_predictions_evm_gt.gff
```

Finally, GAG v2.0.1 was used to remove gene models with length < 250 or > 16000, and gene models with introns size < 15 or > 2000, as such cases are rare in fungi, and likely erroneous.

```bash
gag.py   \
   -f $GENOME \
   -g filtered_predictions_evm_gt.gff \
   -ril 2000 \
   -ris 15 \
   -rgl 16000 \
   -rgs 250 \
   -rcs 150 \
   -o gag_out
```

Resulting GFF files should be accepted by Maker through the `pred_gff` parameter in the `maker_opts.ctl ` control file.

### Repeat masking

Before running Maker, repeats were identified and masked. This is an important step as we do not want Maker calling tranposable elements as genes, or training the ab initio predictions with tranposons.

Repeats were identified with RepeatModeler v1.0.11. Before, the fasta file with the genome was renamed to `ref.fasta` (More tips by Avril Coghlan [here](http://avrilomics.blogspot.com/2015/02/finding-repeats-using-repeatmodeler.html)).

```bash
#Create a Database for RepeatModeler
BuildDatabase -name $DBNAME -engine ncbi $GENOME

#Run RepeatModeler
RepeatModeler -engine ncbi -pa 16 -database $DBNAME
```

Repeat families classified as Unknonw were further analyzed with InterproScan v5.32-71.0 to look for conserved domains not related to tranposons that could have been called as repetitive DNA.

```bash
interproscan.sh --seqtype n --input consensi_unknown.fa -goterms -iprlookup --cpu 24 --formats TSV,HTML,GFF3,XML
```

In this case, no domain other than domains commonly seen in transposons were present. So, repeat library should be good for downstream analysis.

Using the repeat library produced with RepeatModeler, the genome was then masked with RepeatMasker v4.0.7. Note the `-gff` parameter to produce a GFF file that will be given to Maker.

```bash
RepeatMasker -xsmall -lib $LIB -gff -s -pa 12 $GEMOME
```

### Maker round 1

The first round of gene prediction with Maker is intended to generate gene models to train the ab initio predictors, wich are used in the second round of prediction. For the first round of prediction, EST evidence as the assembled transcrips from RNA-seq data was given to Maker through the `est` parameter. Protein sequences from Z. tritici and C. beticola were given to maker though the `protein` parameter. The repeat masking info (parameter`rm_gff`) was given as the GFF produced by RepeatMaker. In addition, parameters `est2genome=1` and `protein2genome=1` were set to 1 to infer gene annotations direcly from EST and protein evidence. Thus, gene models were generated and used to train the ab initio predictors.



### Training ab initio predictors

#### SNAP

To train SNAP v2013-11-29, the script `maker2zff` was used to filter gene models from the first round of prediction and generate models in ZFF format (SNAP readable).

```bash
# generated ZFF from Maker store index *datastore_index.log
# -c 1: The fraction of splice sites confirmed by an EST alignment
# -o 1: The fraction of exons that overlap any evidence (EST or Protein)
# -x 1: Max AED to allow
maker2zff -c 1 -o 1 -x 0.1 -d $DT_INDEX

# validate models
fathom genome.ann genome.dna -validate > snap_validate_output.txt

# find models with errors or warning to remove them
grep -e error -e warning snap_validate_output.txt | awk '{print $2}' | sort -u > models_to_remove.txt

# save original models
cp genome.ann genome_original.ann

# remove models with errors or warnings
grep -vw -f models_to_remove.txt genome.ann > genome_filtered.ann
mv genome_filtered.ann genome.ann

# generated required files to train SNAP
fathom genome.ann genome.dna -validate > snap_validate_output.txt
fathom -gene-stats genome.ann genome.dna > gene_stats.txt
```

 Here are the main stats `gene_stats.txt` of models used to train SNAP. A total of 3,925 genes with 85% of them multi-exon.

```
3925 genes (plus=1975 minus=1950)
565 (0.143949) single-exon
3360 (0.856051) multi-exon
654.189819 mean exon (min=6 max=19932)
71.442245 mean intron (min=42 max=905)
```

Then, SNAP is trained, and the HMM is produced. This HMM is given to Maker.

```bash
fathom genome.ann genome.dna -categorize 1000
fathom uni.ann uni.dna -export 1000 -plus
mkdir snap_files
cd snap_files
forge ../export.ann ../export.dna
hmm-assembler.pl cladosporium_fulvum . > cladosporium_fulvum.hmm
```

#### Augustus

The same filtered set of gene models used to train SNAP was also used to train Agustus v3.2.3. During the SNAP training, gene models are present in the files `export.ann` and `export.dna`. These files can be used to produce a GenBank file to train Augustus. The script `zff2augustus.pl` obtained [here](https://raw.githubusercontent.com/hyphaltip/genome-scripts/master/gene_prediction/zff2augustus_gbk.pl) was used for this purpose:

```bash
zff2augustus_gbk.pl ../01snap/export.ann ../01snap/export.dna > augustus.gbk
```

Then, the models in GenBank format were randomly split and a testing set containing 200 models was obtained:

```bash
randomSplit.pl augustus.gbk 200
```

Here are the commands used to train Augustus:

```bash
#== Variables =========
SPECIES=cladosporium_fulvum
TRAINGB=augustus.gbk.train
TESTGB=augustus.gbk.test
#======================

#making a local copy of augustus config directory
cp -r /share/apps/maker-2.31.10/exe/augustus/config/ ./config

# where species config files are (current directory)
# this has to be exported again before running maker
export AUGUSTUS_CONFIG_PATH=/home/azacca/.../02augustus/config

#creating a new species
new_species.pl --species=$SPECIES

#initial training
etraining --species=$SPECIES $TRAINGB

#first test, without optimization
augustus --species=$SPECIES $TESTGB | tee first_training.out

#optimizing augustus parameters
optimize_augustus.pl --species=$SPECIES --cpus=8 $TRAINGB

#retrain and test again
etraining --species=$SPECIES $TRAINGB

# Second test, with optimization
augustus --species=$SPECIES $TESTGB | tee second_training.out
```

First testing results without parameter optimization.

| Level      | Sensitivity (first test) | Specificity (first test) |
| ---------- | ------------------------ | ------------------------ |
| Nucleotide | 0.97                     | 0.835                    |
| Exon       | 0.767                    | 0.585                    |
| Gene       | 0.585                    | 0.402                    |

In the second testing with parameters optimized, there was a little of improvement:

| Level      | Sensitivity (second test) | Specificity (second test) |
| ---------- | ------------------------- | ------------------------- |
| Nucleotide | 0.968                     | 0.836                     |
| Exon       | 0.775                     | 0.596                     |
| Gene       | 0.61                      | 0.416                     |

The training files should be in the `config/`directory under the species name given. Don't forget to export again `AUGUSTUS_CONFIG_PATH` so Augustus knows where the training files are.

#### GeneMark

To train GeneMark v4.57, genes and intron hints were given to it. The gene hints are the genes in GFF format generated with GeMoMa based on C. beticola annotation, as described previously. The introns hints were generated from the mapped RNA-seq reads in BAM format. Introns hints were generated with the script `bam2hints` from Braker package, which is another gene predictor tools. Commands used are:

```bash
samtools sort -@ 8 -n $BAM > rna_mapped.s.bam
filterBam --uniq --in rna_mapped.s.bam --out rna_mapped.sf.bam
samtools sort -@ 8 rna_mapped.sf.bam -o rna_mapped.sfs.bam
bam2hints --intronsonly --in=rna_mapped.sfs.bam --maxintronlen=2000 --minintronlen=20 --out=introns.gff
filterIntronsFindStrand.pl $GENOME introns.gff --score > introns.f.gff
rm -f *.bam
```

Thus, GeneMark was trained:

```bash
perl /home/azacca/programs/gmes_linux_64/gmes_petap.pl --ET $INTRONS --evidence $GENES --fungus --training --soft_mask auto --sequence $GENOME
```

And the `gmhmm.mod` file was generated. This file is given to Maker.