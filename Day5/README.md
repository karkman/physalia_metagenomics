# Day 5

| Time      | Activity            | Slides                               | Hands-on                          |
|-----------|---------------------|--------------------------------------|-----------------------------------|
| Morning   | MAG annotation      | [Link here](MAG-annotation.pdf)      | [Link here](#MAG-annotation)      |

## MAG annotation

First login to the Amazon Cloud and pull possible GitHub changes:

```bash
cd physalia_metagenomics
git pull
```

### Recap of what has been done in anvi'o
First let's take a better look at what has REALLY been done in `anvi'o`.  
Let's take a look at the script:

```bash
less Scripts/ANVIO_MEGAHIT.sh
```

After several rounds of binning and refining with `anvi-interactive` and `anvi-refine`, we have finally decided to call it a day.  
We have then renamed the bins and made a summary of them with `anvi-summarize`.
You can find the output of everything that has been done with the bins in `Share/BINNING_MEGAHIT`

### Taxonomic assignment with GTDB
Normally we would like to learn more about the taxonomy of our MAGs.  
Although `anvi'o` gives us a preliminary idea, we can use a more dedicated platform for taxonomic assignment of MAGs.  
Here we will use `GTDBtk`, a tool to infer taxonomy for MAGs based on the GTDB database (you can - and probably should - read more about GTDB [here](https://gtdb.ecogenomic.org/)).  
We have already run `GTDBtk` for you.  
Let's take a look at what it produced for us:

```bash
ls -lt ~/Share/GTDB
```

Let's copy the two summary files:

```bash
cp ~/Share/GTDB/gtdbtk.bac120.summary.tsv .
cp ~/Share/GTDB/gtdbtk.ar122.summary.tsv .
```

Particularly, let's look at `Sample03Short_MAG_00001`, the nice bin from yesterday that had no taxonomic assignment:

```bash
grep Sample03Short_MAG_00001 gtdbtk.bac120.summary.tsv
```

What other taxa we have?  
Let's take a quick look with some `bash` magic:

```bash
cut -f 2 gtdbtk.bac120.summary.tsv | sed '1d' | sort | uniq -c | sort
```

### Functional annotation
Let's now annotate the MAGs against databases of functional genes.  
This takes some time to run so we won't do it here.  
Instead, let's take a look at the script:

```bash
Scripts/ANVIO_ANNOTATE.sh
```

We can now run an `anvi'o` command to get a table of the annotations.  
First let's create a new folder:

```bash
mkdir ANNOTATION
```

And then run `anvi-export-functions`:

```bash
for SAMPLE in Sample01 Sample02 Sample03 Sample04; do
  anvi-export-functions --contigs-db ~/Share/BINNING_MEGAHIT/$SAMPLE/CONTIGS.db \
                        --output-file ANNOTATION/$SAMPLE.gene_annotation.txt
done
```

Let's also run a not so clean piece of code to get information about to which bin/MAG each gene call belongs:

```bash
for SAMPLE in Sample01 Sample02 Sample03 Sample04; do
  BINS=$(cut -f 1 ~/Share/BINNING_MEGAHIT/$SAMPLE/MAGsSummary/bins_summary.txt | sed '1d')

  printf '%s\t%s\t%s\t%s\t%s\t%s\n' bins gene_callers_id contig start stop direction > ANNOTATION/$SAMPLE.gene_calls.txt

  for BIN in $BINS; do
    sed '1d' ~/Share/BINNING_MEGAHIT/$SAMPLE/MAGsSummary/bin_by_bin/$BIN/$BIN-gene_calls.txt | awk -F '\t' -v BIN=$BIN -v OFS='\t' '{print BIN, $1, $2, $3, $4, $5}'
  done >> ANNOTATION/$SAMPLE.gene_calls.txt
done
```

And let's get a copy of the main summary for the bins:

```bash
for SAMPLE in Sample01 Sample02 Sample03 Sample04; do
  cp ~/Share/BINNING_MEGAHIT/$SAMPLE/MAGsSummary/bins_summary.txt ANNOTATION/$SAMPLE.bins_summary.txt
done
```
