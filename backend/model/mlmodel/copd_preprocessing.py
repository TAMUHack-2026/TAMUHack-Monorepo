from asthma_preprocessing import to_flow_rate
import numpy as np
import pandas as pd
from scipy import signal
import os


'''
must create xlsx in copd/data directory

'''

def _downsample_data(flow_rate_data, source_rate = 200, target_rate = 100):
    """downsamples data from 5 ms to 10 ms by cutting the points in half"""

    downsample_factor = int(source_rate/target_rate)
    if downsample_factor == 1:
        # No downsampling needed
        return flow_rate_data

    # Design anti-aliasing filter (low-pass filter)
    # Cutoff at Nyquist frequency of target rate
    nyquist_freq = target_rate / 2  # 50 Hz for 100 Hz target
    cutoff_normalized = nyquist_freq / (source_rate / 2)  # Normalize to [0, 1]
    
    # Design a Butterworth low-pass filter
    b, a = signal.butter(4, cutoff_normalized, btype='low')
    
    # Apply filter
    flow_filtered = signal.filtfilt(b, a, flow_rate_data)
    
    # Decimate (take every Nth sample)
    flow_downsampled = flow_filtered[::downsample_factor]
    
    return flow_downsampled
 
def process_excel_file(voltages, source_rate = 200, target_rate = 100):
    
    flow_data = _downsample_data(
        flow_rate_data = to_flow_rate(voltages),
        source_rate = source_rate,
        target_rate = target_rate
    )

    #creating time
    time = np.linspace(0,len(flow_data)/target_rate, len(flow_data))
    dt = 1.0 / target_rate

    pef = np.max(flow_data)
    fvc = np.trapezoid(flow_data,time)

    one_second_idx = int(target_rate)

    fev1 = np.trapezoid(flow_data[:one_second_idx], time[:one_second_idx])

    data = {
        'fvc': [fvc],
        'fev1':[fev1],
        'pef': [pef],
        'flow'
        : [flow_data] # may need to do flow_data.tolist()
    }

    df = pd.DataFrame(data)

    out_dir = "COPD_Early_Prediction"
    os.makedirs(out_dir, exist_ok = True)
    excel_path = os.path.join(out_dir, "infer.xlsx")
    df.to_excel(excel_path, index = False)
