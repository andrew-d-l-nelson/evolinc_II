#!/bin/bash

# Script to process cuffcompare output file to generate lincRNA
# Usage: 
# sh BLASTn_pipeline.sh  -g subjectgenome.fa -s subject_species -q query_species -l lincRNAquery.fa -subject_gff

while getopts ":l:q:s:e:hg:" opt; do
  case $opt in
    l)
      lincRNAfasta=$OPTARG
    ;;
    q)
      query_species=$OPTARG
      ;;
    s)
      subject_species=$OPTARG
      ;;
    e)
      subject_gff=$OPTARG
      ;;
    h)
      echo "USAGE : open script in text editor"
      exit 1
      ;;
    g)
      subject_genome=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

makeblastdb -in $subject_genome -dbtype nucl -out BLAST_DB/$subject_genome.blast.out

blastn -query $lincRNAfasta -db BLAST_DB/$subject_genome.blast.out -num_threads 4 -penalty -2 -reward 1 -gapopen 5 -gapextend 2 -dust no -word_size 8 -evalue 1e-20 -outfmt "6 qseqid sseqid pident length qlen qstart qend sstart send evalue bitscore" -out BLAST_Return/$subject_species.out 

sed 's/ //g' BLAST_Return/$subject_species.out >BLAST_Return/$subject_species.stripped.out

perl blast2gff.pl -i BLAST_Return/$subject_species.stripped.out -s $subject_species -o BLAST_Return/$subject_species.out.gff

python merge_close_hits.py BLAST_Return/$subject_species.out.gff BLAST_Return/$subject_species.out.merged.gff

perl gtftocdna.pl BLAST_Return/$subject_species.out.merged.gff $subject_genome >BLAST_Return/$subject_species.$query_species.orthologs.fasta

#gffread $subject_gff -g $subject_genome -w $subject_gff.fasta

makeblastdb -in $subject_gff -dbtype nucl -out BLAST_DB/$subject_gff.blast.out
#No subject_gff blastdb will be made if there is no subject_gff provided. That is okay, as the following scripts will run and simply not reannotate sequence IDs.

blastn -query BLAST_Return/$subject_species.$query_species.orthologs.fasta -db BLAST_DB/$subject_gff.blast.out -num_threads 4 -penalty -2 -reward 1 -gapopen 5 -gapextend 2 -dust no -word_size 8 -evalue 1e-20 -outfmt "6 qseqid sseqid pident length qlen qstart qend sstart send evalue bitscore" -out BLAST_Return/$subject_species.annotation.out
#An error prompt will show up if no subject_gff is provided. This is okay!

python filter_sequences_annotation.py BLAST_Return/$subject_species.annotation.out BLAST_Return/$subject_species.annotation.sense.list.txt BLAST_Return/$subject_species.annotation.antisense.list.txt

python assign_sense_annotation.py BLAST_Return/$subject_species.$query_species.orthologs.fasta BLAST_Return/$subject_species.annotation.sense.list.txt BLAST_Return/$subject_species.$query_species.orthologs.sense.renamed.fasta

python assign_antisense_annotation.py BLAST_Return/$subject_species.$query_species.orthologs.sense.renamed.fasta BLAST_Return/$subject_species.annotation.antisense.list.txt BLAST_Return/$subject_species.$query_species.orthologs.renamed.fasta

perl Sort_FASTA_Alp.pl -r BLAST_Return/$subject_species.$query_species.orthologs.renamed.fasta >BLAST_Return/$subject_species.$query_species.orthologs_alpha.fasta

perl Remove_dup_seqs.pl BLAST_Return/$subject_species.$query_species.orthologs_alpha.fasta


cp BLAST_Return/$subject_species.$query_species.orthologs_alpha.fasta.dup_removed.fasta Orthologs