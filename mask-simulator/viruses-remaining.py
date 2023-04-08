#!/usr/bin/env python3

"""
A script which calculates, for a given number of photons available for decontamination
in the outer layer, and for the total number of viruses spread (evenly) throughout the FFR,
the total number of viruses which remain after the light have traveled through the mask.

We use the ratios of photons available for decontamination as obtained from our simulator
to propagate the new number of photos in the outer layer.

We assume these values:
 - PCT_PHO_ABSORBED: the percentage of photons absorbed of those available for decontamination
                     in each FFR layer. This can be scaled over each layer by the
                     PCT_PHO_ABSORBED_DECREASE value.
 - PCT_PHOTONS_DEACTIVATING: the percentage of photons which actually deactivate a coronavirus
                             after being absorbed by one.
"""

import csv
import sys

### CONSTANTS
N_LAYERS                  = 9
TOTAL_VIRUSES             = 119000
VIRUSES_PER_LAYER         = TOTAL_VIRUSES / N_LAYERS
PCT_PHO_ABSORBED          = 0.1
PCT_PHO_ABSORBED_DECREASE = 2
PCT_PHOTONS_DEACTIVATING  = 0.8

if len(sys.argv) == 2:
    N_INC_PHOTONS =  int(sys.argv[1])
else:
    N_INC_PHOTONS = 16000

# VARIABLES
virusDataFile = "./virus-data.csv"
exposureTime = []
viralLoad = []

photonDataFile = "./photon-data.csv"
photonsEntered = []
photonsEnteredNorm = []

subLayers = []

viruses = [VIRUSES_PER_LAYER] * N_LAYERS
pctPhotonsAbsorbed = []
photonsAbsorbed = []
deactivatedViruses = []
deactivatedVirusesBiDir = []
virusesRemaining = []
totalVirusesRemaining = 0

# Get virus data
with open(virusDataFile, "r") as csvfile:
    reader = csv.reader(csvfile, delimiter=',')
    for row in reader:
        exposureTime.append(int(row[0]))
        viralLoad.append(int(row[1]))
    csvfile.close()

# Get photon data
with open(photonDataFile, "r") as csvfile:
    reader = csv.reader(csvfile, delimiter=',')
    for row in reader:
        subLayers.append(int(row[0]))
        photonsEntered.append(int(row[1]))
    csvfile.close()

# Normalize photon data
norm_factor = N_INC_PHOTONS/photonsEntered[0]
for l in range(0,N_LAYERS):
    photonsEnteredNorm.append(photonsEntered[l] * norm_factor)

# Set absorption percentage per sub-layer
#for i in range(0,N_LAYERS):
    #pctPhotonsAbsorbed.append(PCT_PHO_ABSORBED)

# Calculate the absorption percentage per sub-layer
pctPhotonsAbsorbed.append(PCT_PHO_ABSORBED)
for i in range(1, N_LAYERS):
    pctPhotonsAbsorbed.append(pctPhotonsAbsorbed[i-1] / PCT_PHO_ABSORBED_DECREASE)

### Calculate num photons absorbed by viruses per sub-layer
photons_for_decon = []
for i in range(0,N_LAYERS):
    n_photons_entered_norm = photonsEnteredNorm[i]
    if i == 0:
        n_photons_for_decon = n_photons_entered_norm
        photons_for_decon.append(n_photons_for_decon)
    else:
        prev = i - 1
        ratio = n_photons_entered_norm / photonsEnteredNorm[prev]
        n_photons_for_decon = (photons_for_decon[prev] * ratio) - photonsAbsorbed[prev]
        photons_for_decon.append(n_photons_for_decon)
    nPhotonsAbsorbed = n_photons_for_decon * pctPhotonsAbsorbed[i]
    photonsAbsorbed.append(nPhotonsAbsorbed)

### Calculate num viruses deactivated
# Num viruses deactivated
for nPhotonsAbsorbed in photonsAbsorbed:
    nDeactivatedViruses = nPhotonsAbsorbed * PCT_PHOTONS_DEACTIVATING
    deactivatedViruses.append(nDeactivatedViruses)

mid = (len(deactivatedViruses) + 1) // 2

for outerLayer, innerLayer in zip(deactivatedViruses, deactivatedViruses[::-1]):
    deactivatedVirusesBiDir.append(outerLayer + innerLayer)

### Calculate num viruses remaining per sub-layer
for i in range(0, N_LAYERS):
    nDeactivatedViruses = deactivatedVirusesBiDir[i]
    nVirusesRemainingPossiblyNegative = viruses[i] - nDeactivatedViruses
    nVirusesRemaining = 0 if nVirusesRemainingPossiblyNegative < 0 else nVirusesRemainingPossiblyNegative
    virusesRemaining.append(nVirusesRemaining)

### Calculate total viruses remaining in FFR
for nVirusesRemaining in virusesRemaining:
    totalVirusesRemaining += nVirusesRemaining

print(f"Viruses remaining in each sub-layer (outer -> inner): {virusesRemaining}")
print(f"Total viruses remaining in FFR: {int(round(totalVirusesRemaining))}")

# Exp #5, 3M1870+ - slit
#  - with 380,100 photons available for decontamination in layer 9
#   you get 0 remaining photons in each layer
#
# Exp #7, 3M9210+ - slit
#  - with 2,130,000 photons in layer 9, you get 0 remaining
