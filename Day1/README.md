# Day 1

| Time      | Activity                          | Slides                                                | Hands-on                                    |
|-----------|-----------------------------------|-------------------------------------------------------|---------------------------------------------|
| Morning   | Course outline and practical info | [Link here](course-outline.pdf)                       |                                             |
| Morning   | Introduction to metagenomics      | [Link here](intro-to-metagenomics.pdf)                |                                             |
| Morning   | Working with the command line     | [Link here](working-with-the-command-line.pdf)        | [Link here](#working-with-the-command-line) |
| Afternoon | Setting up the Amazon Cloud       |                                                       | [Link here](#setting-up-the-amazon-cloud)   |
| Afternoon | QC and trimming                   | [Link here](QC-and-trimming.pdf)                      | [Link here](#qc-and-trimming)               |

## Working with the command line
Most of our activities will be done using the Unix command line (aka Unix shell).  
It is thus highly recommend to have at least a basic grasp of how to get around in the Unix shell.  
We will now dedicate one hour or so to follow some basic to learn (or refresh) the basics of the Unix shell.  
**Windows users:** Open [this terminal emulator](https://bellard.org/jslinux/vm.html?url=alpine-x86.cfg&mem=192) in a new window.  
**MacOS/Linux:** Launch terminal on your machine.

### Playing around with basic UNIX commands

#### Important notes

Things inside a box like this...

```bash
mkdir unix_shell
cd unix_shell
```
...represent commands you need to type in the shell. Each line is a command. Commands have to be typed in a single line, one at a time. After each command, hit “Enter” to execute it.

Things starting with a pound sign (or hashtag)...

```bash
# This is a comment and is ignored by the shell
```

...represent comments embedded in the code to give instructions to the user. Anything in a line starting with a `#` is ignored by the shell. You can type it if you want, but nothing will happen (provided you start with a `#`).

We will be using different commands with different syntaxes. Different commands expect different types of arguments. Some times the order matters, some times it doesn't. If you are unsure, the best way to check how to run a command is by taking a look at its manual with the command `man`. For example, if you want to look at the manual for the command `mkdir` you can do:

```bash
man mkdir

# You can scroll down by hitting the space bar
# To quit, hit "q"
```

#### Creating and navigating directories

First let's see where we are:

```bash
pwd
```

Are there any files here? Let's list the contents of the folder:

```bash
ls
```

Let's now create a new folder called `unix_shell`. In addition to the command (`mkdir`), we are now passing a term (also known as an argument) which, in this case, is the name of the folder we want to create:

```bash
mkdir unix_shell
```

Has anything changed? How to list the contents of the folder again?

<details>
<summary>
HINT (CLICK TO EXPAND)
</summary>

> ls

</details>  

---

And now let's enter the `unix_shell` folder:

```bash
cd unix_shell
```

Did it work? Where are we now?

<details>
<summary>
HINT
</summary>

> pwd

</details>  

#### Creating a new file

Let's create a new file called `myfile.txt` by launching the text editor `nano`:

```bash
nano myfile.txt
```

Now inside the nano screen:

1. Write some text

2. Exit with ctrl+x

3. To save the file, type **y** and hit "Enter"

4. Confirm the name of the file and hit "Enter"

List the contents of the folder. Can you see the file we have just created?


#### Copying, renaming, moving and deleting files

First let's create a new folder called `myfolder`. Do you remember how to do this?

<details>
<summary>
HINT
</summary>

> mkdir myfolder

</details>  

---

And now let's make a copy of `myfile.txt`. Here, the command `cp` expects two arguments, and the order of these arguments matter. The first is the name of the file we want to copy, and the second is the name of the new file:

```bash
cp myfile.txt newfile.txt
```

List the contents of the folder. Do you see the new file there?  

Now let's say we want to copy a file and put it inside a folder. In this case, we give the name of the folder as the second argument to `cp`:

```bash
cp myfile.txt myfolder
```

List the contents of `myfolder`. Is `myfile.txt` there?

```bash
ls myfolder
```

We can also copy the file to another folder and give it a different name, like this:

```bash
cp myfile.txt myfolder/copy_of_myfile.txt
```

List the contents of `myfolder` again.  Do you see two files there?

Instead of copying, we can move files around with the command `mv`:

```bash
mv newfile.txt myfolder
```

Let's list the contents of the folders. Where did `newfile.txt` go?

We can also use the command `mv` to rename files:

```bash
mv myfile.txt myfile_renamed.txt
```

List the contents of the folder again. What happened to `myfile.txt`?

Now, let's say we want to move things from inside `myfolder` to the current directory. Can you see what the dot (`.`) is doing in the command below? Let's try:

```bash
mv myfolder/newfile.txt .
```

Let's list the contents of the folders. The file `newfile.txt` was inside `myfolder` before, where is it now?  

The same operation can be done in a different fashion. In the commands below, can you see what the two dots (`.`) are doing? Let's try:

```bash
# First we go inside the folder
cd myfolder

# Then we move the file one level up
mv myfile.txt ..

# And then we go back one level
cd ..
```

Let's list the contents of the folders. The file `myfile.txt` was inside `myfolder` before, where is it now?  

We have so many identical files in our folders. Let's clean things up and delete some files :

```bash
rm newfile.txt
```

Let's list the contents of the folder. What happened to `newfile.txt`?  

When deleting files, pay attention in what you are doing: **if you accidently remove the wrong file, it is gone forever!**

And now let's delete `myfolder`:

```bash
rm myfolder
```

It didn't work did it? An error message came up, what does it mean?

```bash
rm: cannot remove ‘myfolder’: Is a directory
```

To delete a folder we have to modify the command further by adding the recursive flag (`-r`). Flags are used to pass additional options to the commands:

```bash
rm -r myfolder
```

PS: the following command also works, but only if the folder is empty:

```bash
rmdir myfolder
```

Let's list the contents of the folder. What happened to `myfolder`?  

## Setting up the Amazon Cloud

### Connecting to the server
For most of the analyses we will use the Amazon cloud services.  
The IP address of the Amazon cloud instance will change every day, we will provide it to you at the start of the activities.   
Your username - that you have received by e-mail - will be the same for the whole course.  
The list of usernames can be found in Slack (#before-start).  
More information on how to connect to the Amazon cloud instance also in Slack (#before-start), but also [here](connecting-to-the-amazon-EC2-service.pdf).

### Copying the course's GitHub repository
Once you have connected to the server, you will see your home folder.  
**Remember**: You can check where you are with the command `pwd`.  

To have access to the scripts and some of the data, let's copy this GitHub repository to your home folder using `git clone`:

```bash
git clone https://github.com/karkman/physalia_metagenomics
```

You should now have a folder called **physalia_metagenomics** in there.  
**Remember**: You can check the contents of the folder with the command `ls`.  

We might update this repository during the course.  
To get the latest updates, pull the changes from GitHub using `git pull`:

```bash
cd physalia_metagenomics
git pull
```

This physalia_metagenomics folder within your home directory is where everything will be run (aka working directory).  
So remember, **everytime you connnect to the server**, you have to `cd physalia_metagenomics`.  
Every once in a while, also run `git pull` to get the newest version of this repository.

### Getting the raw data
Now let's make a folder for the raw data (remember to `cd` to the physalia_metagenomics folder first if you are not yet inside it):

```bash
mkdir RAWDATA
```

To save disk space (and because copying large files takes time), the raw data will be stored in a shared folder.  
This folder is located in `~/Share`.  
To make things more smooth, we will create softlinks to these files inside your working directory:

```bash
ln -s ~/Share/RAWDATA/* RAWDATA
```

### Setting up conda
Most of the programs are pre-installed on the server using [conda](https://docs.conda.io/projects/conda/en/latest/index.html) virtual environments.  
First we need to setup the general conda environment:

```bash
conda init
```

Now either logout of the server and log back in, or run `source .bashrc`.  
This step only has to be run once.  

## QC and trimming
Now we should have softlinks to the raw data and can start the QC and trimming.   
We will use `FastQC`and `MultiQC` for the QC, `Cutadapt` for the trimming of Illumina data and `Porechop` for the trimming of Nanopore data.  

### QC of the raw data
Go to the raw data folder, create a folder for the QC files and activate the `conda` environment:

```bash
cd RAWDATA
mkdir FASTQC
conda activate QC_env
```
And now you're ready to run the QC on the raw data:

```bash
fastqc *.fastq.gz -o FASTQC -t 4
multiqc FASTQC/* -o FASTQC -n multiqc.html
```

After the QC is finished, copy the `MultiQC` report (`multiqc.html`) to your local machine using FileZilla and open it with your favourite browser.  
We will go through the report together before doing any trimming.  

### Read trimming
The trimming scripts are provided and can be found from the `Scripts` folder.  
First go back one level (i.e. back to the `physalia_metagenomics` folder).  
Then open the script file on the server using `vim`:

```bash
vim Scripts/CUTADAPT.sh
```

**NOTE:** To quit `vim` type `:q` and press Enter.  
And now the Porechop script:

```bash
vim Scripts/PORECHOP.sh
```

We wil go through the different options together.  
But you can take a look at the manual for `Cutadapt` [here](https://cutadapt.readthedocs.io/en/stable/index.html), and for `Porechop` [here](https://github.com/rrwick/Porechop).  

Now let's launch the trimming scripts, one at a time:

```bash
bash Scripts/CUTADAPT.sh
bash Scripts/PORECHOP.sh
```

### QC of the trimmed data
The trimming step will actually take a while and it's very likely that the jobs won't finish in a reasonable time.  
For the purposes of this activity, it is enough if 1) we understand what the script is doing and 2) we are able to submit the script without any errors.  
So now let's stop the script by hitting **ctrl+c**.
Luckily, we have a copy of the trimmed data in the `Share` folder, so let's again create softlinks:

```bash
ln -s -f ~/Share/TRIMMED/* TRIMMED
```

**NOTE:** We have now added the `-f` flag to the `ln` command to force overwrite of files that may have been created when we tried to run the script.  

Because we used redirection (`>`) to capture the output (`stdout`) of `Cutadapt` and `Porechop`, this information is now stored in a file.  
Let's take a look at the `Cutadapt` log for Sample01 using `less`:

```bash
less TRIMMED/Sample01.cutadapt.log.txt
```

**NOTE:** You can scroll up and down using the arrow keys on your keyboard, or move one "page" at a time using the spacebar.  
**NOTE:** To quit `less`, hit the letter **q**.  

By looking at the `Cutadapt` log, can you answer:

- How many read pairs we had originally?
- How many reads contained adapters?
- How many read pairs were removed because they were too short?
- How many base calls were quality-trimmed?
- Overall, what is the percentage of base pairs that were kept?

We can also take a look at how the trimmed data looks by running the QC steps (`FastQC` and `MultiQC`) again.  
So let's run `FastQC` and `MultiQC` again for the trimmed data.  

**REMEMBER**:
- To check where you are with `pwd`.
- To `cd` to the `TRIMMED` folder.
- To create the `FASTQC` folder.  

When you have finished, copy the `MultiQC` report to yor local machine using FileZilla and open it with a browser.  
Compare this with the report obtained earlier for the raw data.  
Does the data look better now?
