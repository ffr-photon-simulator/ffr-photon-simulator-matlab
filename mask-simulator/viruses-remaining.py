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
for l in range(0, N_LAYERS):
    photonsEnteredNorm.append(photonsEntered[l] * norm_factor)

# Set absorption percentage per sub-layer
#for i in range(0,N_LAYERS):
    #pctPhotonsAbsorbed.append(PCT_PHO_ABSORBED)

# Calculate the absorption percentage per sub-layer
pctPhotonsAbsorbed.append(PCT_PHO_ABSORBED)
for i in range(1, N_LAYERS):
    pctPhotonsAbsorbed.append(pctPhotonsAbsorbed[i-1] / PCT_PHO_ABSORBED_DECREASE)

### Calculate num photons absorbed by viruses per sub-layer and store this in the
### photonsAbsorbed list defined at the beginning.
###
### As an intermediary, we need to calculate the photons available for decontamination
### in each sublayer. Store these values in photonsForDecon, defined here. We need to fill
### both the photonsForDecon and photonsAbsorbed lists simultaneously because the photons
### available for decontamination in a given layer changes based on how many photons were
### absorbed in the layers before it.
###
### NOTE: the number of photons available for decontamination is considered, in this script, the
### number of photons which enter a given layer before any accounting for viral absorption.
photonsForDecon = []
for i in range(0,N_LAYERS):
    nPhotonsEnteredNorm = photonsEnteredNorm[i]
    # For the first layer, the photons for decon are just those which enter
    if i == 0:
        nPhotonsForDecon = nPhotonsEnteredNorm
        photonsForDecon.append(nPhotonsForDecon)
    # For other layers, the process is more complicated because we have to account
    # for the photons which were absorbed by viruses in the previous layer. For these other layers,
    # we cannot rely on the specific photon quantities given by the simulation because the simulation
    # did not take into account viral absorption of photons.
    #
    # Rather, we use the /ratios/ given by the simulation to calculate how many photons
    # are available for decontamination in the current layer.
    else:
        prev = i - 1
        # The fraction of photons which enter this layer for *any* given amount of photons in the previous.
        ratio = nPhotonsEnteredNorm / photonsEnteredNorm[prev]
        # Use the photons available for decontamination in the previous layer along with the ratio to calculate
        # how many photons are available for decontamination in this layer. Then, subtract the number of photons
        # absorbed from the previous layer to get the actual number of photons available for decontamination
        # in this layer.
        nPhotonsForDecon = (photonsForDecon[prev] * ratio) - photonsAbsorbed[prev]
        photonsForDecon.append(nPhotonsForDecon)
    # Now, calculate how many photons are absorbed in this layer.
    nPhotonsAbsorbed = nPhotonsForDecon * pctPhotonsAbsorbed[i]
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
