#!/bin/ksh

#####################################################################
echo "-----------------------------------------------------"
echo " Script: gfs_transfer.sh" 
echo " "
echo " Purpose - Copy GFS Posts to /nwges and /com"
echo "           Alert posted files to DBNet"
echo " "
echo " History - "
echo "    Cooke   - 04/21/05 - Inital version, based off of"
echo "                         global_transfer.sh"
echo "-----------------------------------------------------"
#####################################################################
set -xa
 
# export CNVGRIB=/nwprod/util/exec/cnvgrib
# export GRB2INDX=/nwprod/util/exec/grb2index
# export WGRIB2=/nwprod/util/exec/wgrib2

if test "$SAVEGES" = "YES" -a $fhr -le 15 -a `expr $fhr % 3` -eq 0
then
  cp $COMIN/${RUN}.t${cyc}z.sf$fhr $GESdir/${RUN}.${cycle}.sf$fhr
  cp $COMIN/${RUN}.t${cyc}z.bf$fhr $GESdir/${RUN}.${cycle}.bf$fhr

  msg="Guess files for fcst hour $fhr copied to $GESdir"
  postmsg "$jlogfile" "$msg"
fi
 
if test "$SENDCOM" = "YES"
then
   #
   # Save Pressure and SFLUX GRIB/GRIB Index files
   #
   cp flxifile $COMOUT/${RUN}.${cycle}.sfluxgrbif$fhr
   
# Chuang: keeping gfs surface files around because post and dng
# use them now   
   #if [[ $fhr -gt 84 ]]
   #then
   #  if [[ $fhr -ne 120 && $fhr -ne 168 ]]
   #    then
   #      rm $COMOUT/${RUN}.${cycle}.bf$fhr
   #  fi
   #fi
fi

############################################
# Convert the sflux file to grib2 format:
############################################
#cp $COMIN/${RUN}.${cycle}.sfluxgrbf$fhr sfluxgrbf$fhr
if [ `expr $fhr % 3` -eq 0 ]; then
$CNVGRIB -g12 -p40 $COMIN/${RUN}.${cycle}.sfluxgrbf$fhr sfluxgrbf${fhr}.grib2
$WGRIB2 sfluxgrbf${fhr}.grib2 -s> sfluxgrbf${fhr}.grib2.idx

if [ $SENDCOM = YES ]
then
  cp sfluxgrbf${fhr}.grib2 $COMOUT/${RUN}.${cycle}.sfluxgrbf${fhr}.grib2
  cp sfluxgrbf${fhr}.grib2.idx $COMOUT/${RUN}.${cycle}.sfluxgrbf${fhr}.grib2.idx
fi

fi
#
# DBNet Alerts for gfs suite
#

if test "$SENDDBN" = 'YES' -a "$RUN" = 'gfs' 
then
  if [ `expr $fhr % 3` -eq 0 ]; then
  $DBNROOT/bin/dbn_alert MODEL GFS_SGB $job $COMOUT/${RUN}.${cycle}.sfluxgrbf$fhr
  $DBNROOT/bin/dbn_alert MODEL GFS_SGBI $job $COMOUT/${RUN}.${cycle}.sfluxgrbif$fhr
  $DBNROOT/bin/dbn_alert MODEL GFS_SGB_GB2 $job $COMOUT/${RUN}.${cycle}.sfluxgrbf${fhr}.grib2
  $DBNROOT/bin/dbn_alert MODEL GFS_SGB_GB2_WIDX $job $COMOUT/${RUN}.${cycle}.sfluxgrbf${fhr}.grib2.idx
  fi

  $DBNROOT/bin/dbn_alert MODEL GFS_SF $job $COMOUT/${RUN}.${cycle}.sf$fhr

 
  if [[ $fhr -gt 0  && $fhr -le 84  ]]
  then
     $DBNROOT/bin/dbn_alert MODEL GFS_BF $job $COMOUT/${RUN}.${cycle}.bf$fhr
  fi
  if [[ $fhr -eq 120  ]]
  then
     $DBNROOT/bin/dbn_alert MODEL GFS_BF $job $COMOUT/${RUN}.${cycle}.bf$fhr
  fi
fi

exit 
