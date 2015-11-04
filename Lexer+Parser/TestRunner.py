#!/usr/bin/python
import os
from os.path import expanduser

HOME = expanduser("~")
DEV_HOME = HOME + "/dev"
PROJ_HOME = DEV_HOME + "/looc"
TESTS_HOME = PROJ_HOME + "/tests"
LPSRC_HOME = PROJ_HOME + "/Lexer+Parser"

for file in os.listdir(TESTS_HOME):
  if file.endswith(".cl"):
    print(file)
