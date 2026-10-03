# Challenge Writeup

## **Challenge Overview**
- **Category**: Pwn
- **Synopsis**: An FSOP (File Stream Oriented Programming) challenge in ARM64 environment, where players must change stderr specifically to gain shell access from the [`exit()`](https://man7.org/linux/man-pages/man3/exit.3.html) sequence.

- **Written by**: **Spinel99**

## **Analysis of Given Assets**:

* **Binary analysis**:
```sh
$ file chall
chall: ELF 64-bit LSB pie executable, ARM aarch64, version 1 (SYSV), dynamically linked, interpreter [OMMITED]/ld-linux-aarch64.so.1, for GNU/Linux 3.7.0, BuildID[sha1]=e5bd31bc51fc4116c339c2d93eb568d4e1318bf5, not stripped

$ checksec chall       
    Arch:       aarch64-64-little
    RELRO:      Full RELRO
    Stack:      Canary found
    NX:         NX enabled
    PIE:        PIE enabled
    RUNPATH:    ...
    Stripped:   No
```

* **LIBC Version (After Extraction)**:

```sh
$ strings libc.so.6 | grep 'GNU C Library'
GNU C Library (Ubuntu GLIBC 2.43-2ubuntu2.3) stable release version 2.43.
```

### Notes
- dependencies can be identified from inside provided container using [`ldd`](https://man7.org/linux/man-pages/man1/ldd.1.html) and extracted from there.
- To patch the binary, one can use [`patchelf`](https://github.com/NixOS/patchelf).

### Summary
Given binary is hardened, it's also an AARCH64 binary so not the usual x86-64, with LIBC relatively new.

## **Static Analysis: Reverse-Engineering the Binary**
The app basically:
1. Reads 0x12C bytes of Base64-Encoded input
2. Decodes it onto approximately 0xE0 bytes
3. Injects the decode directly onto stderr and returns.

Here's the decompiled `main()` function after some name and type improvements:
```c
int __fastcall main(int argc, const char **argv, const char **envp)
{
  FILE *_stderr; // [xsp+10h] [xbp-140h]
  char b64_payload[304]; // [xsp+18h] [xbp-138h] BYREF

  setup();
  _stderr = stderr;
  printf("This message leads straight to the end at %p, can you blossom anew from it?\n", &exit);
  printf("Your response: ");
  memset(b64_payload, 0, 0x12Du);
  read(0, b64_payload, 0x12Cu);
  __b64_pton(b64_payload, (u_char *)_stderr, 0xE0u);
  return 0;
}
```

## **Dynamic Analysis: Testing the Waters**
No dynamic analysis needed, behavior is straight forward.
The exploitation is straight-forward, we must get shell, we can use [GDB](https://man7.org/linux/man-pages/man1/gdb.1.html), for me I generally use [pwndbg](https://pwndbg.re/stable/setup/).

We notice the function returns from `main` into LIBC code, which then executes `exit(0)`.

## **Exploitation Strategy**
### Generic Pondering
For those new to FSOP exploitation, basically [`exit`](https://elixir.bootlin.com/glibc/glibc-2.43/source/stdlib/exit.c#L146) calls a few functions to cleanup IO things before completely killing the process, in general: [`__fcloseall`](https://elixir.bootlin.com/glibc/glibc-2.31/C/ident/__fcloseall), [`_IO_cleanup`](https://elixir.bootlin.com/glibc/glibc-2.31/C/ident/_IO_cleanup), [`_IO_flush_all_lockp`](https://elixir.bootlin.com/glibc/glibc-2.31/C/ident/_IO_flush_all_lockp), and [`_IO_flush_all`](https://elixir.bootlin.com/glibc/glibc-2.31/source/libio/genops.c#L724), for me it straight called [`_IO_flush_all`](https://elixir.bootlin.com/glibc/glibc-2.31/source/libio/genops.c#L724), which called `vtable->__sync()`.

Basically go with the usual route of overwriting the vtable with a relative address that makes [`_IO_flush_all`](https://elixir.bootlin.com/glibc/glibc-2.31/source/libio/genops.c#L724) calls [`_IO_wfile_overflow`](https://elixir.bootlin.com/glibc/glibc-2.43/source/libio/wfileops.c#L407), which in turn calls [`_IO_wdoallocbuf`](https://elixir.bootlin.com/glibc/glibc-2.43/source/libio/wgenops.c#L364), which calls `vtable->__doallocate` without vtable checks; which lets us achieve arbitrary code execution.

We can easily then execute `system("/bin/sh")`.

#### Note
I have skipped most of this part, as a lot of resources exist on it already, and my explanation would be simultaneusly too long for a write-up, and insufficient to explain FSOP.

One can learn the intricacies of FSOP from various sources, the best I recommend are:
- pwn.college's File Struct Exploits: [Link](https://pwn.college/software-exploitation/file-struct-exploits).
- My FSOP notes: [Link](https://github.com/MedjberAbderrahim/Binary-Exploitation-Notes/tree/main/FSOP).

### Possible Problems

#### Offsets Overlap
One of the problems one might encounter when setting the payload is offsets overlap, one can play with relative offsets that he can change (e.g. `fp->_wide_data->vtable`), after reserving space for the fixed offsets (e.g. `fp->_mode`, `fp->_lock`, `fp->vtable`, ...)

### Summary
1. Setup payload to poison `stderr` and get RCE call via the chain `exit`->`IO_flush_all`->`_IO_wfile_overflow`->`_IO_wdoallocbuf`.
2. Use that RCE to execute `system(' /bin/sh')` and gain user shell directly.

## **Solve Script**
You can find the full solve script [here](./challenge/solution/exploit.py)

## **Proof of Concept**
Here's how the solve would look like:
```sh
$ ./exploit.py REMOTE
[+] Opening connection to 127.0.0.1 on port 10000: Done
[*] libc.address: 0x7f67ff630000
[*] wfile_vtable: 0x7f67ff7ef3b0
[*] _IO_2_1_stderr_: 0x7f67ff7f12f0
flag{96bfe6b765c355307132a019314d775be408d4c4f0df6c2343e555ec88b1b7e5}
[*] Closed connection to 127.0.0.1 port 10000
```

## **Final Notes (From Author)**
The challenge was really fun to make in my opinion, as it was a similar idea of another challenge I made, but less intuitive; transitioning from the classic `puts` & `stdout` exploitation path to [`exit`](https://man7.org/linux/man-pages/man3/exit.3.html) and `stderr`.

Suffered a bit in making it as I had to reverse engineer its LIBC and follow with it.

Alas, hope you'all found this challenge good, either you learnt something new from it, or found it fun & entertaining! see you next time hopefully, meanwhile, happy pwning!