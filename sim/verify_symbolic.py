"""
Symbolic verification (SymPy) of derivation/derivation.tex, no numbers involved.

  S1  Lemma 3.1 (productivity): d/dI lnY|_{K,L} = ln( W / (gamma(I) R) ) and d/dN = ln( gamma(N) R / W ),
      starting from lnY = a ln(K/a) + b ln(L/b) + int_I^N ln gamma, W = bY/L, R = aY/K.
  S2  Lemma 3.2 (employment) by implicit differentiation of L = L^s(b/(aL)) with a generic L^s.
  S3  Theorem 3.3: dlnW/dI = pi_I - 1/(b(1+eps_L)),  dlnR/dI = pi_I + 1/(a(1+eps_L)),
      dlnW/dN = pi_N + 1/(b(1+eps_L)),  dlnR/dN = pi_N - 1/(a(1+eps_L)).
  S4  Theorem 4.2 (threshold): the zero of dlnW/dI in K is K_hat = (a L gamma(I)/b) exp(1/(b(1+eps_L))).
  P6  Observation 3.4: the paper's Proposition 3 at sigma_hat = 1 gives the same displacement term, and
      its productivity term ((W/gamma)^(1-s) - R^(1-s))/(1-s) tends to ln(W/(gamma R)) as s -> 1.

Run:  python3 verify_symbolic.py      (exits 1 if any identity fails)
"""
import sys

import sympy as sp

ok = True


def check(name, expr):
    global ok
    res = sp.simplify(expr)
    passed = res == 0
    ok &= passed
    print(f"[{'OK' if passed else 'FAIL'}] {name}" + ("" if passed else f"   residual: {res}"))


I, N, K, i = sp.symbols("I N K i", real=True)
s = sp.symbols("s", positive=True)
gamma = sp.Function("gamma", positive=True)
Ls = sp.Function("L_s", positive=True)
Lsym = sp.symbols("L", positive=True)

a = I - N + 1
b = N - I


def lnY(Ival, Nval, Lval):
    """Lemma 2.3: lnY = a ln(K/a) + b ln(L/b) + int_{I}^{N} ln gamma, with a = I-N+1, b = N-I."""
    return ((Ival - Nval + 1) * sp.log(K / (Ival - Nval + 1))
            + (Nval - Ival) * sp.log(Lval / (Nval - Ival))
            + sp.Integral(sp.log(gamma(i)), (i, Ival, Nval)))


# ---------------- S1 productivity (K, L fixed) ----------------
Y = sp.exp(lnY(I, N, Lsym))
W = b * Y / Lsym
R = a * Y / K
dlnY_dI = sp.diff(lnY(I, N, Lsym), I).doit()
dlnY_dN = sp.diff(lnY(I, N, Lsym), N).doit()
pi_I = sp.log(W / (gamma(I) * R))
pi_N = sp.log(gamma(N) * R / W)
check("S1 dlnY/dI|KL = ln(W/(gamma(I) R))", sp.expand_log(dlnY_dI - pi_I, force=True))
check("S1 dlnY/dN|KL = ln(gamma(N) R/W)", sp.expand_log(dlnY_dN - pi_N, force=True))

# ---------------- S2 employment: L(x) solves L = Ls(b/(a L)) ----------------
x = sp.symbols("x", real=True)  # x stands for I (or N) along the derivative
Lf = sp.Function("Lf", positive=True)


def employment_derivative(var):
    """d ln L / d var from L = Ls(omega), omega = b/(a L), by implicit differentiation."""
    aa = (x - N + 1) if var == "I" else (I - x + 1)
    bb = (N - x) if var == "I" else (x - I)
    omega = bb / (aa * Lf(x))
    eqn = Lf(x) - Ls(omega)
    dL = sp.solve(sp.diff(eqn, x), sp.diff(Lf(x), x))[0]
    return sp.simplify(dL / Lf(x)), omega, aa, bb


w_ = sp.symbols("omega", positive=True)
eps = sp.symbols("epsilon_L", positive=True)
Lsp = sp.Function("Lsp")  # derivative of L^s


def to_eps(expr, omega):
    """Replace L^s'(omega) by eps * L^s(omega) / omega and L^s(omega) by L (equilibrium)."""
    expr = expr.subs(sp.Subs(sp.Derivative(Ls(w_), w_), w_, omega), eps * Lf(x) / omega)
    expr = expr.replace(lambda e: isinstance(e, sp.Subs), lambda e: eps * Lf(x) / omega)
    expr = expr.replace(lambda e: isinstance(e, sp.Derivative) and e.expr.func == Ls, lambda e: eps * Lf(x) / omega)
    return sp.simplify(expr.subs(Ls(omega), Lf(x)))


dlnL_I, omI, aI, bI = employment_derivative("I")
dlnL_I = to_eps(dlnL_I, omI)
check("S2 dlnL/dI = -eps/(1+eps) * 1/(ab)", dlnL_I - (-eps / (1 + eps) / (aI * bI)))
dlnL_N, omN, aN, bN = employment_derivative("N")
dlnL_N = to_eps(dlnL_N, omN)
check("S2 dlnL/dN = +eps/(1+eps) * 1/(ab)", dlnL_N - (eps / (1 + eps) / (aN * bN)))

# ---------------- S3 total derivatives (K fixed, L adjusts) ----------------
g = sp.symbols("g", real=True)  # stands for d ln L / dx
# lnW = ln b + lnY - ln L, lnR = ln a + lnY - ln K, with dlnY = pi + b * dlnL (d lnY/d lnL = b)
Lx = sp.symbols("Lx", positive=True)
dlnY_dlnL = sp.simplify(Lx * sp.diff(lnY(I, N, Lx), Lx))
check("S3 d lnY / d lnL = b", dlnY_dlnL - b)
piI_s, piN_s = sp.symbols("pi_I pi_N", real=True)
dW_I = sp.diff(sp.log(b), I) + piI_s + b * dlnL_I.subs(x, I) - dlnL_I.subs(x, I)
dR_I = sp.diff(sp.log(a), I) + piI_s + b * dlnL_I.subs(x, I)
dW_N = sp.diff(sp.log(b), N) + piN_s + b * dlnL_N.subs(x, N) - dlnL_N.subs(x, N)
dR_N = sp.diff(sp.log(a), N) + piN_s + b * dlnL_N.subs(x, N)
check("S3 dlnW/dI = pi_I - 1/(b(1+eps))", dW_I - (piI_s - 1 / (b * (1 + eps))))
check("S3 dlnR/dI = pi_I + 1/(a(1+eps))", dR_I - (piI_s + 1 / (a * (1 + eps))))
check("S3 dlnW/dN = pi_N + 1/(b(1+eps))", dW_N - (piN_s + 1 / (b * (1 + eps))))
check("S3 dlnR/dN = pi_N - 1/(a(1+eps))", dR_N - (piN_s - 1 / (a * (1 + eps))))

# ---------------- S4 threshold ----------------
# In regime (R), a = I-N+1 > 0 and b = N-I > 0 are constants; declare them positive for SymPy.
Kv, gI, ap, bp, Lp = sp.symbols("K_v gamma_I a b L", positive=True)
omega_tilde = bp * Kv / (ap * Lp)  # W/R in regime (R), eq. (2.3)
dW = sp.log(omega_tilde / gI) - 1 / (bp * (1 + eps))
K_hat_formula = ap * Lp * gI / bp * sp.exp(1 / (bp * (1 + eps)))
check("S4 K_hat is a zero of dlnW/dI", sp.expand_log(dW.subs(Kv, K_hat_formula), force=True))
check("S4 dlnW/dI strictly increasing in K (derivative = 1/K > 0)", sp.diff(dW, Kv) - 1 / Kv)
check("S4 K_hat / K_I = exp(1/(b(1+eps))) with K_I = a L gamma_I / b",
      K_hat_formula / (ap * Lp * gI / bp) - sp.exp(1 / (bp * (1 + eps))))

# ---------------- P6 paper Proposition 3 at sigma_hat = 1 ----------------
Wp, Rp, gp = sp.symbols("W R gamma_I", positive=True)
paper_prod = ((Wp / gp) ** (1 - s) - Rp ** (1 - s)) / (1 - s)
check("P6 lim_{s->1} paper productivity = ln(W/(gamma R))",
      sp.limit(paper_prod, s, 1) - sp.log(Wp / (gp * Rp)))
integral_form = sp.integrate(sp.Symbol("y", positive=True) ** (-s), (sp.Symbol("y", positive=True), Rp, Wp / gp))
check("P6 integral form = paper productivity (s != 1)",
      sp.simplify(sp.piecewise_fold(integral_form).args[0][0] - paper_prod)
      if isinstance(integral_form, sp.Piecewise) else integral_form - paper_prod)
bb_, eps_ = sp.symbols("b epsilon_L", positive=True)
aa_ = 1 - bb_
Gamma1 = bb_  # int_I^N gamma^0 = b
LambdaI = 1 / Gamma1 + 1 / aa_
sL = bb_
check("P6 paper displacement (1-sL) Lambda_I/(1+eps) = 1/(b(1+eps))",
      (1 - sL) * LambdaI / (1 + eps_) - 1 / (bb_ * (1 + eps_)))
LambdaN = 1 / Gamma1 + 1 / aa_
check("P6 paper reinstatement (1-sL) Lambda_N/(1+eps) = 1/(b(1+eps))",
      (1 - sL) * LambdaN / (1 + eps_) - 1 / (bb_ * (1 + eps_)))
check("P6 paper rental term sL Lambda_I/(1+eps) = 1/(a(1+eps))",
      sL * LambdaI / (1 + eps_) - 1 / (aa_ * (1 + eps_)))

print("\nALL SYMBOLIC CHECKS PASSED" if ok else "\nSOME SYMBOLIC CHECKS FAILED")
sys.exit(0 if ok else 1)
