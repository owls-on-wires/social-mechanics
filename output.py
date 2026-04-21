"""Plotting and export functions for Social Mechanics simulation."""

import json
import numpy as np
import matplotlib.pyplot as plt

from main import N, T, NAMES, GAMMA_A, GAMMA_R, DELTA, ALPHA_R, a_equilibrium


def plot_results(tau_hist, A_hist, R_hist, filename="docs/dynamics.png"):
    fig, axes = plt.subplots(3, 1, figsize=(14, 10), sharex=True)
    fig.patch.set_facecolor("#0a0a0f")
    for ax in axes:
        ax.set_facecolor("#0a0a0f")
        ax.tick_params(colors="#888")
        ax.spines[:].set_color("#333")
        ax.grid(alpha=0.15, color="#444")

    pairs = [
        (0, 1, "Couple: Alice–Bob", "#e06060"),
        (2, 3, "Couple: Carol–Dan", "#60a0e0"),
        (0, 2, "Friends: Alice–Carol", "#80c080"),
        (4, 5, "Eve–Frank", "#d0a040"),
        (0, 4, "Friends: Alice–Eve", "#a080c0"),
    ]

    # τ
    ax = axes[0]
    for i, j, label, color in pairs:
        ax.plot(tau_hist[:, i, j], label=label, alpha=0.85, color=color, linewidth=1)
    tau_thresh = np.sqrt(DELTA / GAMMA_A)
    ax.axhline(tau_thresh, color="#666", linestyle=":", alpha=0.5,
               label=f"τ* = {tau_thresh:.1f} (bistability)")
    ax.set_ylabel("τ (hrs/day)", color="#aaa")
    ax.set_title("Interaction Time", color="#ccc", fontsize=13)
    ax.legend(loc="upper right", fontsize=8, facecolor="#1a1a28", edgecolor="#333",
              labelcolor="#ccc")

    # A
    ax = axes[1]
    for i, j, label, color in pairs:
        ax.plot(A_hist[:, i, j], label=label, alpha=0.85, color=color, linewidth=1)
    ax.set_ylabel("Attraction (A)", color="#aaa")
    ax.set_title("Attention Matrix", color="#ccc", fontsize=13)
    ax.legend(loc="upper right", fontsize=8, facecolor="#1a1a28", edgecolor="#333",
              labelcolor="#ccc")

    # R
    ax = axes[2]
    for i, j, label, color in pairs:
        ax.plot(R_hist[:, i, j], label=label, alpha=0.85, color=color, linewidth=1)
    ax.set_ylabel("Repulsion (R)", color="#aaa")
    ax.set_xlabel("Day", color="#aaa")
    ax.set_title("I-Need Space", color="#ccc", fontsize=13)
    ax.legend(loc="upper right", fontsize=8, facecolor="#1a1a28", edgecolor="#333",
              labelcolor="#ccc")

    plt.tight_layout()
    plt.savefig(filename, dpi=150, facecolor="#0a0a0f")
    print(f"Saved {filename}")

    print(f"\nτ* (bistability threshold) = {tau_thresh:.2f} hrs/day")
    print(f"R runaway critical excess = {DELTA / (GAMMA_R * ALPHA_R):.3f}")
    print(f"A equilibrium at τ=5: {a_equilibrium(5):.3f}")
    print(f"A equilibrium at τ=2: {a_equilibrium(2):.3f}")
    print(f"A equilibrium at τ=0.3: {a_equilibrium(0.3):.4f}")


def export_json(tau_hist, filename="docs/sim.json"):
    """Export simulation as JSON for the perspective visualization."""
    step = 2
    frames = []
    for t in range(0, T, step):
        tau = tau_hist[t]
        pairs = {}
        for i in range(N):
            for j in range(i + 1, N):
                pairs[f"{i},{j}"] = round(float(tau[i, j]), 4)
        frames.append({"day": t, "tau": pairs})

    # Compute global tau range for color scaling
    all_tau = []
    for f in frames:
        all_tau.extend(f["tau"].values())
    tau_max = max(all_tau) if all_tau else 1

    data = {
        "names": NAMES,
        "n": N,
        "tauMax": round(tau_max, 4),
        "frames": frames,
    }

    with open(filename, "w") as f:
        json.dump(data, f)
    print(f"Saved {filename} ({len(frames)} frames)")


if __name__ == "__main__":
    from main import simulate
    tau_hist, A_hist, R_hist = simulate(seed=42)
    plot_results(tau_hist, A_hist, R_hist)
    export_json(tau_hist)
