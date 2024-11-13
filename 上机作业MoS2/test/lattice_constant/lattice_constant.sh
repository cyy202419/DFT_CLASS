#!/bin/bash/env bash
cat ~/Desktop/PAW/PBE/Mo_pv/POTCAR ~/Desktop/PAW/PBE/S/POTCAR > POTCAR
cat > INCAR.relax <<!
# Starting parameters
SYSTEM = MoS2
ISTART = 0
ICHARG = 2
LWAVE = .F.
LCHARG = .F.
NWRITE = 1

# Parameters for electronic SCF iteration
ENCUT = 500
ALGO = F
LDIAG = .TURE.
EDIFF = 1E-5
ADDGRID = .TRUE.
SIGMA = 0.05
ISMEAR = 0
NELM = 60
NELMIN = 4

# Parameters for Ionic relaxations
IBRION = 2
NSW = 100
ISIF = 2
EDIFFG = -0.01

# Exchange correlation function
GGA = PE
IVDW = 11

# Other parameters
PREC = A
NCORE = 4
!

cat > INCAR.static <<!
# Starting parameters
SYSTEM = MoS2
ISTART = 0
ICHARG = 2
LWAVE = .F.
LCHARG = .F.
NWRITE = 1

# Parameters for electronic SCF iteration
ENCUT = 500
ALGO = F
LDIAG = .TURE.
EDIFF = 1E-5
SIGMA = 0.05
ISMEAR = 0

# Exchange correlation function
GGA = PE
IVDW = 11

# Other parameters
PREC = A
NCORE = 4
!

cat > KPOINTS <<!
Automatic mesh
0
Gamma
15 15 1
0 0 0
!

for i in $(seq 3.152 0.002 3.168)
do

k=$(echo "$i * 0.8660254038" | bc)
j=$(echo "$i * 0.5000000000" | bc)
kk=$(echo "-$i * 0.8660254038" | bc)

cat > POSCAR <<!
Mo1 S2
1.000
$j $kk 0.0000000000000000
$j $k 0.0000000000000000
0.0000000000000000 0.0000000000000000 23.1026500132666968
Mo S
1 2
Direct
0.0000000000000000 0.0000000000000000 0.5000000000000000 Mo1
0.3333333333333334 0.6666666666666666 0.5671492233896329 S1
0.3333333333333333 0.6666666666666667 0.4328507766103671 S2
!

cat INCAR.relax > INCAR
echo "---------------------a=$i relax---------------------"; time mpirun -np 2 vasp
cat CONTCAR > POSCAR
cat INCAR.static > INCAR
echo "---------------------a=$i static---------------------"; time mpirun -np 2 vasp

V=$(grep "volume" OUTCAR | tail -1 | awk '{printf "%12.9f \n", $5 }')
E=$(grep "TOTEN" OUTCAR | tail -1 | awk '{printf "%12.9f \n", $5 }')
echo $i $V $E >> ab.dat

done
