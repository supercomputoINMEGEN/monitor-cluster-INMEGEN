# run this script for a quick portable test

# ask to erase previous logs
if [ -d $(pwd)/logs ]
then
	rm -rfi $(pwd)/logs
fi \
&& bash $(pwd)/master_monitor.sh
