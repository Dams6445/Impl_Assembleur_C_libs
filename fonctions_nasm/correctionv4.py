#!/usr/bin/python3 -u

import os
import sys
from pathlib import Path
import subprocess

funcs = {
        "bzero": 7,
        "isalpha": 14,
        "puts": 43,
        "read": 23,
        "strcat": 18,
        "strcmp": 17,
        "toupper": 12,
        }

nasm_template = """
global my_%s
section .text
my_%s:
    ret
"""

correction_c_template = """
#define _gnu_source
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <strings.h>
#include <assert.h>
#include <unistd.h>
#include <errno.h>
#include <fcntl.h>
#include <sys/mman.h>

// prototypes
size_t abi_check(void *func, size_t num_args, ...);

int my_strcmp(const char *s1, const char *s2);
#define ABICHECK_my_strcmp(s1, s2) (int)abi_check(my_strcmp, 2, (char*)s1, (char*)s2)

int my_toupper(int c);
#define ABICHECK_my_toupper(c) (int)abi_check(my_toupper, 1, (int)c)

int my_isalpha(int c);
#define ABICHECK_my_isalpha(c) (int)abi_check(my_isalpha, 1, (int)c)

int my_puts(const char *s);
#define ABICHECK_my_puts(s) (int)abi_check(my_puts, 1, (char*)s)

void my_bzero(void *s, size_t n);
#define ABICHECK_my_bzero(s, n) (void)abi_check(my_bzero, 2, (void*)s, (size_t)n)

char *my_strcat(char *restrict dst, const char *restrict src);
#define ABICHECK_my_strcat(dst, src) (char*)abi_check(my_strcat, 2, (char*)dst, (char*)src)

ssize_t my_read(int fd, void *buf, size_t count);
#define ABICHECK_my_read(fd, buf, count) (ssize_t)abi_check(my_read, 3, (int)fd, (void*)buf, (size_t)count)

int num_tests = 0;
int num_errors = 0;

#define expect(expr, msg, ...) \\
    do \\
    { \\
        num_tests++; \\
        if (!(expr)) \\
        { \\
            fprintf(stderr, "\\033[0;31m%s failed  (test %d, line %d): \\033[1;33m%s\\033[0m (\\033[0;31m" msg "\\033[0m)\\n", __func__, num_tests, __LINE__, #expr, __VA_ARGS__); \\
            num_errors++; \\
        } \\
        else \\
        { \\
            fprintf(stderr, "\\033[0;32m%s success (test %d, line %d): \\033[1;32m%s\\033[0m (\\033[0;32m" msg "\\033[0m)\\n", __func__, num_tests, __LINE__, #expr, __VA_ARGS__); \\
        } \\
    } while(0)


void test_toupper () {
    unsigned int c = 0x00;
    while (c < 256) {
        expect(
                toupper(c) == ABICHECK_my_toupper(c),
                "c=%02hhx", c
                );
        c++;
    }
}

void test_isalpha () {
    unsigned int c = 0x00;
    while (c < 256) {
        expect(
                !!isalpha(c) == !!ABICHECK_my_isalpha(c),
                "c=%02hhx", c
                );
        c++;
    }
}

int c_diff(const char *path1, const char *path2) {
    FILE *f1, *f2;
    int ch1, ch2;

    f1 = fopen(path1, "r");
    if (f1 == NULL) {
        perror("Erreur lors de l'ouverture du premier fichier");
        exit(1);
    }

    f2 = fopen(path2, "r");
    if (f2 == NULL) {
        perror("Erreur lors de l'ouverture du deuxième fichier");
        fclose(f1);
        exit(1);
    }

    while (1) {
        ch1 = fgetc(f1);
        ch2 = fgetc(f2);

        if (ch1 != ch2) {
            fclose(f1);
            fclose(f2);
            return 1; // Les fichiers sont différents
        }

        if (ch1 == EOF && ch2 == EOF) {
            break; // Les deux fichiers ont été lus jusqu'à la fin
        }
    }

    fclose(f1);
    fclose(f2);
    return 0; // Les fichiers sont identiques
}

void test_puts () {
    int ret1, ret2;
    char *puts_string;

    puts_string = "hello world\\n\\0\\x01";
    freopen("/tmp/asmtest1", "w", stdout);
    ret1 = puts(puts_string);
    fflush(stdout);
    freopen("/tmp/asmtest2", "w", stdout);
    ret2 = ABICHECK_my_puts(puts_string);
    fflush(stdout);
    freopen("/dev/tty", "w", stdout);
    assert(ret1 >= 0);
    expect(ret2 >= 0,
            "hello world", 0); // check return
    expect(c_diff("/tmp/asmtest1", "/tmp/asmtest2") == 0,
            "hello world", 0); // check written
                               //
    char bigbuf[150000] = {0};
    memset(bigbuf, 0xff, 0x1ffff);
    puts_string = bigbuf;
    freopen("/tmp/asmtest1", "w", stdout);
    ret1 = puts(puts_string);
    fflush(stdout);
    freopen("/tmp/asmtest2", "w", stdout);
    ret2 = ABICHECK_my_puts(puts_string);
    fflush(stdout);
    freopen("/dev/tty", "w", stdout);
    assert(ret1 >= 0);
    expect(ret2 >= 0,
            "0xff * 85535", 0); // check return
    expect(c_diff("/tmp/asmtest1", "/tmp/asmtest2") == 0,
            "0xff * 85535", 0); // check written

    puts_string = "hello world\\n\\n\\0\\xff";
    fclose(stdout);
    ret1 = puts(puts_string);
    ret2 = ABICHECK_my_puts(puts_string);
    freopen("/dev/tty", "w", stdout);
    assert(ret1 == EOF);
    expect(ret2 == EOF,
            "write to closed fd (ebadf), ret=%p", ret2); // check return

    /* puts_string = "hello world"; */
    /* int sealed_fd = memfd_create("x", mfd_allow_sealing); */
    /* fcntl(sealed_fd, f_add_seals, f_seal_write); */
    /* dup2(sealed_fd, stdout_fileno); */
    /* fcntl(stdout_fileno, f_add_seals, f_seal_write); */

    /* int w = write(1, "x\\n", 2); */
    /* fprintf(stderr, "w=%d, errno=%d\\n", w, errno); */

    /* fcntl(sealed_fd, f_add_seals, f_seal_write); */
    /* ret1 = puts(puts_string); */
    /* fcntl(sealed_fd, f_add_seals, f_seal_write); */
    /* ret2 = ABICHECK_my_puts(puts_string); */

    /* w = write(1, "x\\n", 2); */
    /* fprintf(stderr, "w=%d, errno=%d\\n", w, errno); */

    /* freopen("/dev/tty", "w", stdout); */
    /* assert(ret1 == EOF); */
    /* expect(ret2 == EOF, */
    /*         "try to write to sealed fd (eperm)", 0); // check return */
}

void test_read () {
    int fd;
    char buf1[150000] = {0};
    char buf2[150000] = {0};
    ssize_t ret1, ret2;

    fd = open("/etc/passwd", O_RDONLY, 0666);
    memset(buf1, '\\0', 150000);
    memset(buf2, '\\0', 150000);
    assert(!lseek(fd, 0, SEEK_SET));
    ret1 = read(fd, buf1, 0x1ffff);
    assert(!lseek(fd, 0, SEEK_SET));
    ret2 = ABICHECK_my_read(fd, buf2, 0x1ffff);
    assert(ret1 > 4);
    expect(
            ret1 == ret2,
            "read /etc/passwd, ret=%d", ret2 // check return
          );
    expect(
            !memcmp(buf1, buf2, 150000),
            "read /etc/passwd", 0); // check buf
    close(fd);


    fd = open("/dev/zero", O_RDONLY, 0666);
    memset(buf1, 'a', 150000);
    memset(buf2, 'a', 150000);
    ret1 = read(fd, buf1, 0x1ffff);
    ret2 = ABICHECK_my_read(fd, buf2, 0x1ffff);
    assert(ret1 == 0x1ffff);
    expect(
            ret1 == ret2,
            "read /dev/zero, ret=%d", ret2 // check return
          );
    expect(
            !memcmp(buf1, buf2, 150000),
            "read /dev/zero", 0); // check buf
    close(fd);


    fd = open("/dev/null", O_RDONLY, 0666);
    memset(buf1, '0', 150000);
    memset(buf2, '0', 150000);
    ret1 = read(fd, buf1, 0x1ffff);
    ret2 = ABICHECK_my_read(fd, buf2, 0x1ffff);
    assert(ret1 == 0);
    expect(
            ret1 == ret2,
            "read /dev/null, ret=%d", ret2 // check return
          );
    expect(
            !memcmp(buf1, buf2, 150000),
            "read /dev/null", 0
            ); // check buf
    close(fd);
                                  //
    fd = open("/dev", O_RDONLY, 0666);
    errno = 0;
    ret1 = read(fd, buf1, 0x1ffff);
    assert(errno == EISDIR);
    errno = 0;
    ret2 = ABICHECK_my_read(fd, buf2, 0x1ffff);
    assert(ret1 == -1);
    expect(
            ret1 == ret2,
            "read /dev directory, ret=%d", ret2 // check return
          );
    expect(
            errno == EISDIR,
            "read /dev directory, errno=%d", errno // check errno
          );
    expect(
            !memcmp(buf1, buf2, 150000),
            "read /dev directory", 0
            ); // check buf
    close(fd);

    fd = open("/etc/passwd", O_RDONLY, 0666);
    errno = 0;
    ret1 = read(fd, (char*)0xffffff, 0x1ffff);
    assert(errno == EFAULT);
    errno = 0;
    ret2 = ABICHECK_my_read(fd, (char*)0xffffff, 0x1ffff);
    assert(ret1 == -1);
    expect(
            ret1 == ret2,
            "read info invalid buf, ret=%d", ret2 // check return
          );
    expect(
            errno == EFAULT,
            "read into invalid buf, errno=%d", errno // check errno
          );
    close(fd);
}

void test_bzero () {
    char buf1[150000];
    char buf2[150000];

    memset(buf1, 'a', 150000);
    memset(buf2, 'a', 150000);

    bzero(buf1, 256);
    ABICHECK_my_bzero(buf2, 256);
    expect(
            !memcmp(buf1, buf2, 150000),
            "small buf", 0
            );

    bzero(buf1+1000, 0x1ffff);
    ABICHECK_my_bzero(buf2+1000, 0x1ffff);
    expect(
            !memcmp(buf1, buf2, 150000),
            "big buf", 0
            );
};

void test_strcat () {
    char buf1[300000];
    char buf2[300000];
    char suffix[0x1ffff+1];
    char *ret2;

    memset(buf1, '\\0', 300000);
    memset(buf2, '\\0', 300000);
    memset(suffix+1, 0xfd, 0x1ffff-1);
    strcat(buf1, "hello world");
    ret2 = ABICHECK_my_strcat(buf2, "hello world");
    expect(
            ret2 == buf2,
            "check return", 0);
    expect(
            !memcmp(buf1, buf2, 300000),
            "check mem", 0
            );


    strcat(buf1, "hello world");
    ret2 = ABICHECK_my_strcat(buf2, "hello world");
    expect(
            ret2 == buf2,
            "check return", 0);
    expect(
            !memcmp(buf1, buf2, 300000),
            "check mem", 0
            );

    buf1[5] = '\\0';
    buf2[5] = '\\0';
    strcat(buf1, "hello world");
    ret2 = ABICHECK_my_strcat(buf2, "hello world");
    expect(
            ret2 == buf2,
            "check return", 0);
    expect(
            !memcmp(buf1, buf2, 300000),
            "check mem", 0
            );

    strcat(buf1, suffix);
    ret2 = ABICHECK_my_strcat(buf2, suffix);
    expect(
            ret2 == buf2,
            "check return", 0);
    expect(
            !memcmp(buf1, buf2, 300000),
            "check mem", 0
            );

    strcat(buf1, suffix);
    ret2 = ABICHECK_my_strcat(buf2, suffix);
    expect(
            ret2 == buf2,
            "check return", 0);
    expect(
            !memcmp(buf1, buf2, 300000),
            "check mem", 0
            );

    buf1[5] = '\\0';
    buf2[5] = '\\0';
    strcat(buf1, "hello world");
    ret2 = ABICHECK_my_strcat(buf2, "hello world");
    expect(
            ret2 == buf2,
            "check return", 0);
    expect(
            !memcmp(buf1, buf2, 300000),
            "check mem", 0
            );
}

int wr(int val) {
    if (val < 0) return -1;
    if (val > 0) return 1;
    return 0;
}

void test_strcmp () {
    int ret1, ret2;

    char buf1[0x1ffff+1] = {0};
    char buf2[0x1ffff+1] = {0};

    expect(
            wr(strcmp(buf1-100, buf1-100)) == wr(ABICHECK_my_strcmp(buf1-100, buf1-100)),
            "cmp same ptr", 0
            );

    strcat(buf1, "hello world");
    strcat(buf2, "hello world");
    expect(
            wr(strcmp(buf1, buf2)) == wr(ABICHECK_my_strcmp(buf1, buf2)),
            "cmp same data", 0
            );

    memset(buf1, '\\0', 0x1ffff);
    memset(buf2, '\\0', 0x1ffff);
    expect(
            wr(strcmp(buf1, buf2)) == wr(ABICHECK_my_strcmp(buf1, buf2)),
            "cmp same data", 0
            );

    strcat(buf1, "aaaa");
    strcat(buf2, "zzzz");
    ret1 = strcmp(buf1, buf2);
    ret2 = ABICHECK_my_strcmp(buf1, buf2);
    expect(
            wr(ret1) == wr(ret2),
            "cmp smaller data (ret1=%d, ret2=%d)", ret1, ret2
            );
    strcat(buf1, "zzzz");
    strcat(buf2, "aaaa");
    ret1 = strcmp(buf1, buf2);
    ret2 = ABICHECK_my_strcmp(buf1, buf2);
    expect(
            wr(ret1) == wr(ret2),
            "cmp smaller data (ret1=%d, ret2=%d)", ret1, ret2
            );

    strcpy(buf1, "zzzz");
    strcpy(buf2, "aaaa");
    ret1 = strcmp(buf1, buf2);
    ret2 = ABICHECK_my_strcmp(buf1, buf2);
    expect(
            wr(ret1) == wr(ret2),
            "cmp bigger data (ret1=%d, ret2=%d)", ret1, ret2
            );

    strcpy(buf1, "\\x02");
    strcpy(buf2, "\\x01");
    ret1 = strcmp(buf1, buf2);
    ret2 = ABICHECK_my_strcmp(buf1, buf2);
    expect(
            wr(ret1) == wr(ret2),
            "cmp bigger data (ret1=%d, ret2=%d)", ret1, ret2
            );

    strcpy(buf1, "\\xfe");
    strcpy(buf2, "\\xff");
    ret1 = strcmp(buf1, buf2);
    ret2 = ABICHECK_my_strcmp(buf1, buf2);
    expect(
            wr(ret1) == wr(ret2),
            "cmp smaller data (ret1=%d, ret2=%d)", ret1, ret2
            );

    memset(buf1, '\\x80', 0x1ffff);
    memset(buf2, '\\x80', 0x1ffff);
    ret1 = strcmp(buf1, buf2);
    ret2 = ABICHECK_my_strcmp(buf1, buf2);
    expect(
            wr(ret1) == wr(ret2),
            "cmp equal data (ret1=%d, ret2=%d)", ret1, ret2
            );

    buf1[0x1ffff] = '\\x81';
    ret1 = strcmp(buf1, buf2);
    ret2 = ABICHECK_my_strcmp(buf1, buf2);
    expect(
            wr(ret1) == wr(ret2),
            "cmp bigger data (ret1=%d, ret2=%d)", ret1, ret2
            );

    buf2[0x1ffff] = '\\x86';
    ret1 = strcmp(buf1, buf2);
    ret2 = ABICHECK_my_strcmp(buf1, buf2);
    expect(
            wr(ret1) == wr(ret2),
            "cmp smaller data (ret1=%d, ret2=%d)", ret1, ret2
            );

    buf2[1] = 0x00;
    ret1 = strcmp(buf1, buf2);
    ret2 = ABICHECK_my_strcmp(buf1, buf2);
    expect(
            wr(ret1) == wr(ret2),
            "cmp bigger data (ret1=%d, ret2=%d)", ret1, ret2
            );

    buf1[1] = 0x00;
    ret1 = strcmp(buf1, buf2);
    ret2 = ABICHECK_my_strcmp(buf1, buf2);
    expect(
            wr(ret1) == wr(ret2),
            "cmp equal data (ret1=%d, ret2=%d)", ret1, ret2
            );
}

int main(int argc, char **argv) {
    if (argc == 2) {
        printf("testing %s\\n", argv[1]);
        if (!strcmp(argv[1], "toupper")) {
            test_toupper();
        }
        else if (!strcmp(argv[1], "bzero")) {
            test_bzero();
        }
        else if (!strcmp(argv[1], "isalpha")) {
            test_isalpha();
        }
        else if (!strcmp(argv[1], "puts")) {
            test_puts();
        }
        else if (!strcmp(argv[1], "read")) {
            test_read();
        }
        else if (!strcmp(argv[1], "strcat")) {
            test_strcat();
        }
        else if (!strcmp(argv[1], "strcmp")) {
            test_strcmp();
        }
        else {
            printf("usage: %s [function]\\n", argv[0]);
            printf("example: %s strcmp\\n", argv[0]);
            exit(1);
        }
        if (!num_errors) {
            fprintf(stderr, "\\033[32mall %d tests succeeded\\033[0m\\n", num_tests);
            return 0;
        }
        else {
            fprintf(stderr, "\\033[31m%d of %d tests failed !\\033[0m\\n", num_errors, num_tests);
            return 1;
        }
    }
}
"""

abi_template = """
; size_t abi_check(void *func, size_t num_args, size_t arg1, size_t arg2, size_t arg3);
global abi_check

%macro  multipush 1-*
  %rep  %0
  %rotate -1
    push %1
  %endrep
%endmacro

%macro  multipop 1-*
  %rep %0
    pop %1
  %rotate 1
  %endrep
%endmacro

%define  override_val 0xaaaaaaaaaaaaaaaa

%macro  reg_override 1-*
  %rep %0
    mov %1, override_val
  %rotate 1
  %endrep
%endmacro

%macro  randomize 1-*
  %rep %0
    rdrand %1
  %rotate 1
  %endrep
%endmacro

%define STACK_RBX QWORD [rsp+(8*5)]
%define STACK_RCX QWORD [rsp+(8*6)]
%define STACK_RDX QWORD [rsp+(8*7)]
%define STACK_RSI QWORD [rsp+(8*8)]
%define STACK_RDI QWORD [rsp+(8*9)]
%define STACK_RSP QWORD [rsp+(8*10)]
%define STACK_RBP QWORD [rsp+(8*11)]
%define STACK_R8  QWORD [rsp+(8*12)]
%define STACK_R9  QWORD [rsp+(8*13)]
%define STACK_R10 QWORD [rsp+(8*14)]
%define STACK_R11 QWORD [rsp+(8*15)]
%define STACK_R12 QWORD [rsp+(8*16)]
%define STACK_R13 QWORD [rsp+(8*17)]
%define STACK_R14 QWORD [rsp+(8*18)]
%define STACK_R15 QWORD [rsp+(8*19)]

%define STACK_FUNCPTR   STACK_RDI
%define STACK_NUM_ARGS  STACK_RSI
%define STACK_ARG1      STACK_RDX
%define STACK_ARG2      STACK_RCX
%define STACK_ARG3      STACK_R8

%define STACK_RAND      STACK_RCX

section .text

abi_check:

.backup_registers:
    multipush rbx, rcx, rdx, rsi, rdi, rsp, rbp, r8, r9, r10, r11, r12, r13, r14, r15


.override_registers:
    randomize rax, rbx, rcx, rdx, rsi, rdi, r8, r9, r10, r11, r12, r13, r14, r15


.randomize_non_volatile:
    multipush rbx, r12, r13, r14, r15

.set_args:
    ; set arg1
    cmp STACK_NUM_ARGS, 1
    jb .call_function
    mov rdi, STACK_ARG1
    ; set arg2
    cmp STACK_NUM_ARGS, 2
    jb .call_function
    mov rsi, STACK_ARG2
    ; set arg3
    cmp STACK_NUM_ARGS, 3
    jb .call_function
    mov rdx, STACK_ARG3


.call_function:
    call STACK_FUNCPTR


.check_nonvolatile_registers:
    mov rdi, STACK_RSP
    sub rdi, 0x58
    cmp rsp, rdi
    jne .return_error

    cmp rbp, STACK_RBP
    jne .return_error

    pop rdi
    cmp rbx, rdi
    jne .return_error

    pop rdi
    cmp r12, rdi
    jne .return_error

    pop rdi
    cmp r13, rdi
    jne .return_error

    pop rdi
    cmp r14, rdi
    jne .return_error

    pop rdi
    cmp r15, rdi
    jne .return_error


.check_direction_flag_is_clear:
    pushf
    pop rdi
    bt rdi, 10
    jc .return_error


.return_func_result:
    multipop rbx, rcx, rdx, rsi, rdi, rsp, rbp, r8, r9, r10, r11, r12, r13, r14, r15
    ret


.return_error:
    multipop rbx, rcx, rdx, rsi, rdi, rsp, rbp, r8, r9, r10, r11, r12, r13, r14, r15
    rdrand rax
    ret
"""

RM=True


if True or not Path("test_functions").is_file():
    os.system("rm -f my_*.o abi_check.o ./test_functions")

    abi = Path("abi_check.s")
    if not abi.is_file():
        abi.write_text(abi_template)
    os.system(f"nasm -f elf64 abi_check.s -o abi_check.o")
    if RM:
        os.system(f"rm abi_check.s")

    for func in funcs:
        path = Path("my_"+func+".s")
        if not path.exists():
            path.write_text(nasm_template.replace("%s", func))
        os.system(f"nasm -f elf64 my_{func}.s -o my_{func}.o")
    objs = " ".join(f"my_{f}.o" for f in funcs)

    correction_c = Path("correction.c")
    if not correction_c.is_file():
        correction_c.write_text(correction_c_template)
    os.system(f"gcc -fno-builtin -no-pie -g {objs} abi_check.o correction.c -o test_functions")
    if RM:
        os.system(f"rm correction.c")
        os.system(f"rm abi_check.o")

    assert Path("test_functions").is_file()

NOTES = {}

all_functions_work = True
for func in funcs:
    note = 0
    # external functions are forbidden (exept for __errno_location)
    if os.system(f"objdump -x my_{func}.o | grep -v __errno_location | grep -q UND") != 0:
        if os.system(f"./test_functions {func}") == 0:
            note = 10;
    NOTES[func] = note
    if not note:
        all_functions_work = False
if RM:
    os.system(f"rm test_functions")

XP_DELTA = 2
if all_functions_work:
    for func, note in NOTES.items():
        ideal_sz = funcs[func]
        # ret, out = subprocess.getstatusoutput(f"objcopy -O binary --only-section=.text my_{func}.o /tmp/my_{func}.o && wc -c /tmp/my_{func}.o")
        ret, out = subprocess.getstatusoutput(f"size -A -d my_{func}.o | grep ^Total | grep -o '[0-9]\+$'")
        assert ret == 0
        student_sz = int(out.split()[0])
        # student_sz *= 1.5
        # student_sz += 10
        print()
        print(f"SIZE OF YOUR {func}:   {student_sz}")
        print(f"IDEAL SIZE FOR {func}: {ideal_sz}")
        if student_sz >= ideal_sz * XP_DELTA:
            print(f"extra points for {func}: 0")
            continue # keep note 10
        elif student_sz <= ideal_sz:
            NOTES[func] = 20
            print(f"extra points for {func}: 10")
            continue

        extra_points = (ideal_sz * XP_DELTA - student_sz) / (XP_DELTA - 1)
        extra_points = (extra_points / ideal_sz) * 10
        extra_points = max(1, min(9, extra_points))
        print(f"extra points for {func}: {extra_points:.2f}")
        NOTES[func] += extra_points

print("\n\n============== CALCULATING YOUR NOTE ================")
total = 0
for func, note in NOTES.items():
    print(f"got {note:.2f}/20 for {func}")
    total += note
glob_note = total / len(NOTES)
glob_note_rounded = round(glob_note)
print(f"GLOBAL NOTE: {glob_note_rounded}/20 (rounded from {glob_note:.2f})")
