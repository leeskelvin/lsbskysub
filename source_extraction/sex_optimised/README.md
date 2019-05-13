# SExtractor Optimisation notes

## Final phase testing

### BACK_SIZE [64] / BACK_FILTERSIZE [3]

BACK_SIZE from 512,256,128,64,32 tried. 

Mesh size 64 optimal for mean of all sources. 

Mesh size 512 optimal for mean of largest 5 sources. Smaller sizes reduce recovered area by ~few percent. 

Compromise at 256, with a filtersize of 5x5. 

SExtractor seems to struggle when area of interest of largest source crosses ~25% boundary. Strongly field density dependent. Larger mesh sizes better, but trade off in picking up small scale structure in the sky background. 

Impossible to choose one mesh size which is suitable for all sources (requires two or more runs).

Sph-like worsens first, at larger BACK_SIZEs. 

Disk-like more robust down to smaller BACK_SIZEs.

## Previous notes

Values represent offsets from default

### kernel

* 1,3.5 : ndet +2500
* 2,3.5 : ndet -200
* 3,3.5 : ndet -700
* 4,3.5 : ndet -1000
* 5,3.5 : ndet -1600
* 2,10 : ndet -200
* 2,1 : ndet 0

### BACK_SIZE [64]

* 16 : sky +0.002, ndet ~0
* 32 : sky ~0, ndet ~0
* 128 : sky ~0, ndet -50
* 256 : sky ~0, ndet -75
* 512 : sky ~0, ndet -100
* 1024 : sky ~0, ndet -125
* 2048 : sky +0.001, ndet -75
* 4096 : sky ~0, ndet -50

### BACK_FILTERSIZE [3]

* 1 : sky +0.001, ndet -25
* 5 : sky ~0, ndet ~0
* 7 : sky ~0, ndet +10
* 9 : sky ~0, ndet +10
* 11 : sky ~0, ndet +10

### DETECT_THRESH / ANALYSIS_THRESH [1.5]

* 0.5 : ndet +70000
* 1.0 : ndet + 4000
* 2.0 : ndet -1000
* 2.5 : ndet -1500

### DEBLEND_MINCONT [0.005]

* 0.0000005 : ndet +100
* 0.000005 : ndet +100
* 0.00005 : ndet +100
* 0.0005 : ndet +75
* 0.05 : ndet -100
* 0.5 : ndet -150

