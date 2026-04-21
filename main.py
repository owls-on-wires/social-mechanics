"""
Social Mechanics — Dynamics Simulation v2
"""

import numpy as np

# ── Parameters ──────────────────────────────────────────────────────

N = 8
S = 12.0             # social meter (hrs/day)
BETA = 6.0           # softmax sharpness
GAMMA_A = 0.006      # attraction growth rate (quadratic in tau)
GAMMA_R = 0.004      # repulsion growth rate
DELTA = 0.015        # universal decay rate (attraction and repulsion)
ALPHA_R = 8.0        # repulsion compounding factor
R_THRESH = 0.15      # interaction fraction threshold for repulsion
SIGMA_A = 0.008      # attraction noise
SIGMA_R = 0.003      # repulsion noise
SIGMA_TAU = 0.05     # schedule noise
T = 730              # days (~2 years)

NAMES = ["Alice", "Bob", "Carol", "Dan", "Eve", "Frank", "Grace", "Hiro"]


def a_equilibrium(tau):
    """Theoretical equilibrium A for a given tau."""
    return GAMMA_A * tau**2 / (GAMMA_A * tau**2 + DELTA)


def initialize(seed=42):
    rng = np.random.default_rng(seed)

    A = np.full((N, N), 0.04)
    R = np.full((N, N), 0.002)
    np.fill_diagonal(A, 0)
    np.fill_diagonal(R, 0)

    # Couples: high attention
    for i, j in [(0, 1), (2, 3)]:
        A[i, j] = A[j, i] = 0.85 + rng.uniform(-0.03, 0.03)

    # Friends: moderate attention
    for i, j in [(0, 2), (1, 3), (0, 4), (2, 5), (4, 6), (5, 7), (1, 6)]:
        v = 0.5 + rng.uniform(-0.05, 0.05)
        A[i, j] = A[j, i] = v

    # "Hey I think you'd really get along with..."
    A[4, 5] = 0.2
    A[5, 4] = 0.25

    return A, R, rng


def softmax_allocate(sigma):
    sigma_masked = sigma.copy()
    np.fill_diagonal(sigma_masked, -1e10)
    row_max = sigma_masked.max(axis=1, keepdims=True)
    exp_sigma = np.exp(BETA * (sigma_masked - row_max))
    np.fill_diagonal(exp_sigma, 0)
    sums = exp_sigma.sum(axis=1, keepdims=True)
    sums = np.maximum(sums, 1e-10)
    return S * exp_sigma / sums


def step(A, R, rng):
    sigma = A - R
    tau_desired = softmax_allocate(sigma)
    tau = np.minimum(tau_desired, tau_desired.T)

    noise_tau = rng.normal(0, SIGMA_TAU, (N, N))
    noise_tau = (noise_tau + noise_tau.T) / 2
    tau = tau + noise_tau
    np.fill_diagonal(tau, 0)
    tau = np.clip(tau, 0, None)

    row_sums = tau.sum(axis=1)
    for i in range(N):
        if row_sums[i] > S:
            tau[i, :] *= S / row_sums[i]
    tau = (tau + tau.T) / 2
    np.fill_diagonal(tau, 0)
    tau = np.clip(tau, 0, None)

    a_growth = GAMMA_A * tau**2 * (1 - A)
    a_decay = DELTA * A
    A_new = A + a_growth - a_decay + rng.normal(0, SIGMA_A, (N, N))
    A_new = np.clip(A_new, 0, 1)
    np.fill_diagonal(A_new, 0)

    frac = tau / S
    excess = np.maximum(0, frac - R_THRESH)
    r_growth = GAMMA_R * (1 + ALPHA_R * R) * excess
    r_decay = DELTA * R
    R_new = R + r_growth - r_decay + rng.normal(0, SIGMA_R, (N, N))
    R_new = np.clip(R_new, 0, 1)
    np.fill_diagonal(R_new, 0)

    return tau, A_new, R_new


def simulate(seed=42):
    A, R, rng = initialize(seed)
    tau_hist = np.zeros((T, N, N))
    A_hist = np.zeros((T, N, N))
    R_hist = np.zeros((T, N, N))

    for t in range(T):
        tau, A, R = step(A, R, rng)
        tau_hist[t] = tau
        A_hist[t] = A
        R_hist[t] = R

    return tau_hist, A_hist, R_hist


if __name__ == "__main__":
    from output import plot_results, export_json
    tau_hist, A_hist, R_hist = simulate(seed=42)
    plot_results(tau_hist, A_hist, R_hist)
    export_json(tau_hist)
