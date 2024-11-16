#!/bin/sh
cat /path/to/Mo_pv/POTCAR /path/to/S/POTCAR > POTCAR

cat > INCAR <<!
# Starting parameters
SYSTEM = MoS2
ISTART = 0
ICHARG = 2
LWAVE = .T.
LCHARG = .T.
NWRITE = 1

# Parameters for electronic SCF iteration
ENCUT = 500
ALGO = F
LDIAG = .TURE.
EDIFF = 1E-6
ADDGRID = .TRUE.
SIGMA = 0.05
ISMEAR = 0
LASPH = .TRUE.
NELM = 150
NELMIN = 6
NELMDL = -12

# Parameters for Ionic relaxations
IBRION = -1
ISYM = 0

# Exchange correlation function
GGA = PE
IVDW = 11

# Other parameters
PREC = A
NCORE = 12
!

cat > KPOINTS <<!
Automatic mesh
0
Gamma
15 15 1
0  0  0
!

cat > POSCAR <<!
Mo1 S2                                  
   1.00000000000000     
     1.5820430070132074   -2.7401779469146073    0.0000000000000000
     1.5820430131823260    2.7401779499860925    0.0000000000000000
     0.0000000000000000    0.0000000000000000   23.3962306484859361
   Mo   S 
     1     2
Direct
  0.9999999895133698  0.0000000090035286  0.5000000002825900
  0.3333333335900122  0.6666666582058269  0.5668876205883038
  0.3333333435632895  0.6666666661239802  0.4331123791291063
!

srun vasp_std
