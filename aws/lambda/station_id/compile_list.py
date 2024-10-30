import csv

def import_and_sort_csv(file_path):
    # Step 1: Import data from CSV file
    with open(file_path, mode='r', newline='', encoding='utf-8') as file:
        data = []
        for line in file:
            # Split each line on the first comma only
            id_str, name = line.strip().split(',', 1)
            data.append((name.strip(), int(id_str.strip())))  # Strip whitespace for clean entries

    # Step 2: Sort the data by the name
    sorted_data = sorted(data, key=lambda x: x[0])

    return sorted_data

def export_to_py(sorted_data, py_file_path):
    # Step 3: Export to a .py file with a variable
    with open(py_file_path, 'w', encoding='utf-8') as file:
        file.write("sorted_data = [\n")
        for name, id_num in sorted_data:
            file.write(f"    ({name!r}, {id_num}),\n")
        file.write("]\n")

# Sample usage
csv_file_path = 'station_list.csv'  # Replace with the path to your CSV file
sorted_data = import_and_sort_csv(csv_file_path)

# Export sorted data to .py file and pickle file
export_to_py(sorted_data, 'sorted_station_list.py')
