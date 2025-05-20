#!/bin/bash

GRUB_CFG="/boot/grub/grub.cfg"

# Fungsi untuk menampilkan menu dan membaca pilihan
boot_menu() {
    # Header
    echo "============================="
    echo "           Menu Boot"
    echo "============================="
    echo "Silahkan pilih (format '1>2' untuk submenu):"
    echo

    # Inisialisasi counter dan state
    main_index=0
    brace_depth=0
    submenu_start_depth=0
    submenu_main_index=0
    submenu_index=0

    # Baca setiap baris grub.cfg
    while IFS= read -r line; do
        # Hitung perubahan brace depth
        opens=$(grep -o '{' <<< "$line" | wc -l)
        closes=$(grep -o '}' <<< "$line" | wc -l)
        (( brace_depth += opens - closes ))

        # Deteksi submenu (" atau ')
        if [[ $line =~ ^[[:space:]]*submenu[[:space:]]\"([^\"]+)\" ]]; then
            name="${BASH_REMATCH[1]}"
        elif [[ $line =~ ^[[:space:]]*submenu[[:space:]]\'([^\']+)\' ]]; then
            name="${BASH_REMATCH[1]}"
        else
            name=""
        fi

        if [[ -n "$name" ]]; then
            echo "$main_index. $name"
            submenu_start_depth=$brace_depth
            submenu_main_index=$main_index
            submenu_index=0
            (( main_index++ ))
            continue
        fi

        # Deteksi menuentry (" atau ')
        if [[ $line =~ ^[[:space:]]*menuentry[[:space:]]\"([^\"]+)\" ]]; then
            entry="${BASH_REMATCH[1]}"
        elif [[ $line =~ ^[[:space:]]*menuentry[[:space:]]\'([^\']+)\' ]]; then
            entry="${BASH_REMATCH[1]}"
        else
            entry=""
        fi

        if [[ -n "$entry" ]]; then
            if (( submenu_start_depth>0 && brace_depth>submenu_start_depth )); then
                echo "${submenu_main_index}>${submenu_index}. $entry"
                (( submenu_index++ ))
            else
                echo "$main_index. $entry"
                (( main_index++ ))
            fi
            continue
        fi

        # Keluar dari submenu saat kedalaman turun kembali
        if (( submenu_start_depth>0 && brace_depth<=submenu_start_depth )); then
            submenu_start_depth=0
        fi

    done < "$GRUB_CFG"

    # Prompt pilihan
    echo
    echo "catatan: jika ingin boot submenu, contoh input \"1>2\""
    read -p "Silahkan input pilihan anda : " pilihan
}

# Panggil fungsi untuk menampilkan menu dan membaca pilihan
boot_menu

# Validasi input dan eksekusi reboot
if [[ "$pilihan" =~ ^[0-9]+$ ]] || [[ "$pilihan" =~ ^[0-9]+\>[0-9]+$ ]]; then
    sudo grub-reboot "$pilihan"
    echo "Reboot ke GRUB entri $pilihan..."
    sleep 2
    sudo reboot
else
    echo "Input tidak valid!"
    exit 1
fi
