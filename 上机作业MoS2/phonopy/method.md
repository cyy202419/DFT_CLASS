1. 使用能带计算时优化好的结构, `copy POSCAR as POSCAR.unitecell`
2. 使用`phonopy -d --dim="4 4 1" -c POSCAR.unitcell`命令，以$4\times 4 \times 1$将$\rm MoS_{2}$单胞拓展为`supercell`，同时会产生3个`POSCAR`文件
3. 对于3个`POSCAR`进行三次静态计算，分别产生`vasprun.xml`
4. 使用`phonopy -f {001..003}/vasprun.xml`命令计算力常数矩阵
5. 创建`band.conf`配置文件如下
```
#band.conf
BAND = 0.0000000000   0.0000000000   0.0000000000   0.5000000000   0.0000000000   0.0000000000   0.3333333333   0.3333333333   0.0000000000   0.0000000000   0.0000000000   0.0000000000

BAND_LABELS = $\Gamma$ M K $\Gamma$

BAND_POINTS = 200
```
6. 使用`phonopy -p band.conf -s`，绘制声子谱并保存。