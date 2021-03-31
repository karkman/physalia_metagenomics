# Day 1

| Time      | Activity                          | Slides                                          | Hands-on                                    |
|-----------|-----------------------------------|-------------------------------------------------|---------------------------------------------|
| Morning   | Course outline and practical info | [Link here](course-outline.pptx)                |                                             |
| Morning   | Introduction to metagenomics      | [Link here](introduction-to-metagenomics.pptx)  |                                             |
| Morning   | Working with the command line     | [Link here](working-with-the-command-line.pptx) | [Link here](#working-with-the-command-line) |
| Afternoon | QC and trimming                   | [Link here](QC-and-trimming.pptx)               | [Link here](#qc-and-trimming)               |
| Afternoon | Launching the read-based analyses |                                                 | [Link here](#read-based-analyses)           |

## Working with the command line

- Time for some exercise for those who do not have experience with UNIX
- Link to a coursera/codeacademy course?

## QC and trimming

**This is my idea on how things will go**

- Connect to the server
- Create a directory for you

```bash
mkdir $USER
cd $USER
```
- Clone this repository (for scripts)

```bash
git clone https://github.com/karkman/physalia_metagenomics
```

- Raw data is already there in the server (folder RAWDATA)
- Run Cutadapt

```bash
bash physalia_metagenomics/Scripts/CUTADAPT.sh
```

**Alternatively, they will get the scripts from GitHub and type/copy+paste directly in the terminal?**


## Read-based analyses

We will launch the read-based analyses now so it is finished in time for tomorrow morning.  

- Connect to the server
- Open a "screen" so you can leave things running overnight

```bash
screen -S megan
```
- Go to your directory
- Run

```bash
bash physalia_metagenomics/Scripts/MEGAN.sh
```

- Close the screen with Ctrl+a+d
