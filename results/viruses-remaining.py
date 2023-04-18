#!/usr/bin/env python3

import csv
import sys
import math

N_ARGS = 5

if len(sys.argv) < N_ARGS:
    print(f"viruses-remaining.py must be run with {N_ARGS} arguments: ")
    print("1. Experimental virus csv file for FFR sample.")
    print("2. Simulated average photon csv file for FFR.")
    print("3. Absorption coefficient value, between 0 and 1.")
    print("4. Absorption coefficient method:")
    print("   --constant")
    print("       Keep the absorption coefficient constant for each sub-layer.")
    print("   --decrease=[factor]")
    print("       Decrease the absorption coefficient by a constant factor for each sub-layer, between 0 and 1.")
    print("   --scaled")
    print("       Scale the absorption coefficient with the photon data.")
    print("5. Variable number of photons available for decontamination in the outer layer.")
    sys.exit(1)

### CONSTANTS
N_LAYERS                  = 9
PCT_PHOTONS_DEACTIVATING  = 0.8

# ARGUMENTS
virusDataFile  = sys.argv[1]
photonDataFile = sys.argv[2]

coeff = float(sys.argv[3])
PCT_PHO_ABSORBED = coeff

absMethodFlag = sys.argv[4]
# Constant
if absMethodFlag == '--constant':
    ABS_METHOD = 'constant'
    PCT_PHO_ABSORBED_DECREASE = float(1)
    print("Using constant absorption coefficient.")
# Scaled
elif absMethodFlag == '--scaled':
    ABS_METHOD = 'scaled'
    print("Using scaled absorption coefficient.")
# Decrease
elif '=' in absMethodFlag:
    # Get flag and parameters
    ABS_METHOD = 'decrease'
    PCT_PHO_ABSORBED_DECREASE = float(absMethodFlag.split('=')[1])
    print("Using decreasing absorption coefficient.")
else:
    print(f"Unrecognized absorption coefficient flag {absMethodFlag}.")

# N_INC_PHOTONS will always be the last argument.
N_INC_PHOTONS  =  int(sys.argv[N_ARGS])


# VARIABLES
#virusDataFile = "./virus-data.csv"
exposureTime = []
viralLoad = []

#photonDataFile = "./photon-data.csv"
photonsEntered = []
photonsEnteredNorm = []

subLayers = []

pctPhotonsAbsorbed = [] # first item (index 0) is never used
photonsAbsorbed = []
deactivatedViruses = []
deactivatedVirusesBiDir = []
virusesRemaining = []
totalVirusesRemaining = 0

with open(virusDataFile, "r") as csvfile:
    reader = csv.reader(csvfile, delimiter=',')
    for row in reader:
        exposureTime.append(int(row[0]))
        viralLoad.append(int(row[1]))
    csvfile.close()

TOTAL_VIRUSES = viralLoad[0]
VIRUSES_PER_LAYER = TOTAL_VIRUSES / N_LAYERS
viruses = [VIRUSES_PER_LAYER] * N_LAYERS

with open(photonDataFile, "r") as csvfile:
    reader = csv.reader(csvfile, delimiter=',')
    for row in reader:
        subLayers.append(int(row[0]))
        photonsEntered.append(int(row[1]))
    csvfile.close()

norm_factor = N_INC_PHOTONS/photonsEntered[0]
for l in range(0, N_LAYERS):
    photonsEnteredNorm.append(photonsEntered[l] * norm_factor)

photonsEnteredRatios = []
for i in range(0, N_LAYERS):
    nPhotonsEnteredNorm = photonsEnteredNorm[i]
    if i == 0:
        photonsEnteredRatios.append(1)
    else:
        prev = i - 1
        ratio = nPhotonsEnteredNorm / photonsEnteredNorm[prev]
        photonsEnteredRatios.append(ratio)

if ABS_METHOD == 'scaled':
    pctPhotonsAbsorbed.append(PCT_PHO_ABSORBED)
    for i in range(1, N_LAYERS):
        nextPct = pctPhotonsAbsorbed[i - 1] * photonsEnteredRatios[i]
        pctPhotonsAbsorbed.append(nextPct)
else:
    pctPhotonsAbsorbed.append(PCT_PHO_ABSORBED)
    for i in range(1, N_LAYERS):
        pctPhotonsAbsorbed.append(pctPhotonsAbsorbed[i-1] * PCT_PHO_ABSORBED_DECREASE)

photonsForDecon = []
for i in range(0,N_LAYERS):
    nPhotonsEnteredNorm = photonsEnteredNorm[i]
    if i == 0:
        nPhotonsForDecon = nPhotonsEnteredNorm
        photonsForDecon.append(nPhotonsForDecon)

    else:
        prev = i - 1
        ratio = nPhotonsEnteredNorm / photonsEnteredNorm[prev]
        nPhotonsForDecon = (photonsForDecon[prev] * ratio) - photonsAbsorbed[prev]
        photonsForDecon.append(nPhotonsForDecon)

    nPhotonsAbsorbed = nPhotonsForDecon * pctPhotonsAbsorbed[i]
    photonsAbsorbed.append(nPhotonsAbsorbed)

for nPhotonsAbsorbed in photonsAbsorbed:
    nDeactivatedViruses = nPhotonsAbsorbed * PCT_PHOTONS_DEACTIVATING
    deactivatedViruses.append(nDeactivatedViruses)

mid = (len(deactivatedViruses) + 1) // 2
for outerLayer, innerLayer in zip(deactivatedViruses, deactivatedViruses[::-1]):
    deactivatedVirusesBiDir.append(outerLayer + innerLayer)

for i in range(0, N_LAYERS):
    nDeactivatedViruses = deactivatedVirusesBiDir[i]
    nVirusesRemainingPossiblyNegative = viruses[i] - nDeactivatedViruses
    nVirusesRemaining = 0 if nVirusesRemainingPossiblyNegative < 0 else nVirusesRemainingPossiblyNegative
    virusesRemaining.append(nVirusesRemaining)

for nVirusesRemaining in virusesRemaining:
    totalVirusesRemaining += nVirusesRemaining

#print(f"Viruses remaining in each sub-layer (outer -> inner): {virusesRemaining}")
print(f"Total viruses remaining in FFR: {int(round(totalVirusesRemaining))}")
