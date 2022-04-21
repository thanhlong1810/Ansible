#!/bin/bash
_ip=`ip -4 addr | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | awk 'FNR == 2 {print}'`
LOGFILE="/var/log/clamav/clamav-$(date +'%Y-%m-%d').log"
EMAIL_MSG="Please see the log file attached from $_ip"
# EMAIL_FROM="clamav-daily@example.com";
# EMAIL_TO="username@example.com";
DIRTOSCAN="/home /etc /tmp /root /var"
_Exclude="/var/lib"

for S in ${DIRTOSCAN}
do
 DIRSIZE=$(du -sh "$S" 2>/dev/null | cut -f1)

 echo "Starting a daily scan of "$S" directory.
 Amount of data to be scanned is "$DIRSIZE"."

 clamscan -ri --exclude-dir="$_Exclude" "$S" >> "$LOGFILE"

 # get the value of "Infected lines"
 MALWARE=$(tail "$LOGFILE"|grep Infected|cut -d" " -f3)

 # if the value is not equal to zero, send an email with the log file attached
 if [ "$MALWARE" -ne "0" ]
 then
#  using heirloom-mailx below
#  echo "$EMAIL_MSG"|mail -a "$LOGFILE" -s "Malware Found" -r "$EMAIL_FROM" "$EMAIL_TO";
curl -s -X POST https://api.telegram.org/bot5237038374:AAErk5cvF_Ua3b2nM1-dbjULKhBmPixA4NQ/sendMessage -d chat_id=-698823940 -d text="$EMAIL_MSG - Dir $S" 
curl -F document=@"$LOGFILE" https://api.telegram.org/bot5237038374:AAErk5cvF_Ua3b2nM1-dbjULKhBmPixA4NQ/sendDocument?chat_id=-698823940
 fi 
done

exit 0
