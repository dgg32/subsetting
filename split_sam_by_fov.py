#@V350053925L4C002R012

import sys, os, re

headers = []

fov_reads = {}

rx = re.compile('([A-Z]\d+)(L\d)(C\d{3}R\d{3})')

input_sam = sys.argv[1]
output_folder = sys.argv[2]
prefix_length = int(sys.argv[3])

for line in open(input_sam, 'r'):
    if line.startswith('@'):
        headers.append(line.strip())
    else:
        fields = line.strip().split('\t')
        read_name = fields[0]

        fov_id = read_name[:prefix_length]

        if fov_id not in fov_reads:
            fov_reads[fov_id] = "\n".join(headers) + "\n"
        
        fov_reads[fov_id] += line.strip() + "\n"

for fov_id in fov_reads:
    search_name = rx.search(fov_id)
    #print (fov_id)
    if search_name:
        lane = search_name.group(2)

        lane = lane[0] + "0" + lane[1:]

        filename = search_name.group(1) + '_' + lane + '_' + search_name.group(3) + "_Read1_none" + '.sam'
        
        output_path = os.path.join(output_folder, filename)
        #print (output_path)
        with open(output_path, 'w') as output_file:
            output_file.write(fov_reads[fov_id])