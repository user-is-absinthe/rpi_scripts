import subprocess


def replacer(changed_string, list_replace):
    changed_string = str(changed_string)
    for r in list_replace:
        changed_string = changed_string.replace(r, '')
    return changed_string


# network screen
network_status = 'Connected to:'
# cmd = "iwconfig wlan0 | sed -n 's/.*Access Point: \([0-9\:A-F]\{17\}\).*/\1/p'"
cmd = "iwgetid -r"
bssid_name = subprocess.check_output(cmd, shell=True)
# print(type(bssid_name))
# bssid_name = 'Wi-Fi: ' + str(bssid_name)
# print(bssid_name)

cmd = "hostname -I | cut -d\' \' -f1"
ip = subprocess.check_output(cmd, shell=True)
ip = 'IP: ' + replacer(ip, ["'", 'b', '\\', 'n'])

print(network_status, bssid_name, ip, sep='\n')
