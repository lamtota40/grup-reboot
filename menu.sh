#!/bin/bash

# Ambil semua nama menuentry, urut sesuai di grub.cfg
mapfile -t entries < <(
  grep "^menuentry" /boot/grub/grub.cfg \
    | sed -E "s/^menuentry ['\"]([^'\"]+)['\"].*/\1/"
)

# Tampilkan daftar dengan select
PS3="Silahkan pilih nomor menu: "
select entry in "${entries[@]}"; do
  if [[ -n "$entry" ]]; then
    echo "Kamu memilih: $entry"
    sudo grub-reboot "$entry"
    echo "Reboot ke: $entry"
    sleep 2
    sudo reboot
    break
  else
    echo "Pilihan tidak valid, coba lagi."
  fi
done
