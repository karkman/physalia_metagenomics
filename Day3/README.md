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
Instead, you can use the assemblies and log files we have made and make soft link as before to your own folder.  
We have removed some intermediate files, so the folder contains only some of the files `megahit` normally produces.  
But the most important is the `final.contigs.fa` which cointains the final contigs as one might expect.


```bash
cd ~/physalia_metagenomics
ln -s ~/Share/ASSEMBLY_MEGAHIT/ ./
```

Inside the folder you'll find the assembly logs inside the assembly folder for each sample.  
Start by looking at the assembly logs with `less`.

#### Questions about the assembly
1. __Which version of megahit did we actually use for the assemblies?__
2. __How long did the assemblies take to finish?__
3. __Which sample gave the longest contig?__

### Long-read assembly with metaFlye
We will also assemble the Nanopore data using `metaFlye` (which is actually the genome assembler `Flye` but with different settings that are optimized for metagenomes).  
You can read more about `Flye/metaFlye` [here](https://github.com/fenderglass/Flye).

The script we are using to run `metaFlye` is quite simple, but let's take a look at it using `less` (the script is located in `Scripts/METAFLYE.sh`).  

Again, we are not actually running the long-read assembly as this takes some time.  
Instead, you will find the assemblies already made in `Share/ASSEMBLY_METAFLYE`.  
Let's make soft link to the assembly folder as we have done before for `megahit`:

```bash
cd ~/physalia_metagenomics
ln -s ~/Share/ASSEMBLY_METAFLYE/ ./
```

Using `less`, look at the log files from `metaFlye` that are inside this folder (`Sample03.metaflye.log.txt` and `Sample04.metaflye.log.txt`) and answer the questions below.

#### Questions about the assembly
1. __How many contigs do we have in each assembly?__
2. __What is the total assembly lenght of each assembly?__

The downside of Nanopore (at the moment), is a somewhat higher error rate than Illumina.  
But because we have sequenced the same samples using both Illumina and Nanopore, we can take advantage of the longer reads from Nanopore and the better error rates from Illumina.  
We do that by correcting (polishing) the Nanopore assemblies using the short Illumina reads.  
This will be done using `Pilon` ([take a look here](https://github.com/broadinstitute/pilon/wiki)).

Let's take a look at the script that is located in `Scripts/PILON.sh`.  

You will find inside the assemblies folders (`ASSEMBLY_METAFLYE/Sample03` and `ASSEMBLY_METAFLYE/Sample04`) the output from `Pilon`.  
The `pilon.fasta` file is the corrected assembly, and the `pilon.changes` file is a list of every single change that `Pilon` made to the `metaFlye` assemblies.  
Let's take a look at the first few lines of these files using head:

```bash
head ASSEMBLY_METAFLYE/Sample03/pilon.changes
head ASSEMBLY_METAFLYE/Sample04/pilon.changes
```

## Assembly QC

Now we have all the assemblies ready and we can use `metaquast` for quality control.  
Activate the assembly environment if it's not already activated and run metaquast on all short- and long-read assemblies.

But first, have a look at the different options metaquast has with `metaquast -h`.  
You should at least check the options we are using.  
We will run `metaquast` inside a screen using the command `screen`. This way you can do other things or log out while `metaquast` is running and it won't be interrupted.

Mini manual for `screen`:
* `screen -S NAME`- open a screen and give it a session name `NAME`
* `screen`- open new screen without specifying any name
* `screen -ls` - list all open sessions
* `ctrl + a` + `d` - to detach from a session (from inside the screen)
* `screen -r` - re-attach to a detached session
* `screen -rD` - re-attach to a attached session
* `exit` - close the screen and kill all processes running inside the screen (from inside the screen)

```bash
screen -S metaquast
metaquast.py ASSEMBLY_METAFLYE/*/pilon.fasta ASSEMBLY_MEGAHIT/*/final.contigs.fa \
               -o METAQUAST_FAST \
               --threads 2 \
               --fast \
               --max-ref-number 0 &> metaquast.fast.log.txt
```
Detach from the screen with `ctrl+a` + `d`.  
This will take ~10 min.  You can re-attach with `screen -r metaquast` to check whther it has finished.  
After it is done, we will go through the report together. Open the report file in the output folder:

```bash
less METAQUAST_FAST/report.txt
```
#### Questions about the assembly QC

1. __Which assembly has the longest contig when also long reads assemblies are included?__
2. __Which assembly had the most contigs?__
3. __Were the long read assemblies different from the corresponding short read assemblies?__
4. __If yes, in what way?__
