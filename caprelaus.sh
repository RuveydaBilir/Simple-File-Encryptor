#!/bin/bash
# Banner
figlet caprelaus
echo "                          operation: 1.1"
echo ""

help(){
echo "Enter action and directory:"
echo "-change : to change your password"
echo "-lock : to lock files"
echo "-unlock : to unlock files"
exit 1
}

ACTION=$1
DIR=$2
HASH="hash.txt"

lock(){
if [[ -d $DIR ]]
then
echo "Locking files in directory: $DIR"

for FILE in "$DIR"/*; do
        if [[ -f $FILE ]]; then
        if [[ $FILE != $HASH ]]; then
        echo Locking file: $FILE
        openssl enc -aes-256-cbc -salt -pbkdf2 -in $FILE -out "$FILE".cap -pass pass:$PASS
        if [[ $? -eq 0 ]]
        then
            rm "$FILE"
        else
            echo "Failed to lock the file: $FILE"
        fi
        fi
        fi
done
fi
}
unlock(){
        if [[ -d $DIR ]]; then
                echo "Unlocking files in directory $DIR"
                for FILE in "$DIR"/*.cap; do
                        if [[ -f $FILE ]]; then
                        OUT="${FILE%.cap}"
                        echo Unlocking file: $FILE
                        openssl enc -d  -aes-256-cbc -pbkdf2 -in $FILE -out "$OUT" -pass pass:$PASS
                        if [[ $? -eq 0 ]]
                        then
                                rm "$FILE"
                        else
                                 echo "Failed to unlock the file: $FILE"
                        fi
                        fi
                done
        fi
}
start(){
        if [[ ! -e $HASH ]]; then
                local password="password"
                local var=$(echo -n "$password" | md5sum | awk '{print $1}')
                echo "$var">"$HASH"
                echo "$HASH is created."
        fi
        PASS=$(cat "$HASH")

        read -p "Enter your password: " usrPass
        usrPassHash=$(echo -n "$usrPass" | md5sum | awk '{print $1}')

        if [[ "$usrPassHash" == "$PASS" ]]; then
                case "$ACTION" in
                lock)
                         lock
                        ;;
                unlock)
                        unlock
                        ;;
                *)
                         usage
                        ;;
                esac

        else
                echo "Wrong password."
        fi
}
change(){
        echo "Change function" 
}
 
if [ "$#" -ne 2 ]; then
    help
else
    start
fi
