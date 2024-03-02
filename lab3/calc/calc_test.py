#!/usr/bin/env python3
# encoding: utf-8

import ctypes
import os


cwd = os.getcwd()
lib_path = os.path.join(cwd, 'libcalc.so')
lib = ctypes.cdll.LoadLibrary(lib_path)

def evaluate(expr):
    func = lib.evaluate
    func.restype = ctypes.c_int
    expr += ' = '
    expr_b = expr.encode('ascii')
    expr_buf = ctypes.c_char_p(expr_b)
    return func(expr_buf)

testcases = [
    ('1 + 1', 2),
    ('4 - 1', 3),
    ('3 - 2*4', -5),
    ('10 - 4/2', 8),
    ('2*8 - 9/3', 13),
    ('4*2 - 6', 2),
    ('1+1 - 1*3', -1),
]

for q, a in testcases:
    r = evaluate(q)
    assert r == a, '%s: expect %d; got %d' % (q,a,r)
else:
    print('pass all test cases')
