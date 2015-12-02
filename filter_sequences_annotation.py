__author__ = 'upendrakumardevisetty'

import sys

infile = sys.argv[1] # input file for blast output
outfile_sense = sys.argv[2] # output listfile for filtered sense strant blast output
outfile_antisense = sys.argv[3] # output listfile for filtered antisense strant blast output


final = list()
with open(infile, 'rU' ) as fh_in:
    for line in fh_in:
        line = line.strip()
        line = line.split()
	ID = "%s\t%s" % (line[0], line[1])
        pident = line[2]
        evalue = line[10]
	sstart = line[8]
	send = line[9]
        if float(pident) > 99:
            if evalue > '10e-20':
		if sstart < send:
           	     final.append(ID)
            	    # print line

with open(outfile_sense, "w") as fh_out:
    final_uniq = set(final)
    final2 = "\n".join(list(final_uniq))
    fh_out.write(final2)

final = list()
with open(infile, 'rU' ) as fh_in:
    for line in fh_in:
        line = line.strip()
        line = line.split()
	ID = "%s\t%s" % (line[0], line[1])
        pident = line[2]
        evalue = line[10]
	sstart = line[8]
	send = line[9]
        if float(pident) > 99:
            if evalue > '10e-20':
		if sstart > send:
               	 final.append(ID)
               	 # print line

with open(outfile_antisense, "w") as fh_out:
    final_uniq = set(final)
    final2 = "\n".join(list(final_uniq))
    fh_out.write(final2)