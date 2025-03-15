import csv
from datetime import datetime
import os
import re
from datetime import datetime, timedelta
import numpy as np

# name of output .csv file containing measurment data
measumements_name = 'measurments_MAXN_GPU_DLAv2.csv'

# Define GMAC values for each network (example values)
gmac_values = {
    'unetv2': 2.7, # or 10.6??
    'mobilenetv2': 0.39, # or 0.3 or 0.585 ?
    'resnet50v1prep': 4.2,
    'mobilenetssdv1prep': 1.3,
    'resnet34ssdv1prep': 216.8,
    'inceptionh3v2': 11.1,  #3.8   Replace with actual GMAC value for Inception2
    'dlv3': 5.7  # Replace with actual GMAC value for DLv3
}

# Define the regular expression pattern to match the mean latency line
# pattern = r"Latency:.*mean = (\d+\.\d+) ms"

def extract_log_info(log_file_path):
    """
    This function reads the log file and extracts the number of queries, the mean latency and the duration without warmups.
    """
    num_queries = 0
    mean_latency = 0
    with open(log_file_path, 'r') as log_file:
        log_content = log_file.read()
        match = re.search(r"Timing trace has (\d+) queries over (\d+\.\d+) s", log_content)
        if match:
            num_queries = int(match.group(1))
            duration_wo_warmups = float(match.group(2))
        match = re.search(r"Latency:.*mean = (\d+\.\d+) ms", log_content)
        if match:
            mean_latency = float(match.group(1))

    return num_queries, mean_latency, duration_wo_warmups

# Function to calculate the integral power
def calculate_integral_power(network_data, energy_data):
    integral_power = 0
    
    for i in range(len(network_data)):
        start_time, end_time = network_data[i]
        relevant_energy_data = [(timestamp, power) for timestamp, power in energy_data if start_time <= timestamp <= end_time]
        duration_mean = np.mean([energy_data[i+1][0] - energy_data[i][0]  for i in range(len(energy_data)-1)])
        duration_min = min([energy_data[i+1][0] - energy_data[i][0]  for i in range(len(energy_data)-1)])
        duration_max = max([energy_data[i+1][0] - energy_data[i][0]  for i in range(len(energy_data)-1)])

        print("MEAN, MIN and MAX time intervals: ",  duration_mean.total_seconds() * 1000, duration_min.total_seconds() * 1000, duration_max.total_seconds() * 1000)

        for j in range(1, len(relevant_energy_data)):
            time_diff = (relevant_energy_data[j][0] - relevant_energy_data[j - 1][0]).total_seconds()
            integral_power += 0.5 * ((relevant_energy_data[j][1] / 1000) + (relevant_energy_data[j - 1][1] / 1000)) * time_diff
        
    return integral_power

# Function to calculate average power during inference
def calculate_average_power(network_data, energy_data):
    total_power = 0
    total_queries = 0
    for i in range(len(network_data)):
        start_time, end_time = network_data[i]
        relevant_energy_data = [(timestamp, power) for timestamp, power in energy_data if start_time <= timestamp <= end_time]
        
        total_queries += len(relevant_energy_data)-1
        for j in range(1, len(relevant_energy_data)):
            total_power += 0.5 * ((relevant_energy_data[j][1] / 1000) + (relevant_energy_data[j - 1][1] / 1000))
    if total_queries == 0:
        return 0
    return total_power / total_queries

data = {} # used to store measurment data
# Process log files in folders starting with "power_MAXN_0ms_"
main_directory = '.'  # Assuming log files are in the current directory
network_queries = {}  # Dictionary to store number of queries for each network
for folder_name in os.listdir(main_directory):
    if folder_name.startswith('power_MODE_MAXN_0ms_') and os.path.isdir(folder_name):
        network = folder_name.replace('power_MODE_MAXN_0ms_', '')  # Remove prefix (get network name)
        print(f"Processing folder: {folder_name} for network: {network}")
        if network not in network_queries:
            network_queries[network] = {}
            data[network] = {}
        for log_file_name in os.listdir(folder_name):
            if log_file_name.endswith('.log'):
                log_file_path = os.path.join(main_directory, folder_name, log_file_name)
                num_queries, mean_latency, duration_wo_warmups = extract_log_info(log_file_path)
                network_queries[network][log_file_name] = {'num_queries': num_queries, 'mean_latency': mean_latency, 'duration_wo_warmpus':duration_wo_warmups}
                data[network] = {'network': network, 'mean_latency': mean_latency, 'num_queries': num_queries}
#print(network_queries)
print("\n")

# Load inference timestamps from the CSV file
network_timestamps = {}
with open('inference_timestamps.csv', newline='') as csvfile:
    reader = csv.DictReader(csvfile)
    for row in reader:
        network = row['Engine'].split('/')[0]
        start_time = datetime.strptime(row['StartTimestamp'], "%Y-%m-%d %H:%M:%S.%f")
        end_time = datetime.strptime(row['EndTimestamp'], "%Y-%m-%d %H:%M:%S.%f")
        # To avoid counting warm ups
        duration_wo_warmups = network_queries[network][list(network_queries[network].keys())[0]]['duration_wo_warmpus']
        start_time = end_time - timedelta(seconds=duration_wo_warmups)
        if network not in network_timestamps:
            network_timestamps[network] = []
        network_timestamps[network].append((start_time, end_time))

#print(network_timestamps)
# Load energy measurements from the second CSV file
energy_measurements = []
with open('power_data.csv', newline='') as csvfile:
    reader = csv.reader(csvfile)
    next(reader)  # Skip header
    for row in reader:
        if len(row[0].split('.')) == 2 : # wrong measure otherwise
            timestamp, milliseconds = row[0].split('.')
            timestamp_with_ms = f"{timestamp}.{milliseconds[:3]}"
            timestamp = datetime.strptime(timestamp_with_ms, "%Y-%m-%d %H:%M:%S.%f")
            power = float(row[1])
            energy_measurements.append((timestamp, power))

# Print the accumulated number of queries for each network
for network, queries in network_queries.items():
    total_queries = sum(query_info['num_queries'] for query_info in queries.values())
    print(f"Network: {network}, Total queries: {total_queries}")

print("\n")
# Print the mean latency for each network
for network, queries in network_queries.items():
    mean_latencies = [query_info['mean_latency'] for query_info in queries.values() if query_info['mean_latency'] != 0]
    if mean_latencies:
        mean_latency = sum(mean_latencies) / len(mean_latencies)
        print(f"Network: {network}, Mean latency: {mean_latency} ms")
    else:
        print(f"No mean latency found for network: {network}")
print("\n")

# Calculate the integral power per query for each network
for network, timestamps in network_timestamps.items():
    if network in network_queries:
        total_queries = sum(query_info['num_queries'] for query_info in network_queries[network].values())
        integral_power = calculate_integral_power(timestamps, energy_measurements)
        integral_power_per_query = integral_power / total_queries if total_queries > 0 else 0

        gmac = gmac_values.get(network, 0)
        energy_efficiency = gmac / integral_power_per_query
        average_power = calculate_average_power(timestamps, energy_measurements)
        print(f"Network: {network}, Average power during inference: {average_power} Watts")
        print(
            f"Network: {network}, Integral power per query: {integral_power_per_query} Joules/Query, GMAC: {gmac}, Energy Efficiency: {energy_efficiency} GMAC/J")
        data[network].update({"average_power" : average_power, 'integral_power_per_query' : integral_power_per_query, 'energy_efficienty' : energy_efficiency, 'gmac' : gmac})
    else:
        print(f"No queries found for network: {network}. Skipping calculation.")
    print("\n")


# create folder to contain measurments
if not os.path.exists('measurments/'):
    os.makedirs('measurments/')
    
# write mesurment data to .csv file
with open('measurments/'+measumements_name, 'w', newline='') as csvfile:
    fieldnames = ['network', 'mean_latency', 'num_queries', 'average_power', 'integral_power_per_query', 'energy_efficienty', 'gmac']
    writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
    writer.writeheader()
    for network, network_data in data.items():
        row = {
            'network': network,
            'average_power': network_data.get('average_power', 0),
            'integral_power_per_query': network_data.get('integral_power_per_query', 0),
            'energy_efficienty': network_data.get('energy_efficienty', 0),
            'gmac': network_data.get('gmac', 0),
            'mean_latency': network_data.get('mean_latency', 0),
            'num_queries': network_data.get('num_queries', 0)
        }
        writer.writerow(row)