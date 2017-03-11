#!/usr/bin/python3
#-*- coding:utf-8 -*-

'''
Sometimes player cannot change font style by built-in settings
It's necessary to directly change ssa file in order to modify
font type, size, color (primary and secondary), color (outline 
and background), style (bold and italic), shadow, etc.
Although .ssa file format is simplistic enough to edit with a text
editor, it is not convenient for batch editing.
'''
import sys, os
import argparse
import codecs
import re
from enum import Enum

"""
def argparser_init():
	'''
	Initialize argument parser for changing ssa font style
	'''
	parser = argparse.ArgumentParser(description='ssa subtitle editor in python')
	return parser
"""

class Errno(Enum):
	UNKNOWN = 0
	NO_SECTION = 1
	LACK_ELEMENT = 2
	UNDEF_ELEMENT = 3

class ssaScanner(object):
	'''
	Parse .ssa file and generate a file hierarchy tree
	Define relevant methods to read, modify and overwrite
	.ssa file.
	NOTE: Sometimes there is a BOM char at the beginning of file
	XXX add common font names, color definition  in future
	'''
	ssa_tree = None
	ssa_name = ""
	ssa_dir = ""
	ssa_encoding = ""

	class parseError(Exception):
		'''
		parseError object for parsing .ssa file
		'''
		def __init__(self, msg, errno=Errno.UNKNOWN):
			self.message = msg
			self.errno = errno
		def __str__(self):
			return repr(self.errno) + " " + self.message

	@staticmethod
	def parse_file(contents):
		ssa_tree = dict()
		empty_char = [' ', '\t', '\r', '\n']
		current_section = ''
		current_line = 1
		pattern = re.compile('^[\w ]+:[\t ]*[^\r\n ][^\r\n]*') # substring like "xy zw: &ab-cd :12_34"
		for line in contents:
			line_no_comment = line.split(';')[0].strip()
			
			if len(line_no_comment) == 0:
				current_line += 1
				continue

			m = re.search('\[[\w\ +]*\]', line_no_comment) 					# substring like [V4+ Styles]
																			# no section detected
			if m == None:
				n = pattern.search(line_no_comment)
				if n == None:
					raise ssaScanner.parseError("Line " + str(current_line) + ", illegal tokens", Errno.UNDEF_ELEMENT)
				else:
					if current_section == '':
						raise ssaScanner.parseError("Line " + str(current_line) + ", no valid section", Errno.NO_SECTION)
					else:
						# Add substring to ssa_tree[#current_section]

						index = n.group(0).find(':')
						entry_key = n.group(0)[0:index].strip()	# substring divided by the first ':' is the key of entry
																	# unpack the remaining contents into a token list
						entry_list = [token.strip() for token in n.group(0)[index+1:].split(',')]
																	# add the list into ssa_tree
						try:
							ssa_tree[current_section][entry_key].append(entry_list)
						except KeyError:							# KeyError raised when entry_key is empty
							ssa_tree[current_section][entry_key] = []
							ssa_tree[current_section][entry_key].append(entry_list)
						current_line += 1
						continue
			else:
				s = re.search('[^\s]', line_no_comment[m.end()+1:])	# search for any illegal characters
				if m.start() != 0 or s != None:
					raise ssaScanner.parseError("Line " + str(current_line) + ", illegal tokens", Errno.UNDEF_ELEMENT)
				else:
					current_section = m.group(0)[1:-1].strip()		# new section name
					ssa_tree[current_section] = dict()
					current_line += 1
					continue
		return ssa_tree

	def __init__(self, file_name, **kwargs):
		if "encoding" in kwargs:
			self.ssa_encoding = kwargs["encoding"]
		else:
			self.ssa_encoding = 'UTF-8'

		with codecs.open(file_name, 'r', encoding=self.ssa_encoding) as fp:
			self.ssa_dir = os.path.join(os.getcwd(), file_name)
			self.ssa_name = file_name.split('/')[-1]
			contents = fp.readlines()
			# clear BOM char
			if ord(contents[0][0]) == 0xfeff:
				contents[0] = contents[0][1:]
			self.ssa_tree = self.parse_file(contents)

	def __str__(self):
		return ssa_dir + "\nEncoding: " + self.ssa_encoding