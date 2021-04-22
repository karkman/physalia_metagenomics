# Day 4

| Time      | Activity            | Slides                               | Hands-on                          |
|-----------|---------------------|--------------------------------------|-----------------------------------|
| Morning   | Genome-resolved metagenomics         | [Link here](genome-resolced-metagenomics.pdf) | [Link here](#genome-resolved-metagenomics) |
| Afternoon | Genome-resolved metagenomics cont'd  |                                      |          |

## Genome-resolved metagenomics

Next step in our analysis is genome-resolved metagnomics using anvi'o. Again running all steps needed for generating the necessary files would take more time and resources for everyone to do it, so we have made a tutorial set for you. It's a subset taken from Sample03.

### Tunneling the interactive interafce

Although you can install anvi'o on your own computer (and you're free to do so, but we won't have time to help in that), we will run anvi'o in the cloud and tunnel the interactive interface to your local computer.  
To be able to to do this, everyone needs to use a different port for tunneling and your port will be __8080 + you user number__. So `user1` will use port 8081.

To connect to the cloud with your port (Linux/Mac):

```bash
ssh -L PORT:localhost:PORT USERX@IP-ADDRESS
```

And in windows using Putty:  
In SSH tab select "tunnels". Add:  
- Source port: PORT  
- Destination: localhost:PORT  

Click add and connect as usual.

Before doing anything else, again pull the changes from Github.

```bash
cd physalia_metagenomics
git pull origin main
```

Then we can start to work with our data in anvi'o.  
Activate anvi'o v.7 virtual environment and copy the folder containing the tutorial files to you own course folder. Go to the folder and see what it contains.

```bash
conda activate anvio-7
cp -r ../Share/ANVI-TUTORIAL .
cd ANVI-TUTORIAL
ls -l
```
You should have there the `CONTIGS.db` and `PROFILE.db` plus an auxiliary data file called `AUXILIARY-DATA.db`.

First have a look at some basic statistics about the contigs database.  
*__NOTE!__ You need to specify your port.*

```bash
anvi-display-contigs-stats CONTIGS.db -P PORT
```
Now anvi'o tells you to the servr address. It shoudl contain your port number. Copy-paste the address to your favourite browser. Chrome is preferred.

One thing before starting the binning, let's check what genomes we might expect to find from our data based on the single-copy core genes (SCGs).

```bash
anvi-estimate-scg-taxonomy -c CONTIGS.db \
                           -p PROFILE.db \
                           --metagenome-mode \
                           --compute-scg-coverages

```

Then you can open the interactive interface and explore our data and the interface.  
*__NOTE!__ You need to specify your port in here as well.*

```bash
anvi-interactive -c CONTIGS.db -p PROFILE.db -P PORT
```

You might notice that it's a bit slow to use sometimes. Even this tutorial data is quite big and anvi'o gets slow to use when viewing the whole data. So next step is to split the data in to ~ 5-8 clusters (__bins__) that we will work on individually.

Make the clusters and store them in a collection called `PreCluster`. Make sure that the bins are named `Bin_1`, `Bin_2`,..., `Bin_N`. (or anything else easy to remember).  
Then you can close the server from the command line.

Next we'll move on to manually refine each cluster we made in the previous step. We'll do this to each bin in our collection called `PreCluster`.  

To check your collections and bins you can run `anvi-show-collections-and-bins -p PROFILE.db`

If you know what you have, go ahead and refine all the bins on your collection.
After refining, remember to store the new bins and then close the server from command line and move on to the next one.

```bash
anvi-refine -c CONTIGS.db -p PROFILE.db -C COLLECITON_NAME -b BIN_NAME -P PORT
```

After that's done, we'll rename the bins to a new collection called `PreliminaryBins` and add a prefix to each bin.

```bash
anvi-rename-bins -c CONTIGS.db -p PROFILE.db --collection-to-read Precluster --collection-to-write PreliminaryBins --prefix Preliminary --report-file REPORT_PreliminaryBins
```
Then we can also make a summary of the bins we have in our new collection `PreliminaryBins`.

```bash
anvi-summarize -c CONTIGS.db -p PROFILE.db -C PreliminaryBins -o SUMMARY_PreliminaryBins
```
After that's done, copy the summary folder to your local machine ands open `index.html`.

From there you can find the summary of each of your bins. In the next step we'll further refine each bin that meets our criteria for a good bin but still has too much redundancy. In this case completeness > 50 % and redundancy > 5 %. So refine all bins that are more than 50 % complete and have more than 5 % redundancy.

When you're ready it's time to again rename the bins and run the summary on them.  
Name the new collection `Bins` and use prefix `Sample03`.

Now we should have a collection of pretty good bins out of our data. The last step is to curate each bin to make sure it represent only one population. And finally after tthat we can call MAGs from our collection.
