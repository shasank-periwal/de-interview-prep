# col1	col2	col3	    col4	col5	col6	col7	col8	...
# 1	    2	    {data:data}	data	data	data	data	data	...
								
								
								
# col1	col2	addl col						
# 1	    2	    {col3:{data:data}, col4:data, col5:data, col6:data, col7:data, col8:data}

# lst = rows[0].split(',')[2:]

# for row in rows[1:]:
#     dct  = defaultdict()
#     data = row.split(',')[2:]

#     for i in range(len(lst)):
#         dct[lst[i]] = data[i]
    
#     row.append(dct)

import csv
import json

input_file = "../assets/sample_input.csv"
output_file = "output.csv"

with open(input_file, mode="r") as infile, open(output_file, mode="w", newline="") as outfile:
    reader = csv.DictReader(infile)
    
    # Output headers
    fieldnames = ["col1", "col2", "addl_col"]
    writer = csv.DictWriter(outfile, fieldnames=fieldnames)
    writer.writeheader()
    
    for row in reader:
        col1 = row["col1"]
        col2 = row["col2"]
        
        # Take all other cols dynamically
        addl = {k: v for k, v in row.items() if k not in ["col1", "col2"]}
        
        writer.writerow({
            "col1": col1,
            "col2": col2,
            "addl_col": json.dumps(addl)  # store as JSON string
        })
