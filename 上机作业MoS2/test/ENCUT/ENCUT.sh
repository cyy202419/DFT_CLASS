#!/bin/bash/env bash
cat ~/Desktop/PAW/PBE/Mo_pv/POTCAR ~/Desktop/PAW/PBE/S/POTCAR > POTCAR
cat > KPOINTS <<!
Automatic mesh
0
Gamma
7 7 1
0 0 0
!

cat > POSCAR <<!
Mo1 S2
1.0
1.5920630411037595 -2.7575340760443292 0.0000000000000000
1.5920630411037595 2.7575340760443292 0.0000000000000000
0.0000000000000000 0.0000000000000000 17.3345999500000012
Mo S
1 2
direct
0.0000000000000000 0.0000000000000000 0.0000000000000000 Mo4+
0.3333333333333333 0.6666666666666666 0.0894929799999999 S2-
0.3333333333333333 0.6666666666666667 0.9105070200000001 S2-
!

for i in $(seq 250 25 700)
do
cat > INCAR <<!
SYSTEM = MoS2
ENCUT = $i
ISTART = 0
ICHARG = 2
ISMEAR = 0
PREC = Accurate
LWAVE = .F.
LCHARG = .F.
NWRITE = 1
NCORE = 4
!

echo "ENCUT = $i eV" ; time mpirun -np 2 vasp
E=$(grep "TOTEN" OUTCAR | tail -1 | awk '{printf "%12.9f \n", $5 }')
echo $i $E >>encut_energy.dat
done
