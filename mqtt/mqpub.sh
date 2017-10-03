export LD_LIBRARY_PATH=/var/etc/persistent/mqtt
while sleep 10; 
do 
    cat /proc/power/active_pwr2 | ./mosquitto_pub -h 192.168.155.20 -t home/mpower1/2/activepwr -s
    cat /proc/power/cf_count2 | ./mosquitto_pub -h 192.168.155.20 -t home/mpower1/2/cfcount -s
    /sbin/cgi /usr/www/mfi/sensors.cgi | tail -n +3 | /var/etc/persistent/mqtt/mosquitto_pub -h 192.168.155.20 -t home/mpower1/sensors -s
done