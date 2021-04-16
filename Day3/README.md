# Day 3

| Time      | Activity                      | Slides                                 | Hands-on                          |
|-----------|-------------------------------|----------------------------------------|-----------------------------------|
| Morning   | Assembly of metagenomes       | [Link here](read-based-analyses-2.pdf) | [Link here](#metagenome-assembly) |
| Afternoon | Assembly QC                   |                                        | [Link here](#assembly-qc)         |

## Metagenome assembly

Log in to AWS with the IP provided.

First thing to do is to pull all possible cvhanges in the Github repository

```bash
cd physalia_metagenomics
git pull origin main
```


### Assembly QC

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
