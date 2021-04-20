# Day 3

| Time      | Activity            | Slides                               | Hands-on                          |
|-----------|---------------------|--------------------------------------|-----------------------------------|
| Morning   | Metagenome assembly | [Link here](metagenome-assembly.pdf) | [Link here](#metagenome-assembly) |
| Afternoon | Assembly QC         |                                      | [Link here](#assembly-qc)         |

## Metagenome assembly

First log in to our cloud instance with the IP provided and `cd` to your working directory.  
Let's then pull possible changes in the Github repository:

```bash
cd physalia_metagenomics
git pull origin main
```

After that we're gonna go through the metagenomic assembly part, but not run the actual assembly script.  
The assembly takes days and needs more resources than we have on our instance.  
So the assemblies will be provided.  

### Short-read assembly with megahit
The short reads will be assembled using `megahit`.  
Although, we won't be running the actual assembly, `megahit` is installed on our instance.  

So have a look at the different options you can change in the assembly.  
You can find more information about `megahit` from the [megahit wiki](https://github.com/voutcn/megahit/wiki).  
You don't need to understand each and every option, but some of them can be important.

```bash
conda activate assembly_env
megahit -h
```

#### Questions about megahit
1. __What do you think would be important? What would you change or set?__  
2. __What version of megahit have we installed? Is it the latest?__

After that have a look at the assembly script `Scripts/MEGAHIT.sh`.  
Open it with a text editor or print it on the screen with `less`.  

__Would you have changed something else and why?__

When we're satisfied with the assembly options, we would start the assembly and wait from few hours to several days depending on your data and computational resources.  
But we won't do it, since we don't have to time or the resources.  
Instead, you can copy the assemblies and log files to your own folder from `Share/ASSEMBLY_MEGAHIT/`.  
The copying will complain about permissions, but you don't need to worry about that.  
It just won't copy some intermediate files.  

```bash
cp -r ~/Share/ASSEMBLY_MEGAHIT/ ./
```

Inside the folder you'll find the assembly logs inside the assembly folder for each sample.  
Start by looking at the assembly logs with `less`.

#### Questions about the assembly
1. __Which version of megahit did we actually use for the assemblies?__
2. __How long did the assemblies take to finish?__
3. __Which sample gave the longest contig?__

### Long-read assembly with metaFlye
We will also assemble the Nanopore data using `metaFlye` (which is actually a version of the genome assembler `Flye` with different settings that are optimized for metagenomes).  
You can read more about `Flye/metaflye` [here](https://github.com/fenderglass/Flye).

The script we are using to run `metaFlye` is quite simple, but let's take a look at it using `less` (the script is located in `Scripts/METAFLYE.sh`).  

Again, we are not actually running the long-read assembly as this takes some time.  
Instead, you will find the assemblies already made in `Share/ASSEMBLY_METAFLYE`.  
Let's copy the assembly folder as we have done before for `megahit`:

```bash
cp -r ~/Share/ASSEMBLY_METAFLYE/ ./
```

Look at the log files from `metaFlye` that are inside this folder (`Sample03.metaflye.log.txt` and `Sample04.metaflye.log.txt`) and answer the questions below.

#### Questions about the assembly
1. __How many contigs do we have in each assembly?__
2. __What is the total assembly lenght of each assembly?__

The downside of Nanopore (at the moment), is a somewhat higher error rate than Illumina.  
But because we have sequenced the same samples using both Illumina and Nanopore, we can take advantage of the longer reads from Nanopore and the better error rates from Illumina.  
We do that by correcting (polishing) the Nanopore assemblies using the short Illumina reads.  
This will be done using `Pilon` [take a look here](https://github.com/broadinstitute/pilon/wiki).

Let's take a look at the script that is located in `Scripts/PILON.sh`.  

You will find inside the assemblies folder `ASSEMBLY_METAFLYE/Sample03` and `ASSEMBLY_METAFLYE/Sample04` folders the output from `Pilon`.  
The `pilon.fasta` file is the corrected assembly, and the `pilon.changes` file is a list of every single change that `Pilon` made to the `metaFlye` assemblies.  
Let's take a look at the first few lines of these files using head:

```bash
head ASSEMBLY_METAFLYE/Sample03/pilon.changes
head ASSEMBLY_METAFLYE/Sample04/pilon.changes
```

## Assembly QC

Now we have all the assemblies ready and we can use `metaquast` for quality control.  Activate the assembly environment if its not already activated and run metaquast all short and long read assemblies.
First have a look at the different options meatquast has with `metaquast -h`.  
You should at least check the options we are using.

```bash
metaquast.py ASSEMBLY_METAFLYE/*/pilon.fasta ASSEMBLY_MEGAHIT/*/final.contigs.fa \
               -o METAQUAST_FAST \
               --threads 1 \
               --fast \
               --max-ref-number 0 &> metaquast.fast.log.txt
```

Assembly QC takes ~15 min. After it is done, we will go through the report together.   
Open the report file in the output folder.

```bash
less METAQUAST_FAST/report.txt
```
#### Questions about the assembly QC

1. __Which assembly has the longest contig when also long reads assemblies are included?__
2. __Which assembly had the most contigs?__
3. __Were the long read assemblies different from the corresponding short read assemblies?__
4. __If yes, in what way?__
