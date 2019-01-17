# examples

Some basic examples, testing the capabilities of GalSim

## example01

A simple de Vaucouleurs bulge + exponential disk, with 25 added star-forming knots at 1% of the disk level. Poisson noise added, and image convolved with a Moffat PSF.

## example02

A test at reading in catalogue data from an external file. A similar galaxy as in example01 is used, with a varying SF knot flux from 1-15% (ensuring always that knot flux + disk flux = 90%).

![example02](https://raw.githubusercontent.com/leeskelvin/lsbskysub/master/examples/output/example02.jpeg)

## example03

Showing the ability to pull multiple files from one YAML document. Here I output the convolution PSF first, before outputting the convolved galaxy image second. This necessitates the use of two '---' dividers, splitting the document into three parts: A) global properties, B) output the PSF image, C) output the galaxy image. To quote the demo text, this does this:

> &#35; The multiple yaml documents are separated by a line with three dashes "---"  
> &#35; The first document has all the parts that are common to all the output files.  
> &#35; Then each subsequent document defines its particular additions to that base.  
> &#35; These are combined with the first document's information for processing.  
> &#35; So if we start numbering the documents at 0, we effectively process:  
> &#35;   doc[0] + doc[1]  
> &#35;   doc[0] + doc[2]  
> &#35;   doc[0] + doc[3]  
> &#35;   ...  

## example04

Using the index Sequence type to repeat each item in a list a given number of times. 

## example05

Testing the ability for GalSim to randomly assign object properties, in this case galaxy size (half light radius) via the 'dilate' argument.

Additionally, postage stamps of 64x64 pixels are constructed on a 10x10 grid, and output to a single FITS file. A zero count border of 1 pixel in the x direction and 5 pixels in the y direction is included, for clarity.

## example06

First attempt at generating an image with multiple galaxies. This image contains 100 'InclinedExponential' galaxies randomly scattered across the field of view. Flux values are drawn from a power law distribution. Other key parameters are drawn from random uniform distributions. A flat sky pedestal is assumed in order to calculate Poisson noise for each pixel. 

This example also outputs the input parameters into a catalogue for later further processing. GalSim can be instructed to use all available processors in order to speed up the image generation process.

Two output images are constructed: with and without noise. To facilitate this in a single file, use of the above '---' divider notation is required.

![example06](https://raw.githubusercontent.com/leeskelvin/lsbskysub/master/examples/output/example06.jpeg)

<img alt="example06panel" src="https://raw.githubusercontent.com/leeskelvin/lsbskysub/master/examples/output/example06_panel.jpeg" width="800px">

![example06_panel](https://raw.githubusercontent.com/leeskelvin/lsbskysub/master/examples/output/example06_panel.jpeg | width=800)

