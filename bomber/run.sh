#!/bin/bash
cd "$( dirname "${BASH_SOURCE[0]}" )"

pids=()

while getopts u:m: option
do
case "${option}"
in
u) URL=${OPTARG};;
m) MESSAGES_AMOUNT=${OPTARG};;
n) MEETING_NAME=${OPTARG};;
esac
done

if [ -z "$URL" ] ; then
   echo -e "Enter BBB Base Server URL:"
   read URL
fi;
if [ -z "$URL" ] ; then
    echo "No URL provided";
    exit 1;
fi;

if [ -z "$MESSAGES_AMOUNT" ] ; then
   echo -e "Enter Amount of Messages to be sent by the BOMBER:"
   read MESSAGES_AMOUNT
fi;
if [ -z "$MESSAGES_AMOUNT" ] ; then
    echo "No MESSAGES_AMOUNT provided";
    exit 1;
fi;

if [ -z "$MEETING_NAME" ] ; then
   echo -e "Enter BBB MEETING_NAME:"
   read MEETING_NAME
fi;
if [ -z "$MEETING_NAME" ] ; then
    echo "No MEETING_NAME provided";
    exit 1;
fi;

echo URL: $URL;
echo MESSAGES_AMOUNT: $MESSAGES_AMOUNT "message(s)";
echo MEETING_NAME: $MEETING_NAME;

echo "Executing..."

echo "To join the meeting, click this link: $URL/demo/demoHTML5.jsp?username=Viewer&meetingname=$MEETING_NAME&isModerator=false&action=create";

date=$(date +"%d-%m-%Y")

n=1
while [[ -d "data/${date}_${n}" ]] ; do
    n=$(($n+1))
done

basePath=data/${date}_${n}

mkdir -p $basePath

node bomber.js "$URL" "$basePath" $MESSAGES_AMOUNT $MEETING_NAME &> $basePath/bomber.out &
pids+=($!)

function killprocs()
{
    echo killing ${pids[@]}
    rm -rf $basePath
    kill ${pids[@]}
}

trap killprocs EXIT 

wait "${pids[@]}"
exitcode=$?
trap - EXIT

if [ $exitcode -eq 0 ]
    then
    echo "The Test was ran successfully !"
    exit 0
    else
    echo "There was an error while running your Test !"
    exit 1
fi