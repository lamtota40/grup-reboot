#!/usr/bin/env python3

import os
import re
import signal
import sys

# Handle ctrl-c signal
def handle_signal(signalnum, frame):
    sys.exit(0)

# Fetch current grub entries from '/boot/grub/grub.cfg' file
def get_entries():
    entries = []
    pattern = re.compile(r"^\s*menuentry\s+['\"](.+?)['\"]", re.MULTILINE)
    with open('/boot/grub/grub.cfg', 'r') as grub_cfg_file:
        data = grub_cfg_file.read()
        entries = pattern.findall(data)
    return entries

if __name__ == '__main__':
    signal.signal(signal.SIGINT, handle_signal)

    entries = get_entries()
    if not entries:
        print("No grub entries found in /boot/grub/grub.cfg")
        sys.exit(1)

    while True:
        print('Choose the entry to reboot into:')
        for index, entry in enumerate(entries):
            print('{}. {}'.format(index, entry))

        print('*. press ctrl-c to terminate the process!')

        try:
            input_str = input('input: ')
            user_input = int(input_str)
            if 0 <= user_input < len(entries):
                break
            else:
                print(f'invalid entry number: "{input_str}"')
        except ValueError:
            print(f'invalid entry number: "{input_str}"')

        print()

    print(f'rebooting into "{entries[user_input]}"...')
    os.system(f"sudo grub-reboot {user_input} && sudo reboot")
