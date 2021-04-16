# Day 3

| Time      | Activity                      | Slides                                 | Hands-on                          |
|-----------|-------------------------------|----------------------------------------|-----------------------------------|
| Morning   | Read-based analyses (Part 2)  | [Link here](read-based-analyses-2.pdf) | [Link here](#read-based-analyses) |
| Afternoon | Read-based analyses (Part 3)  |                                        | [Link here](#read-based-analyses) |

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
