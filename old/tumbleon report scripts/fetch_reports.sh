cd `dirname ${0}`

java Autoingestion ${PSG_USER}@${PSG_HOST} ${PSG_PASSWORD} 85382400 Sales Daily Summary

mkdir -p reports
mv *.txt.gz reports/
cd reports/
gunzip -f *.txt.gz
cd -
rm summary.txt

for FILE in `find reports -type f | grep -v ".gz"`
do
	echo $FILE
	./calc_report.sh $FILE | grep "file: " | sed 's/.*382400_//' | sed 's/.txt//' | tee -a summary.txt
done

IPHONE_RANK=`curl -s http://appshopper.com/bestsellers/social-networking/paid/?device=iphone | grep -B 5 "TumbleOn" | tr '\n' ' ' | sed 's/.*num">//' | sed 's/<.*//'`
IPAD_RANK=`curl -s http://appshopper.com/bestsellers/social-networking/paid/?device=ipad | grep -B 5 "TumbleOn" | tr '\n' ' ' | sed 's/.*num">//' | sed 's/<.*//'`

echo "ipad rank: ${IPAD_RANK} iphone rank: ${IPHONE_RANK}" | tee -a summary.txt

echo "finished in ${SECONDS} seconds, `date`" | tee -a summary.txt

scp -i ~/.ssh/tumbleOnKey summary.txt ${TO_USER}@${TO_HOST}:~/sites/tumbleonapp.com/htdocs/sales_summary.txt
