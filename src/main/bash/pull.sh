YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color
echo -e "$YELLOW"
echo $'               .,-:;//;:=,'
echo $'           . :H@@@MM@M#H/.,+$;,'
echo $'        ,/X+ +M@@M@MM$=,-$HMMM@X/,'
echo $'      -+@MM; $M@@MH+-,;XMMMM@MMMM@+-'
echo $'     ;@M@@M- XM@X;. -+XXXXXHHH@M@M#@/.'
echo $'   ,$MM@@MH ,@$=             .---=-=:=,.'
echo $'   =@#@@@MX.,                -$HX$$$$$:;'
echo $'  =-./@M@M$                   .;@MMMM@MM:'
echo $'  X@/ -$MM/                    . +MM@@@M$'
echo $' ,@M@H: :@:         \033[0;31m^^\033[1;33m         . =X#@@@@-'
echo $' ,@@@MMX, .   \E[0;31mPulling  repos\E[1;33m   /H- ;@M@M='
echo $' .H@@@@M@+,                    $MM+..$#$.'
echo $'  /MMMM@MMH/.                  XM@MH; =;'
echo $'   /$+$$XHH@$=              , .H@@@@MX,'
echo $'    .=--------.           -$H.,@@@@@MX,'
echo $'     $MM@@@HHHXX$$$$+- .:$MMX =M@@MM$.'
echo $'      =XMMM@MM@MM#H;,-+HMM@M+ /MMMX='
echo $'        =$@M@M#@$-.=$@MM@@@M; $M$='
echo $'          ,:+$+-,/H#MMMMMMM@= =,'
echo $'                =++$$$$+/:-.'
echo -e "$NC"
echo 

isValidFolder(){
	local _FOLDER=" $1 "
	#Filter gradle
	if [[ " .gradle gradle src build libs vendor " == *"$_FOLDER"* ]]; then
		return 0
	#Filter intellij
	elif  [[ " .idea out " == *"$_FOLDER"* ]]; then
		return 0
	#Filter eclipse
	elif  [[ " .metadata .recommenders .settings bin eclipse " == *"$_FOLDER"* ]]; then
		return 0
	#Filter visual studio (bin\debug and bin\release already filtered in eclipse bin\)
	elif  [[ " .vs debug release packages obj " == *"$_FOLDER"* ]]; then
		return 0
	#Filter visual studio code
	elif  [[ " .vscode " == *"$_FOLDER"* ]]; then
		return 0
	#Filter Minecraft Repos
	elif  [[ " runClient runServer run " == *"$_FOLDER"* ]]; then
		return 0
	fi
	
	return 1
}

counter(){
    for file in "$1"/.[^.]* "$1"/*
    do
	BASE=$(basename "$file")
    if [ -d "$file" ]; then
		if [ "$BASE" == ".git" ]; then
			CD="$PWD"
			cd "$file"
			cd ..
			echo -e "$GREEN$(basename "$PWD")$NC"
			git pull
			cd "$CD"
			if [ $? == 127 ]; then
				exit
			fi
			echo -e "$YELLOW-----------------------------------$NC"
			break
        else
			isValidFolder $BASE
			if [ $? == 1 ]; then
				counter "$file"
			fi
		fi
	elif [ "$BASE" = ".ignorerepos" ]; then
		break
    fi
    done
}

if [ -z "$1" ]; then
	if [ -z "${REPOS}" ]; then
		echo -e "${RED}Pulling from current directory: ${PWD//\\//}$NC\n"
		counter "$PWD"
	else
		echo -e "${RED}Pulling from REPOS env var: ${REPOS//\\//}$NC\n"
		counter "$REPOS//\\//"
	fi
else
	echo -e "${RED}Pulling from passed argument path: ${1//\\//}$NC\n"
	counter "${1//\\//}"
fi

echo 
read -n1 -r -p 'Press any key to exit...' key