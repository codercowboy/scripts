FILE=$1
echo "Summarizing report: $FILE"
#prints everything out sorted
function find_interesting {
	#app type of 1T means 'ipad free or paid'
	#app type of 1 means 'iphone/itouch free or paid'
	#we're just changing both to say '1', b/c we don't care which device..
	cat ${FILE} | awk -F'\t' '{print "sku:",$3,"id:",$5,"type:",$7,"units:",$8, "price:", $16, "e";}' | egrep "1T units|1 units" | sort
}

find_interesting

#1 is sku
function count_free {
        SUM=0
        for COUNT in `find_interesting | grep "sku: $1" | sed 's/.*units: //' | sed 's/ price.*//'`
        do
                SUM=$(($SUM+$COUNT))
        done
        echo "$SUM"
}

#1 is sku
function count_sales {
	SUM=0
	for COUNT in `find_interesting | grep "sku: $1" | grep -v "price: 0 e" | sed 's/.*units: //' | sed 's/ price.*//'`
	do
		SUM=$(($SUM+$COUNT))	
	done
	echo "$SUM"
}

#1 is ipad units
#2 is iphone units
#3 is iphone free units
#4 is ipad free units
#5 is photo lift units
function print_totals {
	IPAD_REV=`echo "scale=2;$1 * 1.40" | bc`
	echo "ipad units moved: $1, revenue per: 1.40, total revenue: $IPAD_REV"
	IPHONE_REV=`echo "scale=2;$2 * 0.70" | bc`
	echo "iphone units moved: $2, revenue per: 0.70 total revenue: $IPHONE_REV"
	TOTAL_REV=`echo "scale=2;${IPAD_REV} + ${IPHONE_REV}" | bc`
	REV_EACH=`echo "scale=2;${TOTAL_REV} / 3.0" | bc`
	echo "total: ${TOTAL_REV}, each of us: ${REV_EACH}" 
	echo "file: ${FILE}, to hd: ${1} (free: ${4}), to: ${2} (free: ${3}), pl: ${5}, rev: ${TOTAL_REV}, each: ${REV_EACH}"
}


IPAD_COUNT=`count_sales 0001`
IPHONE_COUNT=`count_sales 02`
IPAD_FREE_COUNT=`count_free 05`
IPHONE_FREE_COUNT=`count_free 03`
PHOTO_LIFT_COUNT=`count_free 04`
print_totals ${IPAD_COUNT} ${IPHONE_COUNT} ${IPHONE_FREE_COUNT} ${IPAD_FREE_COUNT} ${PHOTO_LIFT_COUNT}
