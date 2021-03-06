################################################################################
# This script masks the FCID raster to exclude wilderness areas and barren FCCS
# as part of the California Biopower Impact Project. 
#
# Author: Micah Wright, Humboldt State University
################################################################################

# load the necessary packages
library(sf)
library(data.table)
library(raster)
library(fasterize)

# load UW FCID raster
FCID2018 <- raster("data/UW/UW_FCID.tif")

# load FCCS mask
FCCS_mask <- raster("data/FCCS/spatial/FCCS_unforested.tif")

# load CA shapefile
CA <- st_read("data/Other/srtm_1_deg/srtm_1_deg_dissolve.shp",
              quiet = TRUE)

# reproject CA
CA <- st_transform(CA,
                   crs(FCID2018)@projargs)

# rasterize the CA polygon
CA_raster <- fasterize(CA, FCID2018)

# mask out Oregon in the FCID raster
FCID2018_no_OR <- mask(FCID2018, 
                       CA_raster, 
                       maskvalue = NA, 
                       datatype = dataType(FCID2018))

# remove CA 
rm(CA)
rm(CA_raster)

# load CA wilderness areas, taken from figshare
wilderness <- st_read("data/Other/wilderness/Wilderness_Areas_CA.shp", 
                      quiet = TRUE)

# reproject wilderness
wilderness <- st_transform(wilderness,
                           crs(FCID2018)@projargs)

# rasterize the wilderness polygons
wild_raster <- fasterize(wilderness, FCID2018)

# mask out wilderness in the FCID raster
FCID2018_no_wild <- mask(FCID2018_no_OR, 
                         wild_raster, 
                         maskvalue = 1, 
                         datatype = dataType(FCID2018))

# remove wilderness
rm(wilderness)
rm(wild_raster)

# mask out FCCS barren areas
FCID2018_masked <- mask(FCID2018_no_wild,
                        FCCS_mask,
                        maskvalue = 1, 
                        datatype = dataType(FCID2018))

# reclassify the FCID without biomass to NA
# first load the clearcut data
clearcut <- fread("data/UW/residue/Remove100Percent.csv")

clearcut[, total_load := Stem_ge9_tonsAcre +
                 Stem_6t9_tonsAcre + 
                 Stem_4t6_tonsAcre +
                 Branch_tonsAcre +
                 Foliage_tonsAcre]

clearcut[, becomes := ifelse(total_load == 0, 1, NA)]

recl <- as.matrix(clearcut[, .(FCID2018, becomes)])

beginCluster()

Mask_no_load <- clusterR(FCID2018_masked, 
                         reclassify,
                         args = list(rcl = recl))

endCluster()

FCID2018_masked_no_load <- mask(FCID2018_masked, 
                                Mask_no_load,
                                maskvalue = 1, 
                                datatype = dataType(FCID2018))

# compare output to original
stk <- stack(FCID2018, FCID2018_masked, FCID2018_masked_no_load)

samp <- sampleRandom(stk, 200, na.rm = FALSE, cells = TRUE)

samp

# save the output
writeRaster(FCID2018_masked_no_load,
            "data/UW/FCID2018_masked.tif",
            format = "GTiff",
            datatype = dataType(FCID2018))
