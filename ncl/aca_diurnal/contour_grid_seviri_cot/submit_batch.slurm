#!/bin/bash
#SBATCH --job-name=contour_grid_seviri_cot.ncl
#SBATCH --output=slurm_b.out
#SBATCH --error=slurm_b.err
#SBATCH --partition=batch
#SBATCH --qos=long
#SBATCH --time=120:00:00
#SBATCH --constraint=hpcf2013
#SBATCH --mem=50000

ncl contour_grid_seviri_cot.ncl;
rm source_grid_file.nc destination_grid_file.nc weights_file.nc
