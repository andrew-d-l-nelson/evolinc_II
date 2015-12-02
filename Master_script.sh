#!/bin/bash

# Script to process cuffcompare output file to generate lincRNA
# Usage: 
# sh BLASTn_pipeline.sh -s Species_lincRNA_list -b Blasting_list -n total_number_of_species -t species_tree

while getopts ":s:b:n:t:h:" opt; do
  case $opt in
    s)
      Species_lincRNA_list=$OPTARG
	;;
	b)
      Blasting_list=$OPTARG	#This is a five-column tab-delimited list in the following order:
		# subject_genome	lincRNA_fasta	query_species (four letter Genus-species designation ie., Gspe)	subject_species (same four letter abbreviation as subject_species)	subject_gff (in fasta_format)
		# All of these files should be in the current working folder
		;;
	t)
      Species_tree=$OPTARG
      ;;
	n)
      Total_number_of_species=$OPTARG
      ;;
    h)	echo 	"USAGE : sh lincRNA_pipeline.sh 
		          -s 	</path/to/Species_lincRNA_list.txt>
	 		  -b 	</path/to/BLASTing_list in tab-delimited format>
			  -t 	</path/to/Species_tree for all species examined in newick format>
			  -n 	<total number of species examined, a number>"
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done
mkdir -p BLAST_DB
mkdir -p BLAST_Return
mkdir -p Orthologs
python startup_script.py $Blasting_list
cd Orthologs
cat * >All_orthologs.fasta
perl ../find_from_list.pl $Species_lincRNA_list All_orthologs.fasta
cd lincRNA_families
rename 's/_.fasta/.fasta/' *.fasta
ls * > alignment_list.txt
sed -i '/alignment_list.txt/d' alignment_list.txt
mkdir -p aligned_families
perl ../../Batch_MAFFT.pl alignment_list.txt
cd aligned_families
ls * >aligned_list.txt
sed -i '/aligned_list.txt/d' aligned_list.txt
#mkdir -p Raxml_families
#perl ../../../Batch_Raxml.pl aligned_list.txt
#cd Raxml_families
python ../../../Family_division_and_summary.py $Total_number_of_species
#Script to divide the families up based on composition. Divisions would be "species_specific" if the family only consisted of one species;
#"poorly_conserved" if there were less than four unique taxa, "moderately_conserved" if there were four or more unique taxa, but less than the total (as determined by input)
#This script would then push the families into specific subfolders:
#These subfolders would be "species_specific", "poorly_conserved", "moderately_conserved", and "completely_conserved"
#for each subfolder:




# NOTUNG variables
#      setenv CLASSPATH $CLASSPATH:<pathname> 
#ls -A *.newick >batch_list_for_NOTUNG.txt
#sed -i 1i"$Species_tree" batch_list_for_NOTUNG.txt
#java -jar Notung-2.6.jar -b batch_list_for_NOTUNG.txt --root --treeoutput newick --nolosses --speciestag prefix --savepng --treestats --info --log --homologtabletabs --edgeweights name
#java -jar Notung-2.6.jar -b batch_list_for_NOTUNG.txt --rearrange --threshold 70 --treeoutput newick --nolosses --speciestag prefix --savepng --treestats --info --log --homologtabletabs --edgeweights name  --stpruned