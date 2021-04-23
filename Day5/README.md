# Day 5

| Time      | Activity                                        | Slides                                                  | Hands-on                                                    |
|-----------|-------------------------------------------------|---------------------------------------------------------|-------------------------------------------------------------|
| Morning   | MAG annotation and downstream analyses (Part 1) | [Link here](MAG-annotation-and-downstream-analyses.pdf) | [Link here](#MAG-annotation-and-downstream-analyses-part-1) |
| Afternoon | MAG annotation and downstream analyses (Part 2) |                                                         | [Link here](#MAG-annotation-and-downstream-analyses-part-2) |
| Afternoon | Closing remarks and open discussion             |                                                         |                                                             |

## MAG annotation and downstream analyses (Part 1)

First login to the Amazon Cloud and pull possible changes on our GitHub page:

```bash
cd physalia_metagenomics
git pull
```

### Recap of what has been done in anvi'o
First let's take a better look at what has REALLY been done in `anvi'o`.  
Let's open the script:

```bash
less Scripts/ANVIO_MEGAHIT.sh
```

And after several rounds of binning and refining with `anvi-interactive` and `anvi-refine`, we have finally decided to call it a day.  
We have then renamed the bins and made a summary of them with `anvi-summarize`.  
You can find the output of everything that has been done with the bins in `~/Share/BINNING_MEGAHIT`.  
For the moment, let's take the summary file for each of the four samples and copy them to a new folder:

```bash
mkdir MAGs

for SAMPLE in Sample01 Sample02 Sample03 Sample04; do
  cp ~/Share/BINNING_MEGAHIT/$SAMPLE/MAGsSummary/bins_summary.txt MAGs/$SAMPLE.bins_summary.txt
done
```

Since we're at it let's also take a couple of files summarizing the abundance of the MAGs across the different samples:

```bash
for SAMPLE in Sample01 Sample02 Sample03 Sample04; do
  cp ~/Share/BINNING_MEGAHIT/$SAMPLE/MAGsSummary/bins_across_samples/mean_coverage.txt MAGs/$SAMPLE.mean_coverage.txt
  cp ~/Share/BINNING_MEGAHIT/$SAMPLE/MAGsSummary/bins_across_samples/detection.txt MAGs/$SAMPLE.detection.txt
done
```

Later on we might import these summary tables to R.  
For now let's take a look at how many MAGs we have:

```bash
cat MAGs/*bins_summary.txt | grep _MAG_ | wc -l
```

Not bad, not bad at all...

### Taxonomic assignment with GTDB
Normally, one thing that we want to learn more about is the taxonomy of our MAGs.  
Although `anvi'o` gives us a preliminary idea, we can use a more dedicated platform for taxonomic assignment of MAGs.  
Here we will use `GTDBtk`, a tool to infer taxonomy for MAGs based on the GTDB database (you can - and probably should - read more about GTDB [here](https://gtdb.ecogenomic.org/)).  
We have already run `GTDBtk` for you for; let's take a look at what it produced for us:

```bash
ls -lt ~/Share/GTDB
```

Let's copy the two summary files:

```bash
cp ~/Share/GTDB/gtdbtk.bac120.summary.tsv MAGs
cp ~/Share/GTDB/gtdbtk.ar122.summary.tsv MAGs
```

I particularly am curious about `Sample03Short_MAG_00001`, the nice bin from yesterday that had no taxonomic assignment.  
I wonder if it's an archaeon?

```bash
grep Sample03Short_MAG_00001 MAGs/gtdbtk.ar122.summary.tsv
```

It doesn't look like it, no...  
Let's see then in the bacterial classification summary:

```bash
grep Sample03Short_MAG_00001 MAGs/gtdbtk.bac120.summary.tsv
```

And what other taxa we have?  
Let's take a quick look with some `bash` magic:

```bash
cut -f 2 gtdbtk.bac120.summary.tsv | sed '1d' | sort | uniq -c | sort
```

Later on, let's see if we can do some more analyses on R.

### Functional annotation
Let's now annotate the MAGs against databases of functional genes to try to get an idea of their metabolic potential.  
As everything else, there are many ways we can annotate our MAGs.  
Here, let's take advantage of `anvi'o` for this as well.  
Annotation usually takes some time to run, so we won't do it here.  
But let's take a look below at how you could achieve this:

```bash
conda activate anvio-7

for SAMPLE in Sample01 Sample02 Sample03 Sample04; do
  anvi-run-ncbi-cogs --contigs-db $SAMPLE/CONTIGS.db \
                     --num-threads 4

  anvi-run-kegg-kofams --contigs-db $SAMPLE/CONTIGS.db \
                       --num-threads 4

  anvi-run-pfams --contigs-db $SAMPLE/CONTIGS.db \
                 --num-threads 4
done
```

These steps have been done by us already, and the annotations have been stored inside the `CONTIGS.db` of each assembly.  
What we need now is to get our hands on a nice table that we can then later import to R.  
We can achieve this by running `anvi-export-functions`:

```bash
for SAMPLE in Sample01 Sample02 Sample03 Sample04; do
  anvi-export-functions --contigs-db ~/Share/BINNING_MEGAHIT/$SAMPLE/CONTIGS.db \
                        --output-file MAGs/$SAMPLE.gene_annotation.txt
done
```

Since we're at it, let's also run a not so clean piece of code to get information about to which bin/MAG each gene call belongs:

```bash
for SAMPLE in Sample01 Sample02 Sample03 Sample04; do
  BINS=$(cut -f 1 ~/Share/BINNING_MEGAHIT/$SAMPLE/MAGsSummary/bins_summary.txt | sed '1d')

  printf '%s\t%s\t%s\t%s\t%s\t%s\n' bins gene_callers_id contig start stop direction > MAGs/$SAMPLE.gene_calls.txt

  for BIN in $BINS; do
    sed '1d' ~/Share/BINNING_MEGAHIT/$SAMPLE/MAGsSummary/bin_by_bin/$BIN/$BIN-gene_calls.txt | awk -F '\t' -v BIN=$BIN -v OFS='\t' '{print BIN, $1, $2, $3, $4, $5}'
  done >> MAGs/$SAMPLE.gene_calls.txt
done
```

## MAG annotation and downstream analyses (Part 2)

Now let's get all these data into R to explore the MAGs taxonomic identity and functional potential.  
First, download the `MAGs` folder to your computer using FileZilla.
