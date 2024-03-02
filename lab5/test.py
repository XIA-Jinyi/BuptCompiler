#!/usr/bin/env python3
# encoding: utf-8

import ctypes
import os
import random
import string
import unittest

class SymbolTable(ctypes.Structure):
    cwd = os.getcwd()
    lib_path = os.path.join(cwd, 'libsymtab.so')
    lib = ctypes.CDLL(lib_path)
    def __init__(self):
        self.lib.symtab_init.restype = ctypes.POINTER(SymbolTable)
        self.lib.symtab_insert.restype = ctypes.c_int32
        self.lib.symtab_lookup.restype = ctypes.c_int32
        self.lib.symtab_remove.restype = ctypes.c_int32
        self.this = self.lib.symtab_init()

    @staticmethod
    def safe_key(key):
        assert len(key) <= 32
        key_b = key.encode('ascii')
        key_buf = ctypes.c_char_p(key_b)
        return key_buf

    def insert(self, key, value):
        key = self.safe_key(key)
        r = self.lib.symtab_insert(self.this, key, value)
        return int(r)

    def lookup(self, key):
        key = self.safe_key(key)
        r = self.lib.symtab_lookup(self.this, key)
        return int(r)

    def remove(self, key):
        key = self.safe_key(key)
        r = self.lib.symtab_remove(self.this, key)
        return int(r)


class SymbolTableTest(unittest.TestCase):
    def setUp(self):
        random.seed(1307)

    def test_01(self):
        st = SymbolTable()
        st.insert('10', 10)
        st.insert('20', 20)
        self.assertEqual(st.lookup('10'), 10)
        self.assertEqual(st.lookup('20'), 20)
        self.assertEqual(st.insert('30', 30), 1)
        self.assertEqual(st.insert('10', 100), 0)
        st.remove('10')
        self.assertEqual(st.insert('10', 100), 1)
        self.assertEqual(st.lookup('10'), 100)
        self.assertEqual(st.remove('10'), 1)
        self.assertEqual(st.remove('10'), 0)

    def test_02(self):
        st = SymbolTable()
        size = 1000
        data = list(range(size))
        random.shuffle(data)
        for i in data:
            st.insert(str(i), i)
        for i in data:
            s = st.lookup(str(i))
            self.assertEqual(s, i)
        self.assertEqual(st.lookup(str(size)), -1)

    def test_03(self):
        letters = string.ascii_lowercase + string.ascii_uppercase
        st = SymbolTable()
        tab = dict()
        size = random.randint(500, 1000)
        while len(tab) < size:
            k = ''.join(random.choice(letters) for _ in range(8))
            v = random.randint(0, 10000)
            tab[k] = v
            st.insert(k, v)
        ks = list(tab)

        trial = random.randint(500, 800)
        for _ in range(trial):
            k = random.choice(ks)
            v = tab[k]
            self.assertEqual(st.lookup(k), v)

        trial = random.randint(200, 400)
        for k in random.sample(ks, trial):
            del tab[k]
            self.assertEqual(st.remove(k), 1)

        trial = random.randint(400, 700)
        for _ in range(trial):
            k = random.choice(ks)
            if k in tab:
                self.assertEqual(st.lookup(k), tab[k])
            else:
                self.assertEqual(st.lookup(k), -1)


if __name__ == '__main__':
    unittest.main()
