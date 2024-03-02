#ifndef SYMBOL_H_
#define SYMBOL_H_

typedef void *HANDLE;

#ifdef __cplusplus
extern "C" {
#endif

#include <stdlib.h>
#include "errlist.h"

enum Category {
    MASK_EXP    = 0x00f,
    MASK_VAR    = 0x0f0,
    MASK_DEC    = 0xf00,
    FLAG_ATOM   = 0x001,
    FLAG_SUB    = 0x010,
    FLAG_TAB    = 0x100,
    /**************************************************************************
    CATEGORY                VISIBILITY  DESCRIPTION
    **************************************************************************/
    E_RVAL      = 0x003, /* atom        Exp */
    V_PRIM      = 0x025, /* atom        Var & Param of primitive types */
    V_CMPLX     = 0x030, /* sub         Var & Param of struct types
                                            take sub as struct type */
    V_ARRAY     = 0x043, /* atom & sub  Var of array types
                                            take atom as elem type
                                                if atom != NOT_T
                                                (stores primitive)
                                            take sub as elem type
                                                if atom == NOT_T
                                                (stores struct)*/
    D_STRUCT    = 0x300, /* tab         Dec of struct type */
    D_FUNC      = 0x303, /* atom & tab  Dec of function type
                                            take atom as retval
                                            take tab as a var_table */
    /*************************************************************************/
};

enum Primitive {
    NOT_T   = 0b0000,
    FLOAT_T = 0b0001,
    INT_T   = 0b0010,
    CHAR_T  = 0b0100,
};

struct type_t {
    HANDLE handle;
};

struct table_t {
    HANDLE handle;
};

struct type_t   type_new        (const char *name, enum Category cat);
struct type_t   type_new_rval   (const char *name, enum Primitive atom);
struct type_t   type_new_prim   (const char *name, enum Primitive atom);
struct type_t   type_new_cmplx  (const char *name, struct type_t sub);
struct type_t   type_new_array  (const char *name, enum Primitive atom);
struct type_t   type_clone      (struct type_t type);
const char *    type_set_name   (struct type_t type, const char *name);
enum Category   type_set_cat    (struct type_t type, enum Category cat);
enum Primitive  type_set_atom   (struct type_t type, enum Primitive atom);
struct type_t   type_set_sub    (struct type_t type, struct type_t sub);
struct table_t  type_set_tab    (struct type_t type, struct table_t tab);
const char *    type_name       (struct type_t type);
enum Category   type_cat        (struct type_t type);
enum Primitive  type_atom       (struct type_t type);
struct type_t   type_sub        (struct type_t type);
struct table_t  type_tab        (struct type_t type);

struct table_t  tab_new     ();
int             tab_add     (struct table_t tab, struct type_t type);
struct type_t   tab_get     (struct table_t tab, const char *name);
int             tab_size    (struct table_t tab);
struct table_t  tab_clone   (struct table_t tab);
const char *    tab_join    (struct table_t dst, struct table_t src);
struct type_t   tab_next    (struct table_t tab);
#define         tab_traverse(tab, type) \
    for (struct type_t type = tab_next(tab); type.handle != NULL; type = tab_next(tab))

struct table_t ctx();
struct table_t ctx_init();
struct table_t ctx_fwd(int line_no);
struct table_t ctx_bwd();
struct table_t ctx_stage();
struct table_t ctx_stage_release();
struct table_t ctx_pass();
struct table_t ctx_pass_release();

struct type_t spec_push(struct type_t type);
struct type_t spec_pop();
struct type_t spec_top();

#ifdef __cplusplus
}
#endif

#endif
