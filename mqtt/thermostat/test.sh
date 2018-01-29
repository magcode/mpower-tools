#!/bin/sh
# ./test.sh 0 0.2 19.7   mode hyster actTemp
			hyster=$2
            targetTemp=20
            actTemp=$3
			i=1
			roomName="bl"
			currentMode=$1
				
            withHysterLow=$(awk -vn1="$targetTemp" -vn2="$hyster" 'BEGIN{print n1-n2}')
            withHysterHigh=$(awk -vn1="$targetTemp" -vn2="$hyster" 'BEGIN{print n1+n2}')
			echo withHysterLow $withHysterLow
			echo withHysterHigh $withHysterHigh

            belowHystLow=$(awk -vn1="$actTemp" -vn2="$withHysterLow" 'BEGIN{print (n1<n2)?1:0 }')
            aboveHystHigh=$(awk -vn1="$actTemp" -vn2="$withHysterHigh" 'BEGIN{print (n1>n2)?1:0 }')
			belowHystHigh=$(awk -vn1="$actTemp" -vn2="$withHysterHigh" 'BEGIN{print (n1<=n2)?1:0 }')

 			echo belowHystLow $belowHystLow
			echo aboveHystHigh $aboveHystHigh
			echo belowHystHigh $belowHystHigh
			
			# currently not heating
			if [ "$currentMode" -eq 0 ];then
				if [ "$belowHystLow" -eq 1 ];then
                    debug=`printf "Channel %s (%s) - ActTemp: %s TargetTemp: %s Too cold, start heating." "$i" "$roomName" "$actTemp" "$targetTemp"`
                    currentMode=1
				else
					debug=`printf "Channel %s (%s) - ActTemp: %s TargetTemp: %s Warm enough, keep heating off." "$i" "$roomName" "$actTemp" "$targetTemp"`
				fi
			# currently heating
			elif [ "$currentMode" -eq 1 ];then
				if [ "$aboveHystHigh" -eq 1 ];then
					debug=`printf "Channel %s (%s) - ActTemp: %s TargetTemp: %s Warm enough, stop heating." "$i" "$roomName" "$actTemp" "$targetTemp"`
				elif [ "$belowHystHigh" -eq 1 ];then
					debug=`printf "Channel %s (%s) - ActTemp: %s TargetTemp: %s Too cold, continue heating." "$i" "$roomName" "$actTemp" "$targetTemp"`
				fi
			fi
			echo "x:$debug"