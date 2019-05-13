# GNU Astro Optimisation notes

## Final phase testing

### tilesize [30,30]

30x30 a definite maximum. Attempted 60x60, with worsening in recovered sky levels and recovered areas. 

Improvements recorded for 15x15 and 12x12. 

10x10 failed, owing to '0 tiles usable after removing outliers!', i.e., tile size is too small to produce any valid tiles. 

Compromise at 15x15 tilesize, as smaller runs the risk of producing zero usable tiles for differing datasets. 

### largetilesize [200,200]

Attempted 500x500 and 50x50, negligible difference. Opt to maintain default 200x200.

### kernel [2,5]

Attempted FWHMs of 2,3,3.5,3.75,4,5

Larger kernel sizes (4,5) failed due to '0 usable clumps found in the undetected regions.' This makes automated progression difficult, as the software quits with an error after this point. 

Continual improvement (i.e., reduction) in recovered sky level up to 3.75, however, reduction in recovered area of largest 5 objects moving beyond 3.5. In addition, sky level over-subtracted for simulated bright-only images.

Conclude that larger kernel is better down to 3.5 --> beyond this, sky level oversubtracted and largest object area reduced. 

NB - kernel filtering switched to 'none' at segmentation stage, as filtering has significant impact on shredding large sources - factor of ~2 (in disks) to ~4 (in spheroids) reduction in area when adopting same kernel as noisechisel stage. Minimum impact for majority of sources. 

### meanmedqdiff [0.005]

The maximum acceptable distance between the quantiles of the mean and median in each tile. 

Tried 0.05,0.01,0.001,0.002,0.0005

Too large (i.e., 0.05) failed owing to '0 usable clumps found in the undetected regions.'

Debatable whether or not an increase (to 0.01) or a decrease (to 0.001) is superior. Increasing improves sky levels and areas, with the exception of spheroid-like sources. However, it also pushes recovered sky levels far below zero, i.e., oversubtraction, in the case of bright-only simulated images. 

Choice of 0.002 seems appropriate, as optimises sky/areas in most cases, yet tempers sky-oversubtraction in case of bright-only spheroid-like sources. Also, 0.002 produces more consistent results (similar sky levels recovered), performs better in high-density spheroid-like environment (most difficult), and returns fewer errors than much larger or smaller values. 

### qthresh [0.3]

Attempted 0.1.0.2,0.25,0.5

Smallest values (i.e., 0.1,0.2) failed, due to '0 usable clumps found in the undetected regions.'

Smaller than default (0.25) reduces sky level across the board, resulting in close to optimal results in A case, yety significant over-subtraction in B case. 

Larger than default (0.5) undoes all prior optimisation, resulting in minimal change from defaults. 

Opt to maintain default level (0.3).

### noerodequant [0.99]

Pixels with a value larger than this will not be eroded. Reducing this value preserves more sharp/small objects.

Attempted 0.69 (0.5 sigma), 0.84 (1 sigma), 0.98 (2 sigma), 0.999 (3 sigma), and 0.99997 (4 sigma).

Smallest value (0.69) failed due to '0 usable clumps found in the undetected regions.'

Smaller values (0.84/0.98) reduce sky level, too much in B case. In addition, undoes area recovered in spheroid cases. 

Larger values produce optimal results, but too larger errs on the side of significantly under-estimating sky in B case. 

Opt to increase value to 0.999. 

### minskyfrac [0.7]

Attempted 0.5,0.6,0.8,0.85,0.9,0.95

Smaller values reduce sky level significantly, leading to over-subtraction in B cases (and almost A cases). 

Larger values seem to produce more optimal results. Beyond 0.9 (i.e., 0.95) sky level becomes too high. 

Opt for 0.90 as chosen value. 

### snquant [0.99]

Attempted 0.84, 0.999, 0.99997

Opted for 0.999.

### minskyfrac (segment) [0.6]

Attempted 0.5,0.7



## Previous notes

### tilesize [30,30]
Negligible impact on recovered sky level and number of detected objects

### largetilesize [200,200]
Negligible impact on recovered sky level and number of detected objects

### kernel
Switching from the default kernel (2D Gaussian, FWHM=2 pixels, truncation=5xFWHM) to a large kernel increases both accuracy of sky and total number of detected objects. We opted for a 2D Gaussian with FWHM=3 pixels, truncation=3.5xFWHM.

### meanmedqdiff (default=0.005)
The maximum difference between the quantiles of the mean and median in each tile, used to accept/reject sky tiles. Smaller values seemed more optimal, tightening this constraint. Values of 0.002 and 0.001 attempted, with the latter favourable.

### qthresh
The quantile threshold applied to the convolved image

### noerodequant

### minskyfrac

