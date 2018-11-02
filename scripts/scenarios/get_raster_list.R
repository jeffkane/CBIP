################################################################################
# This script selects the file paths for raster data based on scenario name 
#
# Author: Micah Wright, Humboldt State University
################################################################################

get_raster_list <- function(scenario) {
        
        stopifnot(scenario %in% c("scenario_one", 
                                  "scenario_two", 
                                  "scenario_three", 
                                  "scenario_four",
                                  "scenario_five"))
        
        if(scenario %in% c("scenario_one", "scenario_four", "scenario_five")) 
        {
                files <- list("FCID2018" = "data/UW/UW_FCID.tif",
                              "Slope" = "data/Other/DEM/Slope_NAD83.tif",
                              "fuelbed_number" = "data/FCCS/spatial/FCCS_NAD83.tif", 
                              "Fm10" = "data/GEE/resampled/fm10.tif",
                              "Fm1000" = "data/GEE/resampled/fm1000.tif",
                              "Wind" = "data/GEE/resampled/windv.tif",
                              "TPI" = "data/Other/DEM/dem_dev_2g_NAD83.tif")
        }
        
        if(scenario %in% c("scenario_two", "scenario_three")) 
        {
                files <- list("FCID2018" = "data/UW/UW_FCID.tif",
                              "Slope" = "data/Other/DEM/Slope_NAD83.tif",
                              "fuelbed_number" = "data/FCCS/spatial/FCCS_NAD83.tif", 
                              "Fm10" = "data/GEE/resampled/fm10_rx.tif",
                              "Fm1000" = "data/GEE/resampled/fm1000_rx.tif",
                              "Wind" = "data/GEE/resampled/windv_rx.tif",
                              "TPI" = "data/Other/DEM/dem_dev_2g_NAD83.tif")
        }
        
        return(files)
}