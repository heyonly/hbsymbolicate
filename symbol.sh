#!/bin/bash
usage(){
	echo ""
	echo "usage sh symbol.sh -l <path/ipa.crash> -b <path/example.app/example> -o destination.crash"
	echo "-l crash report"
	echo "-b crash binary"
	echo "-o destination.crash"
}
while getopts ":l:b:o:h:" opt
    do
        case "${opt}" in
            l)  CRASHREPORT=${OPTARG}
                ;;
            b)  BINARY=${OPTARG}
                ;;
            o)  DEST=${OPTARG}
                ;;
            h)  usage
                exit 0
                ;;
        esac
    done
echo $DEST;
if [ ! -n "$DEST" ];then
	DEST=/tmp/temp.crash;
fi
ARCHITECTURE=`sed -n '/Binary Images:/{n;p;}' $CRASHREPORT | awk -F" " '{print $5}'`;	
sed -n '/^Thread.*Crashed:/,/^$/p' $CRASHREPORT | while read line; do
if [[ $line =~ ^[0-9] ]];then
	numbers=`echo $line |awk -F" " '{print $1}'`;
	binary=`echo $line |awk -F" " '{print $2}'`;
	loadAddress=`echo $line |awk -F" " '{print $4}'`; 
	stackAddress=`echo $line |awk -F" " '{print $3}'`;
	if [[ $loadAddress == 0x* ]];then
	      	crashInfo=`atos -arch $ARCHITECTURE -o $BINARY -l $loadAddress $stackAddress`;
		crashline="${numbers}\t       ${binary}\t        ${crashInfo}";
		echo $crashline >> $DEST
	else
		echo $line >> $DEST
	fi		
else	
	echo $line >> $DEST
fi
done
