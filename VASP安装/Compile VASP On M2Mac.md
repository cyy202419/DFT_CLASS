# M2 Macbook air安装VASP

0. 一些版本信息
> MacOS: Sonoma 14.6, VASP: 6.4.3 （找你师兄师姐要）


1. 安装Xcode命令行工具和brew

	```sh
	xcode-select --install
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	```
   
2. 用brew安装依赖

   ```sh
   brew install gcc openmpi scalapack fftw qd openblas
   ```

3. 修改`makefile.include`，`src/parser/makefile`以及`src/lib/getshmem.c`
- `makefile.include`
	```sh
	cd /path/to/vasp.6.4.3
	cp arch/makefile.include.gnu_omp makefile.include
 	```
 
	用如下代码替换`makefile.include`全文
	```make
	# Default precompiler options
	CPP_OPTIONS= -DHOST=\"LinuxGNU\" \
	              -DMPI -DMPI_BLOCK=8000 \
	              -Duse_collective \
	              -DscaLAPACK \
	              -DCACHE_SIZE=4000 \
	              -Davoidalloc \
	              -Dvasp6 \
	              -Duse_bse_te \
	              -Dtbdyn \
	              -Dfock_dblbuf \
	              -D_OPENMP \
	              -Dqd_emulate
	
	CPP        = gcc-14 -E -P -C -w $*$(FUFFIX) >$*$(SUFFIX) $(CPP_OPTIONS)
	
	FC         = mpif90 -fopenmp
	FCL        = mpif90 -fopenmp
	
	FREE       = -ffree-form -ffree-line-length-none
	
	FFLAGS      = -w -ffpe-summary=invalid,zero,overflow -L /opt/homebrew/Cellar/gcc/14.2.0_1/lib/gcc/14
	OFLAG      = -O2
	OFLAG_IN   = $(OFLAG)
	DEBUG      = -O0
	
	OBJECTS    = fftmpiw.o fftmpi_map.o  fftw3d.o  fft3dlib.o
	OBJECTS_O1 += fftw3d.o fftmpi.o fftmpiw.o
	OBJECTS_O2 += fft3dlib.o
	
	# For what used to be vasp.5.lib
	CPP_LIB    = $(CPP)
	FC_LIB     = $(FC)
	CC_LIB     = gcc-14
	CFLAGS_LIB = -O
	FFLAGS_LIB = -O1
	FREE_LIB   = $(FREE)
	
	OBJECTS_LIB= linpack_double.o getshmem.o
	
	# For the parser library
	CXX_PARS   = g++-14
	LIBS += parser
	LLIBS = -Lparser -lparser -lstdc++
	QD         ?= /opt/homebrew
	LLIBS      += -L$(QD)/lib -lqdmod -lqd
	INCS       += -I$(QD)/include/qd
	
	# When compiling on the target machine itself, change this to the
	# relevant target when cross-compiling for another architecture
	FFLAGS     += -march=native
	
	# For gcc-10 and higher (comment out for older versions)
	FFLAGS     += -fallow-argument-mismatch
	
	# BLAS and LAPACK (mandatory)
	OPENBLAS_ROOT ?= /opt/homebrew/Cellar/openblas/0.3.28
	BLASPACK    = -L$(OPENBLAS_ROOT)/lib -lopenblas
	
	# scaLAPACK (mandatory)
	SCALAPACK_ROOT ?= /opt/homebrew
	SCALAPACK   = -L$(SCALAPACK_ROOT)/lib -lscalapack
	
	LLIBS      += $(SCALAPACK) $(BLASPACK)
	
	# FFTW (mandatory)
	FFTW_ROOT  ?= /opt/homebrew
	LLIBS      += -L$(FFTW_ROOT)/lib -lfftw3 -lfftw3_omp
	INCS       += -I$(FFTW_ROOT)/include
	
	# HDF5-support (optional but strongly recommended)
	#CPP_OPTIONS+= -DVASP_HDF5
	#HDF5_ROOT  ?= /path/to/your/hdf5/installation
	#LLIBS      += -L$(HDF5_ROOT)/lib -lhdf5_fortran
	#INCS       += -I$(HDF5_ROOT)/include
	```
 
	- 其中需要根据个人情况修改的地方
		- 修改 `CPP = gcc-14 -E -P -C -w $*$(FUFFIX) >$*$(SUFFIX) $(CPP_OPTIONS)`
		- 修改第一个FFLAG路径，`/opt/homebrew/Cellar/gcc/14.2.0_1/lib/gcc/14`
		- 修改 `CC_LIB = gcc-14`
		- 修改 `CXX_PARS = g++-14`
		- 修改 `OPENBLAS_ROOT ?= /opt/homebrew/Cellar/openblas/0.3.28`
	 - 通过如下命令查看`gcc openblas`版本和路径
 
	   	```sh
		ls /opt/homebrew/bin/gcc* # 查看homebrew安装的gcc大版本，例如gcc-14；
		ls /opt/homebrew/Cellar/gcc/ # 检查gcc路径
		ls /opt/homebrew/Cellar/openblas/ # 检查openblas版本，例如0.3.28
		```
- 修改`src/parser/makefile`

	`ar vq libparser.a $(CPPOBJ_PARS) $(COBJ_PARS) locproj.tab.h` $\rightarrow$ `ar vq libparser.a $(CPPOBJ_PARS) $(COBJ_PARS)`

- 修改`src/lib/getshmem.c`

	```c
	/*output: shmem id
	*/
	#define SHM_NORESERVE 0 // this line was added
	
	void getshmem_C(size_t _size, int *_id)
	```

4. 编译VASP

	```
	make veryclean
	make std gam ncl
	```
 
	编译成功会在`vasp.6.4.3/bin`文件夹下看到`vasp_std`，`vasp_gam`和`vasp_ncl`，分别为标准版，Gamma only版和非共线版。

5. 测试VASP

	```sh
	export OMP_NUM_THREADS=1 # 单线程，否则会与多进程冲突，都说很重要
	make test # 要跑很久
	```

	为了使用方便，可以把最常用的`vasp_std`改名为`vasp`。然后在`~/.zshrc`末尾加入`export PATH=$PATH:/path/to/vasp.6.4.3/bin`，
	使得此目录加入到操作系统寻找可执行文件的路径中。最后重启终端或者`source ~/.zshrc`。

	下载`http://sobereva.com/attach/455/benchmark.Hg.tar.gz`，解压到任意位置。将`IN-short`改名为`INCAR`，进入此目录，
	输入`mpirun -np 4 vasp`测试调用四个核心执行此任务（也要先`export OMP_NUM_THREADS=1`），
	然后检查得到的OUTCAR看是否内容正常，没报错就说明完全装好了！
	

7. Reference
- https://www.bilibili.com/read/cv26550272/
- https://gist.github.com/janosh/a484f3842b600b60cd575440e99455c0#file-makefile-include
