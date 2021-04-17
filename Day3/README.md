# Day 3

| Time      | Activity                      | Slides                                 | Hands-on                          |
|-----------|-------------------------------|----------------------------------------|-----------------------------------|
| Morning   | Assembly of metagenomes       | [Link here](read-based-analyses-2.pdf) | [Link here](#metagenome-assembly) |
| Afternoon | Assembly QC                   |                                        | [Link here](#assembly-qc)         |

## Github setup

Log in to our cloud instance with the IP provided.  
First thing to do is to pull all possible changes in the Github repository

```bash
cd physalia_metagenomics
git pull origin main
```

## Metagenome assembly

After that we're gonna go through the metagenomic assembly part, but not run the actual assembly script.  
The assembly takes days and needs more resources than we have on our instance.
So the assemblies will be provided.  

### Short-read assembly with megahit
The short reads will be assembled using `megahit`. Although, we won't be running the actual assembly, `megahit` is installed on our instance.  

So have a look at the different options you can change in the assembly.  
You can find more information about `megahit` from the [megahit wiki](https://github.com/voutcn/megahit/wiki). You don't need to understand each and every option, but some of them can be important.

```bash
conda activate assembly_env
megahit -h
```

#### Questions about the megahit
1. __What do you think would be important? What would you change or set?__  
2. __What version of megahit have we installed? Is it the latest?__

After that have a look at the assembly script `Scripts/MEGAHIT.sh`. Open it with a text editor or print it on the screen with `less`.  

__Would you have changed something else and why?__

When we're satisfied with the assembly options, we would start the assembly and wait from few hours to several days depending on your data and computational resources.  
But we won't do it, since we don't have to time or the resources. Instead, you can copy the assemblies and log files to your own folder from `Share/ASSEMBLY_MEGAHIT/`. First open the assembly log files.

Questions:
1. __Which version did we actually use for the assemblies?__
2. __How long did the individual assemblies take?__
3. __Which sample gave the longest contig?__

### Long-read assembly with metaFlye

_Igor adds this part_


## Assembly QC

Now we have all the assemblies ready and we can use `metaquast` for quality control.  Activate the assembly environment if its not already activated and run metaquast all short and long read assemblies.
First have a look at the different options meatquast has with `metaquast -h`.  
You should at least check the options we are using.

```bash
metaquast.py ASSEMBLY_METAFLYE/*/pilon.fasta ASSEMBLY_MEGAHIT/*/final.contigs.fa \
               -o METAQUAST_FAST \
               --threads 2 \
               --fast \
               --max-ref-number 0 &> metaquast.fast.log.txt
```

Assembly QC takes ~15 min. After it is done, we will go through the report together.   
Open the report file in the output folder.

```bash
less METAQUAST_FAST/report.txt
```
