# 🧮 BIOS Bootloader: BMI Calculator (Real-Mode x86 Assembly)

This is a minimal bootable 512-byte x86 real-mode program that calculates a **Body Mass Index (BMI)** using x87 FPU, then displays the result in the BIOS text mode during system boot.

> 💡 Example output when booting:  
> `BMI: 24.1`

## ✅ Features

- Pure 16-bit **boot sector code**, `ORG 0x7C00`
- Uses **FPU (`fld`, `fdiv`, `fistp`)** for BMI = weight / height²
- Outputs result using BIOS `int 10h` teletype (`ah=0Eh`)
- Compiles to exactly **512 bytes** with boot signature (`55AA`)
- Fully testable with **QEMU**

---

## ⚙️ Requirements

- [`nasm`](https://www.nasm.us/) — Netwide Assembler  
- [`qemu-system-x86_64`](https://wiki.qemu.org/Main_Page) — for testing

Optional: `xxd`, `hexdump`, `od` for viewing the binary.

---

## 🛠️ Compile and Run

```bash
# 1. Assemble to raw 512-byte boot sector
nasm -f bin boot_bmi.asm -o boot_bmi.bin

# 2. Boot it with QEMU (text output in terminal)
qemu-system-x86_64 -drive if=floppy,file=boot_bmi.bin,format=raw -boot a -nographic
