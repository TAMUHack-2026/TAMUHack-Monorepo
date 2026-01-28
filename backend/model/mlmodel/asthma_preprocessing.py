import numpy as np


def to_flow_rate(voltages: list, K: float = 1.0, baseline_voltage: float = 0) -> np.ndarray:
    """
    voltages: list of floats reperesting voltages over time
    K: calibration constant 
    sampling_rate: float in ms(5 ms = 200hz)
    baseline_voltage: float representing the voltage when the airflow is 0

    returns flow ->nd array
    """

    voltages = np.asarray(voltages)
    return K*(voltages - baseline_voltage)

def detect_start_index(*,flow, exhale_positive=True, frac_of_peak=0.05, min_consecutive=5):
    """
    Detect start of forced exhalation as first sustained crossing of a threshold.
    Threshold = frac_of_peak * peak_flow.

    frac_of_peak: filters values that are too low compared to the intial threshold
    min_consecutive essentialy forces a local monotonic property(strictly increaisng/strictly decreasing) for a set of datapoints
    """

    flow = np.asarray(flow, dtype=float)

    s = flow if exhale_positive else -flow
    peak = np.nanmax(s)
    thr = frac_of_peak * peak

    above = s >= thr
    # Find first index where we have min_consecutive Trues
    if len(above) < min_consecutive:
        return 0
    run = np.convolve(above.astype(int), np.ones(min_consecutive, dtype=int), mode="valid")
    idxs = np.where(run == min_consecutive)[0]

    return int(idxs[0]) if len(idxs) else 0

def create_time(sampling_rate, num_samples):
    return np.asarray([sampling_rate + i*sampling_rate for i in range(num_samples)])

def volume_from_flow(flow, sampling_rate = 0.005, start_idx=None, exhale_positive=True):
    """
    Integrate flow to cumulative exhaled volume using trapezoidal integration.
    Returns volume array (same length as input), with 0 at start_idx and before.
    """
    flow = np.asarray(flow, dtype=float)
    time = create_time(sampling_rate, len(flow))

    if start_idx is None:
        start_idx = detect_start_index(flow = flow, exhale_positive = exhale_positive)


    s = flow if exhale_positive else -flow

    vol = np.zeros_like(s)
    if start_idx >= len(s) - 1:
        return vol, start_idx
    
    

    # Trapezoidal integration: V[i] = V[i-1] + 0.5*(f[i]+f[i-1])*(t[i]-t[i-1])
    dt = np.diff(time)
    incr = 0.5 * (s[start_idx+1:] + s[start_idx:-1]) * dt[start_idx:]
    vol[start_idx+1:] = np.cumsum(incr)

    # Ensure monotone nondecreasing (helps with small negative noise)
    vol = np.maximum.accumulate(vol)

    return vol, start_idx




def fev1_from_volume(volume, time, start_idx):
    """
    FEV1 = exhaled volume at 1.0 second after start.
    Uses interpolation on volume(time).
    """
    volume = np.asarray(volume, dtype=float)
    time = np.asarray(time, dtype=float)

    t0 = time[start_idx]
    target_t = t0 + 1.0

    if target_t > time[-1]:
        # Not enough duration — return volume at last sample (best available)
        return float(volume[-1] - volume[start_idx])

    v_at_target = np.interp(target_t, time, volume)
    return float(v_at_target - volume[start_idx])

def fvc_from_volume(volume):
    """FVC = max exhaled volume (L)."""
    v = np.asarray(volume, dtype=float)
    return float(np.nanmax(v))

def pef_from_flow(flow, exhale_positive=True):
    """PEF = peak expiratory flow (L/s)."""
    f = np.asarray(flow, dtype=float)
    s = f if exhale_positive else -f
    return float(np.nanmax(s))


def fef25_75_from_flow_volume(flow, volume, fvc, start_idx=0, exhale_positive=True):
    """
    FEF25–75% = average flow between 25% and 75% of FVC.
    """
    flow = np.asarray(flow, dtype=float)
    volume = np.asarray(volume, dtype=float)

    s = flow if exhale_positive else -flow

    # Restrict to post-start region
    v = volume[start_idx:]
    f = s[start_idx:]

    # Enforce monotonic volume for interpolation
    dv = np.diff(v)
    keep = np.concatenate([[True], dv > 1e-12])
    v2 = v[keep]
    f2 = f[keep]

    if len(v2) < 2:
        return float("nan")

    v_lo = 0.25 * fvc
    v_hi = 0.75 * fvc

    # Clamp to valid range
    v_lo = max(v_lo, v2[0])
    v_hi = min(v_hi, v2[-1])
    if v_hi <= v_lo:
        return float("nan")

    # Sample evenly in volume space
    v_grid = np.linspace(v_lo, v_hi, 200)
    f_grid = np.interp(v_grid, v2, f2)

    # Average flow over the interval
    return float(np.trapezoid(f_grid, v_grid) / (v_hi - v_lo))


def blow_duration(flow, time, start_idx, exhale_positive=True,
                  end_flow_threshold=0.05, min_consecutive=5):
    """
    Compute blow duration using an existing start_idx.
    """
    flow = np.asarray(flow, dtype=float)
    time = np.asarray(time, dtype=float)

    s = flow if exhale_positive else -flow
    s = np.maximum(s, 0.0)  # suppress tiny negatives

    post = s[start_idx:]
    below = post <= end_flow_threshold

    if len(post) < min_consecutive:
        return float(time[-1] - time[start_idx]), len(time) - 1

    run = np.convolve(below.astype(int), np.ones(min_consecutive, dtype=int), mode="valid")
    idxs = np.where(run == min_consecutive)[0]

    if len(idxs) == 0:
        end_idx = len(time) - 1
    else:
        end_idx = start_idx + int(idxs[0])

    duration = float(time[end_idx] - time[start_idx])
    return duration, end_idx


def summary_statistics(voltages =  [_ for _ in range(1000)]):
    """
    returns a dictionary of summary stats

    """
    
    flow  = to_flow_rate(voltages)
    volume, start_idx= volume_from_flow(flow)
    time = create_time(0.005,len(flow))

    stats = {}
    
    stats["fev1"] = fev1_from_volume(volume,time,start_idx)
    stats["fvc"] = fvc_from_volume(volume)
    stats["pef"] = pef_from_flow(flow)
    stats["fef25_75"] = fef25_75_from_flow_volume(flow, volume, stats["fvc"],start_idx)
    stats["blow_duration"] = blow_duration(flow,time,start_idx)

    return stats








