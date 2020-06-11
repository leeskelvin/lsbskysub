#!/Usr/bin/env python
# coding: utf-8
from os.path import join
import glob
import numpy as np
import matplotlib.pyplot as plt
from astropy.io import fits
import pandas as pd
import matplotlib
from matplotlib import colors
matplotlib.style.use('seaborn-poster')
matplotlib.style.use('seaborn-poster')
import pdb

import lsst.afw.image as afwImage
import lsst.afw.display as afwDisplay
from lsst.ip.isr.isrFunctions import updateVariance
from lsst.pipe.tasks.characterizeImage import CharacterizeImageTask, CharacterizeImageConfig
from lsst.afw.math import BackgroundList
import lsst.afw.detection as afwDet
import lsst.afw.geom as afwGeom
import lsst.afw.table as afwTable

class ProcessGalsim():
    '''
    A task to process galsim data. We run the CharacterizeImageTask with a few
    modifications. This is because we wish to install a psf, do detection, deblending
    measurement and background estimation, which CharacterizeImage takes care of nicely
    Several methods here are simply to set up the image data as ExposureF's for the stack
    to deal with. This expects a directory parallel to the one you are running this program
    in named 'sims' which holds the simulated galsim images
    parameters:

    input:
    ------
    file list: a python list of strings containing the names of files you wish
    to process.
    doCmodel: False by default, a boolean stating if you want cModel photometry or not
    threshold: a float, the detection threshold
    psf: None by default. If you have a PSF object you wish to use for the exposures you can
    enter it here

    output:
    -------
    for every file in file_list you get the following in the directory ../dm_output
    filename.csv: a csv file of the measurement process output
    det_filename: a fits image, the detection plane of the input file
    bg_filename: a fits image, the full resolution background model
    '''

    def __init__(self, file_list, doCModel=False, threshold=5.0, psf=None):
        self.sims_path = '../sims/'
        self.out_path = '../dm_output'
        self.file_list = file_list
        self.doCModel = doCModel
        self.gain = 1
        self.threshold = threshold
        self.config = self.setupCharConfig(self.doCModel)
        self.charTask = self.setupCharTask()
        self.psf = psf

    def run(self):
        '''
        run method. this will set up exposures, perform detection, measurement,
        deblending, bg estimation, psf instillation etc on all files in file list
        and produce their output
        '''
        for file in self.file_list:
            print('working on {}'.format(file))
            exposure = self.setupExposure(file)
            charRes = self.charTask.run(exposure)
            self.writeOutput(charRes, file)

    def run_single(self, f):
        '''
        an option to run a single frame through the pipeline
        f: python string with the file name of the galsim image you wish to processs
        '''
        exposure = self.setupExposure(f)
        charRes = self.charTask.run(exposure)
        return charRes

    def setupCharConfig(self, doCmodel=False):
        '''
        create the config for CaracterizeImageTask. Set up appropriate
        configurations for galsim data
        '''
        charConfig = CharacterizeImageConfig()
        # switch these off for simulated data
        charConfig.doMeasurePsf = False
        charConfig.doApCorr = False
        charConfig.repair.doCosmicRay = False
        charConfig.doDeblend = True

        # threshold detection
        charConfig.detection.thresholdValue = self.threshold
        charConfig.detection.includeThresholdMultiplier = 1.0
        charConfig.detection.minPixels = 1

        # these are parameters Lee set
        charConfig.installSimplePsf.fwhm = 5
        charConfig.installSimplePsf.width = 55

        if self.doCModel:
            charConfig.measurement.plugins.names |= ["ext_shapeHSM_HsmSourceMoments"]
            charConfig.measurement.plugins.names |= ["modelfit_DoubleShapeletPsfApprox", "modelfit_CModel"]
            charConfig.measurement.slots.modelFlux = 'modelfit_CModel'

        return charConfig

    def setupCharTask(self):
        '''
        set up the CharacterizeImageTask task
        '''
        return CharacterizeImageTask(config=self.config)

    def setupExposure(self, file_name):
        '''
        ingest a file and asign its gain, read noise, wcs, variance plane and turn it into
        an afwImageExposure
        '''
        file_path = join(self.sims_path, file_name)
        image_array=afwImage.ImageF.readFits(file_path)

#        image_array.array = image_array.array.T

        image = afwImage.ImageF(image_array)
        exposure = afwImage.ExposureF(image.getBBox())
        exposure.setImage(image)
        readNoise = self.getReadNoise(file_name)
        updateVariance(exposure.maskedImage, self.gain, readNoise)

        if self.psf is not None:
            exposure.setPsf(self.psf)

        # get wcs
        real_calexp = '/global/cscratch1/sd/ihasan/SkyLee/calexp/calexp-HSC-I-8283-38.image.fits.fz'
        expReader = afwImage.ExposureFitsReader(real_calexp)
        wcs = expReader.readWcs()
        exposure.setWcs(wcs)
#        zero_point=27 # place holder
#        calib = lsst.afw.image.Calib()
#        calib.setFluxMag0(zero_point)
#        exposure.setCalib(calib)

        return exposure

    def getReadNoise(self, file_name):
        '''
        assign readnoise. this is infered from the file name
        '''
        density = file_name.partition('calexp-HSC-R-')[2][0:4]
        density = int(density)

        assert density in (8283, 9592), 'cant tell if its high or low density'

        if density == 8283:
            return 557.9267374
        elif density == 9592:
            return 563.9150705

    def writeOutput(self, charRes, file_name):
        '''
        save measurement catalog, background image, and detection plane
        '''
        # save the catalog as an ascii file
        src = charRes.sourceCat

        if not src.isContiguous():
            src = src.copy(deep=True)

        src_csv = src.asAstropy()
        src_csv_outpath = join(self.out_path, file_name+'.csv')
        src_csv.write(src_csv_outpath, format='ascii', delimiter=',', overwrite=True)

        # save the background model as a fits image
        bg = charRes.background
        bg_im = bg.getImage().array
        hdu = fits.PrimaryHDU(bg_im)
        bg_out_path = join(self.out_path, 'bg_'+file_name)
        hdu.writeto(bg_out_path, overwrite=True)

        # save a detection plane
        masked_im = charRes.exposure.getMaskedImage()
        mask_dict = masked_im.getMask().getMaskPlaneDict()
        detect_bit = mask_dict['DETECTED']

        detection_plane = masked_im.getMask().array & 2**detect_bit
        hdu = fits.PrimaryHDU(detection_plane)
        detect_out_path = join(self.out_path, 'det_'+file_name)
        hdu.writeto(detect_out_path, overwrite=True)
        return


#from lsst.meas.algorithms import DynamicDetectionTask, DynamicDetectionConfig
from lsst.pipe.tasks.multiBand import DetectCoaddSourcesConfig, DetectCoaddSourcesTask
from lsst.meas.algorithms.installGaussianPsf import InstallGaussianPsfConfig, InstallGaussianPsfTask
from lsst.meas.deblender import SourceDeblendTask
from lsst.meas.base import SingleFrameMeasurementTask, SingleFrameMeasurementConfig
from lsst.obs.base import exposureIdInfo
from lsst.pipe.base import Struct

class ProcessGalsimOpt(ProcessGalsim):
    '''
    A class that processes galsim data with DetectCoaddSourcesTask instead of CharacterizeImage
    We take advantage of the dynamic detection algorithm inside DetectCoaddSourcesTask that
    will pick up fainter galaxies. This class is inherited from the ProcessGalsim class above
    '''
    def __init__(self, file_list, psf=None):
        self.file_list = file_list
        self.out_path = '/global/cscratch1/sd/ihasan/SkyLee/dm_opt_output'
        self.sims_path = '/global/cscratch1/sd/ihasan/sims'
        self.psf = psf
        self.gain = 1


    def run(self):
        '''
        run method specific to this class
        '''
        print([f for f in self.file_list])
        for f in self.file_int(f)
            exposure = self.setupExposure(f)
            # put in psf
            gpsfConfig = InstallGaussianPsfConfig()
            gpsfConfig.fwhm = 5
            gpsfConfig.width = 55
            installGaussianPsf = InstallGaussianPsfTask(config=gpsfConfig)
            installGaussianPsf.run(exposure)

            # setup all the tasks we need
            # the schema needs to be made first so all tasks
            # know which table to write to
            schema = afwTable.SourceTable.makeMinimalSchema()

         # subaru configs and in detectcoaddsources defaults
            dcconfig.detection.isotropicGrow = True
            dcconfig.detection.doTempWideBackground =   True
            dcconfig.detection.tempWideBackground.binSize = 128
            dcconfig.detection.tempWideBackground.useApprox = False
            dcconfig.detection.reEstimateBackground = True
            dcconfig.detection.background.binSize = 128
            dcconfig.detection.background.usg = SingleFrameMeasurementConfig()
            sourceMeasurementConfig.plugins=["base_PixelFlags",
                 "base_SdssCentroid",
                 "base_NaiveCentroid",
                 "base_SdssShape",
                 "base_GaussianFlux",
                 "base_PsfFlux",

            # you can pass none for exposure id
            idFactory = afwTable.IdFactory.makeSimple()
            result = sourceCoaddDetectionTask.run(exposure, idFactory, None)
          Output(self, goodStuff, file_name):
        # save the catalog as an ascii file
        src = goodStuff.sources

        if not src.isContiguous():
            src = src.copy(deep=True)

        src_csv = src.asAstropy().to_pandas()

        # we need to do some jujitsu to get the footprint area
        # saved in the catalog. we will iterate over the sources in the source table
        # and save the footprint area, then do a join on object id
        farea = [(s.getId(), sea_outpath = join(self.out_path, file_name+'.footprint.txt')
        joined.to_csv(farea_outpath)
#        np.savetext(farea_outpath, np.array(farea))

        # save the background model as a fits image
        bg = goodStuff.backgroundList
        bg_im = bg.getImage().array
        hdu = fits.PrimaryHDU(bg_im)
        bg_out_path = join(self.out_path, 'bg_'+file_name)
        hdu.writeto(bg_out_path, overwrite=True)

        # save a detection plane
        masked_im = goodStuff.exposure.getMaskedImage()
       ut_path, 'det_'+file_name)
        hdu.writeto(detect_out_path, overwrite=True)
        return





if __name__ == '__main__':
    file_list = glob.glob('/global/cscratch1/sd/ihasan/sims/*.fits')
    file_list = [f.split('/')[-1] for f in file_list]
    pg = ProcessGalsimOpt(file_list)
    pg.run()
