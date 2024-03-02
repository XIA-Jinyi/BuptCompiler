#include "symbol.h"
#include <string>
#include <list>
#include <map>
#include <iostream>
#include <cstdio>
#include <stack>
#include <cassert>

using std::string;
using std::list;
using std::map;
using std::stack;

class Type {
    public:
        string name;
        enum Category cat;
        enum Primitive atom;
        struct type_t sub;
        struct table_t tab;

        Type(): name{""}, cat{E_RVAL}, atom{NOT_T}, sub{.handle = NULL}, tab{.handle = NULL} {}

        type_t dump() {
            return type_t{static_cast<HANDLE>(this)};
        }

        static Type &load(type_t type) {
            return *static_cast<Type *>(type.handle);
        }
};

class Table {
    public:
        list<type_t> type_list;
        map<string, list<type_t>::iterator> type_map;

        Table() {}

        int add(type_t type) {
            if (type_map.find(Type::load(type).name) != type_map.end()) {
                return 0;
            }
            type_list.push_back(type);
            type_map[Type::load(type).name] = --type_list.end();
            return type_list.size();
        }

        type_t get(string name) {
            if (type_map.find(name) == type_map.end()) {
                return type_t{.handle = NULL};
            }
            return *type_map[name];
        }

        table_t dump() {
            return table_t{static_cast<HANDLE>(this)};
        }

        static Table &load(table_t table) {
            return *static_cast<Table *>(table.handle);
        }
};

struct table_t staged{.handle = NULL};
struct table_t passed{.handle = NULL};
stack<table_t> ctx_stack;

struct type_t type_new(const char *name, enum Category cat) {
    static list<Type> pool;
    pool.push_back(Type());
    pool.back().name = name ? name : "";
    pool.back().cat = cat;
    return pool.back().dump();
}

struct type_t type_new_rval(const char *name, enum Primitive atom)
{
    Type &t = Type::load(type_new(name, E_RVAL));
    t.atom = atom;
    return t.dump();
}

struct type_t type_new_prim(const char *name, enum Primitive atom) {
    Type &t = Type::load(type_new(name, V_PRIM));
    t.atom = atom;
    return t.dump();
}

struct type_t type_new_cmplx(const char *name, struct type_t sub) {
    Type &t = Type::load(type_new(name, V_CMPLX));
    t.sub = sub;
    return t.dump();
}

struct type_t type_new_array(const char *name, enum Primitive atom) {
    Type &t = Type::load(type_new(name, V_ARRAY));
    t.atom = atom;
    return t.dump();
}

struct type_t type_clone(struct type_t type) {
    Type &t = Type::load(type);
    Type &clone = Type::load(type_new(t.name.c_str(), t.cat));
    clone.atom = t.atom;
    clone.sub = t.sub;
    clone.tab = t.tab;
    return clone.dump();
}

struct table_t tab_new()
{
    static list<Table> pool;
    pool.push_back(Table());
    return pool.back().dump();
}

const char *type_set_name(struct type_t type, const char *name) {
    Type &t = Type::load(type);
    t.name = name;
    return t.name.c_str();
}

enum Category type_set_cat(type_t type, enum Category cat)
{
    Type &t = Type::load(type);
    t.cat = cat;
    return t.cat;
}

enum Primitive type_set_atom(type_t type, enum Primitive atom) {
    Type &t = Type::load(type);
    t.atom = atom;
    return t.atom;
}

struct type_t type_set_sub(type_t type, struct type_t sub) {
    Type &t = Type::load(type);
    t.sub = sub;
    return t.sub;
}

struct table_t type_set_tab(type_t type, struct table_t tab) {
    Type &t = Type::load(type);
    t.tab = tab;
    return t.tab;
}

const char *type_name(type_t type) {
    return Type::load(type).name.c_str();
}

enum Category type_cat(type_t type) {
    return Type::load(type).cat;
}

enum Primitive type_atom(type_t type) {
    return Type::load(type).atom;
}

struct type_t type_sub(type_t type) {
    return Type::load(type).sub;
}

struct table_t type_tab(type_t type) {
    return Type::load(type).tab;
}

int tab_add(struct table_t tab, struct type_t type) {
    return Table::load(tab).add(type);
}

struct type_t tab_get(struct table_t tab, const char *name) {
    return Table::load(tab).get(name);
}

int tab_size(struct table_t tab) {
    return Table::load(tab).type_list.size();
}

struct table_t tab_clone(struct table_t tab) {
    Table &t = Table::load(tab);
    Table &clone = Table::load(tab_new());
    for (auto &type: t.type_list) {
        clone.add(type);
    }
    return clone.dump();
}

const char *tab_join(struct table_t dst, struct table_t src) {
    Table &d = Table::load(dst);
    Table &s = Table::load(src);
    for (auto &type: s.type_list) {
        if (!d.add(type)) {
            return type_name(type);
        }
    }
    return NULL;
}

struct type_t tab_next(struct table_t tab) {
    static map<HANDLE, list<type_t>::iterator> iter_map;
    if (iter_map.find(tab.handle) == iter_map.end()) {
        iter_map[tab.handle] = Table::load(tab).type_list.begin();
    }
    if (iter_map[tab.handle] == Table::load(tab).type_list.end()) {
        iter_map.erase(tab.handle);
        return type_t{.handle = NULL};
    }
    return *iter_map[tab.handle]++;
}

struct table_t ctx() {
    return ctx_stack.top();
}

struct table_t ctx_init() {
    passed = tab_new();
    staged = tab_new();
    ctx_stack.push(tab_new());
    return ctx();
}

struct table_t ctx_fwd(int line_no) {
    ctx_stack.push(tab_clone(ctx()));
    Table &pass = Table::load(passed), &context = Table::load(ctx());
    bool error = false;
    for (auto type: pass.type_list) {
        if (!context.add(type)) {
            printf("Error at line %d: redeclaration of '%s'\n", line_no, type_name(type));
            error = true;
        }
    }
    ctx_pass_release();
    ctx_stage_release();
    return error ? table_t{.handle = NULL} : ctx();
}

struct table_t ctx_bwd() {
    ctx_stack.pop();
    ctx_pass_release();
    ctx_stage_release();
    return ctx();
}

struct table_t ctx_stage() {
    return staged;
}

struct table_t ctx_stage_release() {
    staged = tab_new();
    return staged;
}

struct table_t ctx_pass() {
    return passed;
}

struct table_t ctx_pass_release() {
    passed = tab_new();
    return passed;
}

stack<type_t> spec_stack;

struct type_t spec_push(struct type_t type) {
    spec_stack.push(type);
    return type;
}

struct type_t spec_pop() {
    type_t type = spec_stack.top();
    spec_stack.pop();
    return type;
}

struct type_t spec_top() {
    return spec_stack.top();
}

// #define MAIN_
#ifdef MAIN_
    int main() {
    // Declare a struct type
    type_t d1 = type_new("struct_a", D_STRUCT);
    type_set_tab(d1, tab_new());
    tab_add(type_tab(d1), type_new_prim("x", FLOAT_T));
    tab_add(type_tab(d1), type_new_prim("n", INT_T));
    tab_add(type_tab(d1), type_new_prim("c", CHAR_T));

    // Declare variables
    type_t v1 = type_new_prim("var_a", INT_T);
    type_t v2 = type_new_cmplx("var_b", d1);
    type_t v3 = type_new_array("var_c", CHAR_T);

    auto traverse = [](struct table_t tab)
    {
        tab_traverse(tab, iter)
        {
            printf("%s: %d", type_name(iter), type_cat(iter));
            if (type_cat(iter) == V_CMPLX)
            {
                puts(", +");
                tab_traverse(type_tab(type_sub(iter)), sub_iter)
                {
                    printf("  %s: %d, %d\n", type_name(sub_iter), type_cat(sub_iter), type_atom(sub_iter));
                }
            }
            else
            {
                printf(", %d\n", type_atom(iter));
            }
        }
        puts("--------------------");
    };

    ctx_init();
    tab_add(ctx_pass(), v1);
    tab_add(ctx(), v2);
    ctx_fwd(1);
    tab_add(ctx(), v3);
    traverse(ctx());
    ctx_bwd();
    traverse(ctx());

    return 0;
}
#endif
