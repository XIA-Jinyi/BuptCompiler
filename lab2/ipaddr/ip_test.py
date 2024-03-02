#!/usr/bin/env python3
# encoding: utf-8

import ctypes
import os
import pickle


"""
Test cases originated from:

LeetCode 468. Validate IP Address
https://leetcode.com/problems/validate-ip-address/
"""


cwd = os.getcwd()
lib_path = os.path.join(cwd, 'libip.so')
lib = ctypes.cdll.LoadLibrary(lib_path)

def valid_ip_address(ip):
    func = lib.validIPAddress
    func.restype = ctypes.c_char_p
    ip_b = ip.encode('ascii')
    ip_buf = ctypes.c_char_p(ip_b)
    return func(ip_buf).decode()


test_cases = pickle.load(open('data.pickle', 'rb'))

for input_, output in test_cases.items():
    ans = valid_ip_address(input_+'\n')
    if ans != output:
        print('Wrong!')
        print('Input: %s' % input_)
        print('Excepted: %s' % output)
        print('Your answer: %s' % ans)
        break
else:
    print('All tests passed!')
