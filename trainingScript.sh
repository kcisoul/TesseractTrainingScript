#!/bin/sh
clear

echo " "
echo " "
echo "### tess-script ############################################"
echo "# "
echo "# An tesseract training utiility for "
echo "# The Early-Modern OCR Project (eMOP) "
echo "# "
echo "# Copyright 2013 - eMOP  "
echo "# "
echo "# Modified by kcisoul
echo "# "
echo "#######################################################"
echo " "
echo " "

#### ------------------mjc: 05022013----------------------------------------------------
# The script takes an input file name (without an extension, so something like "emop.mfle.exp18") and running all the necessary commands to build the training files.

#

# The command looks like this:
##          ==============================================================================
##           sh ./tess-script.sh <inputfile(s)>
##          ==============================================================================

# Where:
#          <inputfile(s)>: input file(s) with path  --(relative from the folder where your XSLT is running)
#          NOTE: the input file is the common prefix of the name of a set of tiff/box file pairs. i.e. leave off the .tif/.box

#### ------------------mjc: 050213----------------------------------------------------

#Loop through passed params and assign global var values
infile=($@)
len=${#infile[@]}

for ((i=0; i<=$len-1; i++))
do
     echo " "
     echo "#####################################"
     echo "tesseract ${infile[$i]} ${infile[$i]} nobatch box.train"
     echo "#####################################"

     for var in ${infile[$i]} ;
     do
    #echo "$var"
    echo $var | cut -d'.' -f1
    echo $var | cut -d'.' -f2
    echo $var | cut -d'.' -f3

    language=`echo $var | cut -d'.' -f1` #
    fontName=`echo $var | cut -d'.' -f2` #
    fileNum=`echo $var | cut -d'.' -f3` #
     done

     #run tesseract on the passed in tifs to create training files for each
     tesseract ${infile[$i]}  ${infile[$i]} nobatch box.train
     #rename the passed in files to have the '.tr' extension
     #infile[$i]=${infile[$i]}.tr
done

#create the training file name for the whole set of passed in files by taking a prefix that doesn't include the exp #, the append a '.tr' extension.
outlen=${#infile[0]}-2
outfile=${infile[0]:0:$outlen}.tr

#concat all created training files into one
echo " "
echo "#####################################"
echo "concat all training files into one"
for ((i=0; i<=$len-1; i++))
do
     trin[$i]=${infile[$i]}.tr
done
echo "cat ${trin[@]} > $outfile"
echo "#####################################"
cat ${trin[@]} > $outfile


#extract unicharset from all related box files
echo " "
echo "#####################################"
echo "extract unicharset from all related box files"
echo "unicharset_extractor *.box"
echo "#####################################"
unicharset_extractor *.box

echo "planet 1 0 0 0 0" > ${language}.font_properties

echo " "
echo "#####################################"
echo "mftraining -F ${language}.font_properties -U unicharset -O ${language}.unicharset $outfile"
echo "#####################################"
mftraining -F ${language}.font_properties -U unicharset -O ${language}.unicharset $outfile

echo " "
echo "#####################################"
echo "cntraining $outfile"
echo "#####################################"
cntraining $outfile

echo " "
echo "#####################################"
echo "change output filenames"
echo "mv inttemp ${language}.inttemp"
echo "mv normproto ${language}.normproto"
echo "mv pffmtable ${language}.pffmtable"
echo "mv shapetable ${language}.shapetable"
echo "#####################################"
mv inttemp ${language}.inttemp
mv normproto ${language}.normproto
mv pffmtable ${language}.pffmtable
mv shapetable ${language}.shapetable

echo " "
echo "#####################################"
echo "combine_tessdata "  ${language}.
echo "#####################################"
combine_tessdata ${language}.
