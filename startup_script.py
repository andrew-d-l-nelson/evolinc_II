__author__ = 'asherkhb'

from subprocess import call
import sys

#Ensure correct number of arguments are entered
if len(sys.argv) != 2:
    print("Incorrect usage syntax: Must specify input list.\nUse 'startup_script.py <input>'")
    exit()

#Assign input file from first command argument.
inputfile = sys.argv[1]

with open(inputfile, 'r') as inpt:
    for line in inpt:
        if line == '\n':
            pass
        else:
            line_split = line.split('\t')

            subject = line_split[0]
            lincRNA = line_split[1]
            query_spp = line_split[2]
            subject_spp = line_split[3]
            try:
                try:
                    subject_gff = line_split[4]
                    known_lincRNAs = line_split[5]
                    if subject_gff != '':
                        query = "sh Building_Families.sh -g %s -l %s -q %s -s %s -e %s -k %s" % \
                                (subject, lincRNA, query_spp, subject_spp, subject_gff, known_lincRNAs)
                    else:
                        query = 'sh Building_Families_no_GFF.sh -g %s -l %s -q %s -s %s -k %s' % \
                                (subject, lincRNA, query_spp, subject_spp, known_lincRNAs)

                except IndexError:
                    subject_gff = line_split[4]
                    query = 'sh Building_Families_no_lincRNA_database.sh -g %s -l %s -q %s -s %s -e %s' % \
                            (subject, lincRNA, query_spp, subject_spp, subject_gff)
            except IndexError:
                query = 'sh Building_Families_no_GFF_no_lincRNA_database.sh -g %s -l %s -q %s -s %s' % \
                        (subject, lincRNA, query_spp, subject_spp)
        call(query, shell=True)