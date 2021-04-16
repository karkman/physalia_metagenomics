# Day 2

| Time      | Activity                      | Slides                                 | Hands-on                          |
|-----------|-------------------------------|----------------------------------------|-----------------------------------|
| Morning   | Read-based analyses (Part 1)  | [Link here](read-based-analyses-1.pdf) | [Link here](#read-based-analyses) |
| Morning   | Read-based analyses (Part 2)  | [Link here](read-based-analyses-2.pdf) | [Link here](#read-based-analyses) |
| Afternoon | Read-based analyses (Part 3)  |                                        | [Link here](#read-based-analyses) |

## Read-based analyses

First login to the Amazon Cloud and `cd` to your working directory.  
For the read-based analyses, we will use `seqtk`, `DIAMOND`, `MEGAN` and `METAXA`.
Like yesterday, the script is provided and can be found from the `Scripts` folder.  
Let's take a look at the script using `less`:

```bash
less Scripts/READ_BASED.sh
```

You can scroll up and down with the arrow keys if the text do not fit entirely in your screen.  
To quit `less`, hit the letter **q**.  
As you will see, we are first running `seqtk` to subsample the data to an even number of sequences per sample (2,000,000).  
Then we are running `DIAMOND` to annotate the reads against the NCBI nr database.  
Then we will use `MEGAN` to parse the annotations and get taxonomical and functional assignments.  
In addition to `DIAMOND` and `MEGAN`, we will also use a different approach to get taxonomical profiles using `METAXA`.  
This will happen in two steps: the first command finds rRNA genes among our reads, and the second summarises the taxonomy.  

Now let's run the script:

```bash
bash Scripts/READ_BASED.sh
```



## Read-based analyses

First let's re-open the "screen" from yesterday and see if our script has finished running.

- Connect to the server
- Re-open the "screen" from yesterday:

```bash
screen -r read_based
```

Is the script still running? How can you tell?  

If the script hasn't finished yet:
- Stop it by pressing **Ctrl+c**
- At this point we can close the screen permanently by typping **exit**.  

### MEGAN

Let's take a look at the folder MEGAN **in the course main folder**:

```bash
ls MEGAN
```

For each sample, you will find:
- $SAMPLE.blastx.txt: DIAMOND output
- $SAMPLE.diamond.log.txt: DIAMOND log
- $SAMPLE.rma6: MEGAN output
- $SAMPLE.megan.log.txt: MEGAN log

Now let's copy the .rma6 files to our own computers using FileZilla.

### METAXA
