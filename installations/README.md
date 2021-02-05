# Installations for the course

## Virtual environments - miniconda3

Download the installation script from XXX and install miniconda
```
bash ...
```

## Hybrid assembly - OPERA-MS

Create the virtual environment for OEPRA-MS
```
conda env create -f opera-ms.yml
```

Activate the environment and install OPERA-MS from Github

```
git clone https://github.com/CSB5/OPERA-MS.git
cd OPERA-MS
make
```
