## Clustering genes based on intergenic size

This Snakefile uses BEDtools to crate clusters based on different distances thresholds (`-d`).

Run the Snakefile, then call the Rscripts in `scripts` to make the plots, passing filenames as arguments

```r
Rscript scripts/plot_clusters_count.R plot1.pdf
Rscript scripts/plot_coverage_size plot2.pdf plot3.pdf
```
