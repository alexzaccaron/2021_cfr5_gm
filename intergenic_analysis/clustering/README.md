## Clustering genes based on intergenic size

This Snakefile uses BEDtools to crate clusters based on different distances thresholds (`-d`).

Run the Snakefile, then call the Rscripts in `scripts` to make the plots

```r
snamekmake -j 2 --use-conda
Rscript scripts/plot_clusters_summaries.R
Rscript scripts/plot_intergenic_size_repeat_content.R
```
