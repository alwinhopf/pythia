#!/usr/bin/env bash
#SBATCH --job-name=pythia_sample
#SBATCH --mail-type=END,FAIL
#SBATCH --time=3-10:00:00
#SBATCH --cpus-per-task=20
#SBATCH --mem=16GB

echo "Job submitted $(date)"
srun pythia.sh  --clean-work-dir --all SL_Rice.json
echo "Job completed $(date)"
