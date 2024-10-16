import numpy as np
from scipy.integrate import quad

def rho(r):
    return (1/np.pi) * np.exp(-2 * r)

def r_s(r):
    # 限制r的值以避免溢出
    r = np.minimum(r, 10)  # 你可以根据需要调整这个值
    return (3/4) ** (1/3) * np.exp(2*r/3)

def epsilon_c(r):
    rs = r_s(r)
    x = np.sqrt(rs)
    
    A = 0.015545
    alpha1 = 0.20548
    beta1 = 14.1189
    beta2 = 6.1977
    beta3 = 3.3662
    beta4 = 0.62517
    
    # 确保对数函数的参数为正且不会太小
    term = 1 + 1/(2*A * (beta1*x + beta2*x**2 + beta3*x**3 + beta4*x**4))
    if term <= 1:
        term = 1 + 1e-10  # 添加一个小的正数以避免对数为负或零
    
    ep = -2*A * (1 + alpha1*x**2) * np.log(term)
    return ep

def integrand(r):
    ep = epsilon_c(r)
    rho_val = rho(r)
    if np.isfinite(ep) and np.isfinite(rho_val):
        return ep * rho_val * 4 * np.pi * r**2
    else:
        return 0  # 如果epsilon_c或rho不是有限值，则返回0

E_c, error = quad(integrand, 0, np.inf, epsabs=1e-10, epsrel=1e-10)

print(f'关联能 E_c = {E_c}')
