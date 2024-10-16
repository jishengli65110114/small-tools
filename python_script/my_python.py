#! /usr/bin/python
# -*- coding: utf-8 -*-
import sys 
import argparse
import os
import subprocess

print("begin to run:",sys.argv[0])

def get_parameter_one():
    if len(sys.argv) > 1:
        for i in range(1,len(sys.argv),1):
            if sys.argv[i] == "-n":
                n_param = sys.argv[i+1];
            elif sys.argv[i] == "-help":
                print("help message")

def get_parameter_two():
    parser = argparse.ArgumentParser(description="help or error message")

    parser.add_argument('-name',type=str,help='name')
    parser.add_argument('-n',type=str,default='n_param',help='n_parameter')
    parser.add_argument('-help',type=str,help='name: -n: -help:')   

    args = parser.parse_args()
    return args

def read_all_doc():

def reg_wire_auto_add():

def width_check():    

if __name__ == "__main__":
    args = get_parameter_two()
    print(args)
    
