/* This C header file is generated by NIT to compile modules and programs that requires ../lib/standard/file. */
#ifndef standard___file_sep
#define standard___file_sep
#include "standard___stream._sep.h"
#include "standard___time._sep.h"
#include <nit_common.h>
#include "file._nitni.h"
#include "standard___file._ffi.h"

extern const classtable_elt_t VFT_standard___file___FStream[];

extern const classtable_elt_t VFT_standard___file___IFStream[];

extern const classtable_elt_t VFT_standard___file___OFStream[];

extern const classtable_elt_t VFT_standard___file___Stdin[];

extern const classtable_elt_t VFT_standard___file___Stdout[];

extern const classtable_elt_t VFT_standard___file___Stderr[];

extern const classtable_elt_t VFT_standard___file___FileStat[];
struct TBOX_FileStat { const classtable_elt_t * vft; bigint object_id;  struct stat *  val;};
val_t BOX_FileStat( struct stat *  val);
#define UNBOX_FileStat(x) (((struct TBOX_FileStat *)(VAL2OBJ(x)))->val)

extern const classtable_elt_t VFT_standard___file___NativeFile[];
struct TBOX_NativeFile { const classtable_elt_t * vft; bigint object_id; void* val;};
val_t BOX_NativeFile(void* val);
#define UNBOX_NativeFile(x) (((struct TBOX_NativeFile *)(VAL2OBJ(x)))->val)
extern const char LOCATE_standard___file[];
extern const int SFT_standard___file[];
#define CALL_standard___file___Object___printn(recv) ((standard___file___Object___printn_t)CALL((recv), (SFT_standard___file[0] + 0)))
#define CALL_standard___file___Object___print(recv) ((standard___file___Object___print_t)CALL((recv), (SFT_standard___file[0] + 1)))
#define CALL_standard___file___Object___getc(recv) ((standard___file___Object___getc_t)CALL((recv), (SFT_standard___file[0] + 2)))
#define CALL_standard___file___Object___gets(recv) ((standard___file___Object___gets_t)CALL((recv), (SFT_standard___file[0] + 3)))
#define CALL_standard___file___Object___stdin(recv) ((standard___file___Object___stdin_t)CALL((recv), (SFT_standard___file[0] + 4)))
#define CALL_standard___file___Object___stdout(recv) ((standard___file___Object___stdout_t)CALL((recv), (SFT_standard___file[0] + 5)))
#define CALL_standard___file___Object___stderr(recv) ((standard___file___Object___stderr_t)CALL((recv), (SFT_standard___file[0] + 6)))
#define ID_standard___file___FStream (SFT_standard___file[1])
#define COLOR_standard___file___FStream (SFT_standard___file[2])
#define ATTR_standard___file___FStream____path(recv) ATTR(recv, (SFT_standard___file[3] + 0))
#define ATTR_standard___file___FStream____file(recv) ATTR(recv, (SFT_standard___file[3] + 1))
#define INIT_TABLE_POS_standard___file___FStream (SFT_standard___file[4] + 0)
#define CALL_standard___file___FStream___path(recv) ((standard___file___FStream___path_t)CALL((recv), (SFT_standard___file[4] + 1)))
#define CALL_standard___file___FStream___file_stat(recv) ((standard___file___FStream___file_stat_t)CALL((recv), (SFT_standard___file[4] + 2)))
#define CALL_standard___file___FStream___init(recv) ((standard___file___FStream___init_t)CALL((recv), (SFT_standard___file[4] + 3)))
#define ID_standard___file___IFStream (SFT_standard___file[5])
#define COLOR_standard___file___IFStream (SFT_standard___file[6])
#define ATTR_standard___file___IFStream____end_reached(recv) ATTR(recv, (SFT_standard___file[7] + 0))
#define INIT_TABLE_POS_standard___file___IFStream (SFT_standard___file[8] + 0)
#define CALL_standard___file___IFStream___reopen(recv) ((standard___file___IFStream___reopen_t)CALL((recv), (SFT_standard___file[8] + 1)))
#define CALL_standard___file___IFStream___open(recv) ((standard___file___IFStream___open_t)CALL((recv), (SFT_standard___file[8] + 2)))
#define CALL_standard___file___IFStream___init(recv) ((standard___file___IFStream___init_t)CALL((recv), (SFT_standard___file[8] + 3)))
#define CALL_standard___file___IFStream___without_file(recv) ((standard___file___IFStream___without_file_t)CALL((recv), (SFT_standard___file[8] + 4)))
#define ID_standard___file___OFStream (SFT_standard___file[9])
#define COLOR_standard___file___OFStream (SFT_standard___file[10])
#define ATTR_standard___file___OFStream____writable(recv) ATTR(recv, (SFT_standard___file[11] + 0))
#define INIT_TABLE_POS_standard___file___OFStream (SFT_standard___file[12] + 0)
#define CALL_standard___file___OFStream___write_native(recv) ((standard___file___OFStream___write_native_t)CALL((recv), (SFT_standard___file[12] + 1)))
#define CALL_standard___file___OFStream___open(recv) ((standard___file___OFStream___open_t)CALL((recv), (SFT_standard___file[12] + 2)))
#define CALL_standard___file___OFStream___init(recv) ((standard___file___OFStream___init_t)CALL((recv), (SFT_standard___file[12] + 3)))
#define CALL_standard___file___OFStream___without_file(recv) ((standard___file___OFStream___without_file_t)CALL((recv), (SFT_standard___file[12] + 4)))
#define ID_standard___file___Stdin (SFT_standard___file[13])
#define COLOR_standard___file___Stdin (SFT_standard___file[14])
#define INIT_TABLE_POS_standard___file___Stdin (SFT_standard___file[15] + 0)
#define CALL_standard___file___Stdin___init(recv) ((standard___file___Stdin___init_t)CALL((recv), (SFT_standard___file[15] + 1)))
#define CALL_standard___file___Stdin___poll_in(recv) ((standard___file___Stdin___poll_in_t)CALL((recv), (SFT_standard___file[15] + 2)))
#define ID_standard___file___Stdout (SFT_standard___file[16])
#define COLOR_standard___file___Stdout (SFT_standard___file[17])
#define INIT_TABLE_POS_standard___file___Stdout (SFT_standard___file[18] + 0)
#define CALL_standard___file___Stdout___init(recv) ((standard___file___Stdout___init_t)CALL((recv), (SFT_standard___file[18] + 1)))
#define ID_standard___file___Stderr (SFT_standard___file[19])
#define COLOR_standard___file___Stderr (SFT_standard___file[20])
#define INIT_TABLE_POS_standard___file___Stderr (SFT_standard___file[21] + 0)
#define CALL_standard___file___Stderr___init(recv) ((standard___file___Stderr___init_t)CALL((recv), (SFT_standard___file[21] + 1)))
#define CALL_standard___file___String___file_exists(recv) ((standard___file___String___file_exists_t)CALL((recv), (SFT_standard___file[22] + 0)))
#define CALL_standard___file___String___file_stat(recv) ((standard___file___String___file_stat_t)CALL((recv), (SFT_standard___file[22] + 1)))
#define CALL_standard___file___String___file_lstat(recv) ((standard___file___String___file_lstat_t)CALL((recv), (SFT_standard___file[22] + 2)))
#define CALL_standard___file___String___file_delete(recv) ((standard___file___String___file_delete_t)CALL((recv), (SFT_standard___file[22] + 3)))
#define CALL_standard___file___String___strip_extension(recv) ((standard___file___String___strip_extension_t)CALL((recv), (SFT_standard___file[22] + 4)))
#define CALL_standard___file___String___basename(recv) ((standard___file___String___basename_t)CALL((recv), (SFT_standard___file[22] + 5)))
#define CALL_standard___file___String___dirname(recv) ((standard___file___String___dirname_t)CALL((recv), (SFT_standard___file[22] + 6)))
#define CALL_standard___file___String___simplify_path(recv) ((standard___file___String___simplify_path_t)CALL((recv), (SFT_standard___file[22] + 7)))
#define CALL_standard___file___String___join_path(recv) ((standard___file___String___join_path_t)CALL((recv), (SFT_standard___file[22] + 8)))
#define CALL_standard___file___String___mkdir(recv) ((standard___file___String___mkdir_t)CALL((recv), (SFT_standard___file[22] + 9)))
#define CALL_standard___file___String___file_extension(recv) ((standard___file___String___file_extension_t)CALL((recv), (SFT_standard___file[22] + 10)))
#define CALL_standard___file___String___files(recv) ((standard___file___String___files_t)CALL((recv), (SFT_standard___file[22] + 11)))
#define CALL_standard___file___NativeString___file_exists(recv) ((standard___file___NativeString___file_exists_t)CALL((recv), (SFT_standard___file[23] + 0)))
#define CALL_standard___file___NativeString___file_stat(recv) ((standard___file___NativeString___file_stat_t)CALL((recv), (SFT_standard___file[23] + 1)))
#define CALL_standard___file___NativeString___file_lstat(recv) ((standard___file___NativeString___file_lstat_t)CALL((recv), (SFT_standard___file[23] + 2)))
#define CALL_standard___file___NativeString___file_mkdir(recv) ((standard___file___NativeString___file_mkdir_t)CALL((recv), (SFT_standard___file[23] + 3)))
#define CALL_standard___file___NativeString___file_delete(recv) ((standard___file___NativeString___file_delete_t)CALL((recv), (SFT_standard___file[23] + 4)))
#define ID_standard___file___FileStat (SFT_standard___file[24])
#define COLOR_standard___file___FileStat (SFT_standard___file[25])
#define INIT_TABLE_POS_standard___file___FileStat (SFT_standard___file[26] + 0)
#define CALL_standard___file___FileStat___mode(recv) ((standard___file___FileStat___mode_t)CALL((recv), (SFT_standard___file[26] + 1)))
#define CALL_standard___file___FileStat___atime(recv) ((standard___file___FileStat___atime_t)CALL((recv), (SFT_standard___file[26] + 2)))
#define CALL_standard___file___FileStat___ctime(recv) ((standard___file___FileStat___ctime_t)CALL((recv), (SFT_standard___file[26] + 3)))
#define CALL_standard___file___FileStat___mtime(recv) ((standard___file___FileStat___mtime_t)CALL((recv), (SFT_standard___file[26] + 4)))
#define CALL_standard___file___FileStat___size(recv) ((standard___file___FileStat___size_t)CALL((recv), (SFT_standard___file[26] + 5)))
#define CALL_standard___file___FileStat___is_reg(recv) ((standard___file___FileStat___is_reg_t)CALL((recv), (SFT_standard___file[26] + 6)))
#define CALL_standard___file___FileStat___is_dir(recv) ((standard___file___FileStat___is_dir_t)CALL((recv), (SFT_standard___file[26] + 7)))
#define CALL_standard___file___FileStat___is_chr(recv) ((standard___file___FileStat___is_chr_t)CALL((recv), (SFT_standard___file[26] + 8)))
#define CALL_standard___file___FileStat___is_blk(recv) ((standard___file___FileStat___is_blk_t)CALL((recv), (SFT_standard___file[26] + 9)))
#define CALL_standard___file___FileStat___is_fifo(recv) ((standard___file___FileStat___is_fifo_t)CALL((recv), (SFT_standard___file[26] + 10)))
#define CALL_standard___file___FileStat___is_lnk(recv) ((standard___file___FileStat___is_lnk_t)CALL((recv), (SFT_standard___file[26] + 11)))
#define CALL_standard___file___FileStat___is_sock(recv) ((standard___file___FileStat___is_sock_t)CALL((recv), (SFT_standard___file[26] + 12)))
#define ID_standard___file___NativeFile (SFT_standard___file[27])
#define COLOR_standard___file___NativeFile (SFT_standard___file[28])
#define INIT_TABLE_POS_standard___file___NativeFile (SFT_standard___file[29] + 0)
#define CALL_standard___file___NativeFile___io_read(recv) ((standard___file___NativeFile___io_read_t)CALL((recv), (SFT_standard___file[29] + 1)))
#define CALL_standard___file___NativeFile___io_write(recv) ((standard___file___NativeFile___io_write_t)CALL((recv), (SFT_standard___file[29] + 2)))
#define CALL_standard___file___NativeFile___io_close(recv) ((standard___file___NativeFile___io_close_t)CALL((recv), (SFT_standard___file[29] + 3)))
#define CALL_standard___file___NativeFile___file_stat(recv) ((standard___file___NativeFile___file_stat_t)CALL((recv), (SFT_standard___file[29] + 4)))
#define CALL_standard___file___NativeFile___io_open_read(recv) ((standard___file___NativeFile___io_open_read_t)CALL((recv), (SFT_standard___file[29] + 5)))
#define CALL_standard___file___NativeFile___io_open_write(recv) ((standard___file___NativeFile___io_open_write_t)CALL((recv), (SFT_standard___file[29] + 6)))
#define CALL_standard___file___NativeFile___native_stdin(recv) ((standard___file___NativeFile___native_stdin_t)CALL((recv), (SFT_standard___file[29] + 7)))
#define CALL_standard___file___NativeFile___native_stdout(recv) ((standard___file___NativeFile___native_stdout_t)CALL((recv), (SFT_standard___file[29] + 8)))
#define CALL_standard___file___NativeFile___native_stderr(recv) ((standard___file___NativeFile___native_stderr_t)CALL((recv), (SFT_standard___file[29] + 9)))
void standard___file___Object___printn(val_t p0, val_t p1);
typedef void (*standard___file___Object___printn_t)(val_t p0, val_t p1);
void standard___file___Object___print(val_t p0, val_t p1);
typedef void (*standard___file___Object___print_t)(val_t p0, val_t p1);
val_t standard___file___Object___getc(val_t p0);
typedef val_t (*standard___file___Object___getc_t)(val_t p0);
val_t standard___file___Object___gets(val_t p0);
typedef val_t (*standard___file___Object___gets_t)(val_t p0);
val_t standard___file___Object___stdin(val_t p0);
typedef val_t (*standard___file___Object___stdin_t)(val_t p0);
val_t standard___file___Object___stdout(val_t p0);
typedef val_t (*standard___file___Object___stdout_t)(val_t p0);
val_t standard___file___Object___stderr(val_t p0);
typedef val_t (*standard___file___Object___stderr_t)(val_t p0);
val_t standard___file___FStream___path(val_t p0);
typedef val_t (*standard___file___FStream___path_t)(val_t p0);
val_t standard___file___FStream___file_stat(val_t p0);
typedef val_t (*standard___file___FStream___file_stat_t)(val_t p0);
void standard___file___FStream___init(val_t p0, int* init_table);
typedef void (*standard___file___FStream___init_t)(val_t p0, int* init_table);
val_t NEW_FStream_standard___file___FStream___init();
void standard___file___IFStream___reopen(val_t p0);
typedef void (*standard___file___IFStream___reopen_t)(val_t p0);
void standard___file___IFStream___close(val_t p0);
typedef void (*standard___file___IFStream___close_t)(val_t p0);
void standard___file___IFStream___fill_buffer(val_t p0);
typedef void (*standard___file___IFStream___fill_buffer_t)(val_t p0);
val_t standard___file___IFStream___end_reached(val_t p0);
typedef val_t (*standard___file___IFStream___end_reached_t)(val_t p0);
void standard___file___IFStream___open(val_t p0, val_t p1, int* init_table);
typedef void (*standard___file___IFStream___open_t)(val_t p0, val_t p1, int* init_table);
val_t NEW_IFStream_standard___file___IFStream___open(val_t p0);
void standard___file___IFStream___init(val_t p0, int* init_table);
typedef void (*standard___file___IFStream___init_t)(val_t p0, int* init_table);
val_t NEW_IFStream_standard___file___IFStream___init();
void standard___file___IFStream___without_file(val_t p0, int* init_table);
typedef void (*standard___file___IFStream___without_file_t)(val_t p0, int* init_table);
val_t NEW_IFStream_standard___file___IFStream___without_file();
void standard___file___OFStream___write(val_t p0, val_t p1);
typedef void (*standard___file___OFStream___write_t)(val_t p0, val_t p1);
val_t standard___file___OFStream___is_writable(val_t p0);
typedef val_t (*standard___file___OFStream___is_writable_t)(val_t p0);
void standard___file___OFStream___close(val_t p0);
typedef void (*standard___file___OFStream___close_t)(val_t p0);
void standard___file___OFStream___write_native(val_t p0, val_t p1, val_t p2);
typedef void (*standard___file___OFStream___write_native_t)(val_t p0, val_t p1, val_t p2);
void standard___file___OFStream___open(val_t p0, val_t p1, int* init_table);
typedef void (*standard___file___OFStream___open_t)(val_t p0, val_t p1, int* init_table);
val_t NEW_OFStream_standard___file___OFStream___open(val_t p0);
void standard___file___OFStream___init(val_t p0, int* init_table);
typedef void (*standard___file___OFStream___init_t)(val_t p0, int* init_table);
val_t NEW_OFStream_standard___file___OFStream___init();
void standard___file___OFStream___without_file(val_t p0, int* init_table);
typedef void (*standard___file___OFStream___without_file_t)(val_t p0, int* init_table);
val_t NEW_OFStream_standard___file___OFStream___without_file();
void standard___file___Stdin___init(val_t p0, int* init_table);
typedef void (*standard___file___Stdin___init_t)(val_t p0, int* init_table);
val_t NEW_Stdin_standard___file___Stdin___init();
val_t standard___file___Stdin___poll_in(val_t p0);
typedef val_t (*standard___file___Stdin___poll_in_t)(val_t p0);
void standard___file___Stdout___init(val_t p0, int* init_table);
typedef void (*standard___file___Stdout___init_t)(val_t p0, int* init_table);
val_t NEW_Stdout_standard___file___Stdout___init();
void standard___file___Stderr___init(val_t p0, int* init_table);
typedef void (*standard___file___Stderr___init_t)(val_t p0, int* init_table);
val_t NEW_Stderr_standard___file___Stderr___init();
val_t standard___file___String___file_exists(val_t p0);
typedef val_t (*standard___file___String___file_exists_t)(val_t p0);
val_t standard___file___String___file_stat(val_t p0);
typedef val_t (*standard___file___String___file_stat_t)(val_t p0);
val_t standard___file___String___file_lstat(val_t p0);
typedef val_t (*standard___file___String___file_lstat_t)(val_t p0);
val_t standard___file___String___file_delete(val_t p0);
typedef val_t (*standard___file___String___file_delete_t)(val_t p0);
val_t standard___file___String___strip_extension(val_t p0, val_t p1);
typedef val_t (*standard___file___String___strip_extension_t)(val_t p0, val_t p1);
val_t standard___file___String___basename(val_t p0, val_t p1);
typedef val_t (*standard___file___String___basename_t)(val_t p0, val_t p1);
val_t standard___file___String___dirname(val_t p0);
typedef val_t (*standard___file___String___dirname_t)(val_t p0);
val_t standard___file___String___simplify_path(val_t p0);
typedef val_t (*standard___file___String___simplify_path_t)(val_t p0);
val_t standard___file___String___join_path(val_t p0, val_t p1);
typedef val_t (*standard___file___String___join_path_t)(val_t p0, val_t p1);
void standard___file___String___mkdir(val_t p0);
typedef void (*standard___file___String___mkdir_t)(val_t p0);
val_t standard___file___String___file_extension(val_t p0);
typedef val_t (*standard___file___String___file_extension_t)(val_t p0);
val_t standard___file___String___files(val_t p0);
typedef val_t (*standard___file___String___files_t)(val_t p0);
val_t NEW_String_standard___string___String___from_substring(val_t p0, val_t p1, val_t p2);
val_t NEW_String_standard___string___String___with_infos(val_t p0, val_t p1, val_t p2, val_t p3);
val_t standard___file___NativeString___file_exists(val_t p0);
typedef val_t (*standard___file___NativeString___file_exists_t)(val_t p0);
val_t standard___file___NativeString___file_stat(val_t p0);
typedef val_t (*standard___file___NativeString___file_stat_t)(val_t p0);
val_t standard___file___NativeString___file_lstat(val_t p0);
typedef val_t (*standard___file___NativeString___file_lstat_t)(val_t p0);
val_t standard___file___NativeString___file_mkdir(val_t p0);
typedef val_t (*standard___file___NativeString___file_mkdir_t)(val_t p0);
val_t standard___file___NativeString___file_delete(val_t p0);
typedef val_t (*standard___file___NativeString___file_delete_t)(val_t p0);
val_t NEW_NativeString_standard___string___NativeString___init();
val_t standard___file___FileStat___mode(val_t p0);
typedef val_t (*standard___file___FileStat___mode_t)(val_t p0);
val_t standard___file___FileStat___atime(val_t p0);
typedef val_t (*standard___file___FileStat___atime_t)(val_t p0);
val_t standard___file___FileStat___ctime(val_t p0);
typedef val_t (*standard___file___FileStat___ctime_t)(val_t p0);
val_t standard___file___FileStat___mtime(val_t p0);
typedef val_t (*standard___file___FileStat___mtime_t)(val_t p0);
val_t standard___file___FileStat___size(val_t p0);
typedef val_t (*standard___file___FileStat___size_t)(val_t p0);
val_t standard___file___FileStat___is_reg(val_t p0);
typedef val_t (*standard___file___FileStat___is_reg_t)(val_t p0);
val_t standard___file___FileStat___is_dir(val_t p0);
typedef val_t (*standard___file___FileStat___is_dir_t)(val_t p0);
val_t standard___file___FileStat___is_chr(val_t p0);
typedef val_t (*standard___file___FileStat___is_chr_t)(val_t p0);
val_t standard___file___FileStat___is_blk(val_t p0);
typedef val_t (*standard___file___FileStat___is_blk_t)(val_t p0);
val_t standard___file___FileStat___is_fifo(val_t p0);
typedef val_t (*standard___file___FileStat___is_fifo_t)(val_t p0);
val_t standard___file___FileStat___is_lnk(val_t p0);
typedef val_t (*standard___file___FileStat___is_lnk_t)(val_t p0);
val_t standard___file___FileStat___is_sock(val_t p0);
typedef val_t (*standard___file___FileStat___is_sock_t)(val_t p0);
val_t standard___file___NativeFile___io_read(val_t p0, val_t p1, val_t p2);
typedef val_t (*standard___file___NativeFile___io_read_t)(val_t p0, val_t p1, val_t p2);
val_t standard___file___NativeFile___io_write(val_t p0, val_t p1, val_t p2);
typedef val_t (*standard___file___NativeFile___io_write_t)(val_t p0, val_t p1, val_t p2);
val_t standard___file___NativeFile___io_close(val_t p0);
typedef val_t (*standard___file___NativeFile___io_close_t)(val_t p0);
val_t standard___file___NativeFile___file_stat(val_t p0);
typedef val_t (*standard___file___NativeFile___file_stat_t)(val_t p0);
void standard___file___NativeFile___io_open_read(val_t p0, val_t p1, int* init_table);
typedef void (*standard___file___NativeFile___io_open_read_t)(val_t p0, val_t p1, int* init_table);
val_t NEW_NativeFile_standard___file___NativeFile___io_open_read(val_t p0);
void standard___file___NativeFile___io_open_write(val_t p0, val_t p1, int* init_table);
typedef void (*standard___file___NativeFile___io_open_write_t)(val_t p0, val_t p1, int* init_table);
val_t NEW_NativeFile_standard___file___NativeFile___io_open_write(val_t p0);
void standard___file___NativeFile___native_stdin(val_t p0, int* init_table);
typedef void (*standard___file___NativeFile___native_stdin_t)(val_t p0, int* init_table);
val_t NEW_NativeFile_standard___file___NativeFile___native_stdin();
void standard___file___NativeFile___native_stdout(val_t p0, int* init_table);
typedef void (*standard___file___NativeFile___native_stdout_t)(val_t p0, int* init_table);
val_t NEW_NativeFile_standard___file___NativeFile___native_stdout();
void standard___file___NativeFile___native_stderr(val_t p0, int* init_table);
typedef void (*standard___file___NativeFile___native_stderr_t)(val_t p0, int* init_table);
val_t NEW_NativeFile_standard___file___NativeFile___native_stderr();
#endif
