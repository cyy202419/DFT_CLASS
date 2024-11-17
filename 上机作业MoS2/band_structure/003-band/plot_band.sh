import matplotlib.pyplot as plt
from pymatgen.io.vasp.outputs import Vasprun
from pymatgen.electronic_structure.plotter import BSDOSPlotter,\
BSPlotter,BSPlotterProjected,DosPlotter

# read vasprun.xml，get band and dos information
bs_vasprun = Vasprun("./vasprun.xml",parse_projected_eigen=True)
bs_data = bs_vasprun.get_band_structure(line_mode=True)
dos_vasprun=Vasprun("./vasprun.xml")
dos_data=dos_vasprun.complete_dos

################能带和态密度#####################
banddos_fig = BSDOSPlotter(bs_projection=None, dos_projection=None, vb_energy_range=5, fixed_cb_energy=5)
banddos_fig.get_plot(bs=bs_data, dos=dos_data)
plt.savefig('banddos_fig.png')

################能带和投影态密度#####################
pbandpdos_fig = BSDOSPlotter(bs_projection='elements', dos_projection='elements',\
                             vb_energy_range=5, fixed_cb_energy=5)
pbandpdos_fig.get_plot(bs=bs_data, dos=dos_data)
plt.savefig('pbandpdos_fig.png')

################能带和投影态密度（轨道）#####################
pbandpdos_fig_orbitals = BSDOSPlotter(bs_projection='elements', dos_projection='orbitals',\
                             vb_energy_range=5, fixed_cb_energy=5)
pbandpdos_fig_orbitals.get_plot(bs=bs_data, dos=dos_data)
plt.savefig('pbandpdos_fig_orbitals.png')

################能带和投影态密度（元素）#####################
pband_fig = BSPlotterProjected(bs=bs_data)
pband_fig = pband_fig.get_projected_plots_dots({'Mo':['d','s'],'S':['p']})
plt.savefig('pband_orbital_fig.png')

################     能      带      #####################
bs_plotter = BSPlotter(bs=bs_data)
ax = bs_plotter.get_plot(ylim=[-4, 4], smooth=True, vbm_cbm_marker=True)

fontsize = 14
ax.set_xlabel(ax.get_xlabel(), fontsize=fontsize)
ax.set_ylabel(ax.get_ylabel(), fontsize=fontsize)
ax.tick_params(axis='both', labelsize=fontsize)
# 添加费米能级参考线
ax.axhline(y=0, color='black', linestyle='--',linewidth=2)
legend = ax.get_legend()
if legend is not None:
    legend.remove()
ax.set_xlabel('')

bandgap = bs_data.get_band_gap()['energy']
ax.text(x=1.95, y=1, s=f"band_gap={bandgap}ev", fontsize=16)
plt.savefig('just_band.png')

################布里渊区#####################
band_fig = BSPlotter(bs=bs_data)
band_fig.plot_brillouin()
plt.savefig('brillouin_fig.png')

fermi_level = dos_vasprun.efermi
print("费米能级为:", fermi_level)
