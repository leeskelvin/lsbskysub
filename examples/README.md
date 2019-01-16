# examples

Some basic examples, testing the capabilities of GalSim

## example01

A simple de Vaucouleurs bulge + exponential disk, with 25 added star-forming knots at 1% of the disk level. Poisson noise added, and image convolved with a Moffat PSF.

## example02

A test at reading in catalogue data from an external file. A similar galaxy as in example01 is used, with a varying SF knot flux from 1-15% (ensuring always that knot flux + disk flux = 90%).

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

