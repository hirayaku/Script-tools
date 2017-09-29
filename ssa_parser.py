#!/usr/bin/python3
# -*- coding:utf-8 -*-
# SSA/ASS parser in python
# Input is the ssa/ass formated subtitle file
# return an SSA object

import sys, os, copy
import codecs
import re
from enum import Enum
import ssa_defines

# Some utility functions
def is_comment(line):
    for c_prefix in ssa_defins.COMMENT_MARKS:
        if line.strip().startswith(c_prefix):
            return True
    return False

def parse_line(line):
    '''
    Paser a non-empty normal line (not a section name line),
    return a dict of contents
    '''
    line_dict = dict()
    line_content = copy.deepcopy(line)
    # Split comments
    comment_str = ''
    for c_prefix in ssa_defines.COMMENT_MARKS:
        c_pos = line_content.find(c_prefix)
        if c_pos != -1:
            comment_str = line_content[c_pos:] + comment_str
            line_content = line_content[:c_pos]
    line_dict["comment"] = comment_str
    # Split meaningful stuff, if any
    line_content = line_content.strip()
    if line_content is '':
        return line_dict

    des_pos = line_content.find(":")
    if des_pos != -1:
        line_des = line_content[:des_pos]
        line_fields = [field.strip() for field in line_content[des_pos+1:].split(ssa_defines.SPLIT)]
        line_dict["descriptor"] = line_des
        line_dict["fields"] = line_fields
    else:
        raise SSAScanner.parseError("Line descriptor not found", Errno.LACK_ELEMENT)

    return line_dict

class SSALine(object):
    '''
    SSA line info class
    type: 'comment', 'attribute', 'format' or 'formatted'.
    '''
    default_type    =   'use_parsed'
    def __init__(self, line_string, formatted=False):
        self.type   =   
        self.descriptor 

class SSASection(object):
    '''
    SSA section info class
    '''
    default_type    =   'attribute'
    def __init__(self, title_string):
    def __init__(self, title, sec_type=SSASection.default_type, line_start=0):
        self.title      =   title
        self.type       =   sec_type
        self.line_start =   line_start
        self.content    =   None

class Errno(Enum):
    UNKNOWN = 0
    NO_SECTION = 1
    LACK_ELEMENT = 2
    WRONG_FORMAT = 3

class SSAScanner(object):
    '''
    Parse .ssa file and generate a file hierarchy tree
    Define relevant methods to read, modify and overwrite
    .ssa file.
    NOTE: Sometimes there is a BOM char at the beginning of file
    '''
    ssa_tree = None
    ssa_name = ""
    ssa_dir = ""
    ssa_encoding = ""

    class parseError(Exception):
        '''
        parseError object for parsing .ssa file
        '''
        def __init__(self, msg='', errno=Errno.UNKNOWN):
            self.message = msg
            self.errno = errno
        def __str__(self):
            return repr(self.errno) + " " + self.message

    @staticmethod
    def parse_section(section, **kwargs):
        '''
        Given a section text, return parsed section info in dict
        The section text has no empty lines (comment lines are allowed), only one section name
        the first line should start with a section name.

        formatted=True: this section is a formatted section. Format line will be searched first,
                        the rest of the section text will be interpreted according to the format
        @"type":    "formatted"
        @"name":    section name
        @"format", "contents":
                    "format":  <list of required fields>,
                    "contents":
                    {
                        <type-1>: [
                            <list of fields data>,
                            <list of fields data>
                            ...
                            ],
                        <type-2>: [
                            ...
                            ],
                        ...
                    }
        @"comments":comment lines

        formatted=False: this section is an attribute section. Attributes are read line by line.
        @"type":    "attribute"
        @"name":    section name
        @"attrs":   a dict of attributes
        @"comments":comment lines
        '''
        def parse_section_name(section_str):
            section_str = section_str.strip()
            if section_str[0] is not '[' and section_str[-1] is not ']':
                raise SSAScanner.parseError("Section name not found", Errno.LACK_ELEMENT)
            else:
                return section_str[1:-1].strip()

        formatted = kwargs["formatted"] if 'formatted' in kwargs else False
        section_dict = dict()
        # Read section name
        section = section.strip()
        lines = section.splitlines()
        section_dict["name"] = parse_section_name(lines[0])
        lines_parsed = map (SSAScanner.parse_line, lines[1:])

        if formatted:
            section_dict["type"] = "formatted"
            section_dict["format"] = []
            section_dict["contents"] = []
            section_dict["comments"] = []
            remains = []

            format_found = False
            for pl in lines_parsed:
                if "descriptor" not in pl:
                    section_dict["comments"].append(pl["comment"])
                elif format_found:
                    if len(pl["fields"]) != len(section_dict["format"][0]):
                        raise SSAScanner.parseError("Format not conformed", Errno.WRONG_FORMAT)
                    section_dict["contents"].append([pl["fields"], pl["comment"], pl["descriptor"]] )
                else:
                    if pl["descriptor"] == "Format":
                        section_dict["format"] = [pl["fields"], pl["comment"]]
                        format_found = True
                    else:
                        raise SSAScanner.parseError("First line should be the format", Errno.LACK_ELEMENT)

        else:
            section_dict["type"] = "attribute"
            section_dict["attrs"] = dict()
            section_dict["comments"] = []
            for pl in lines_parsed:
                if "descriptor" in pl:
                    section_dict["attrs"][pl["descriptor"]] = [pl["fields"], pl["comment"]]
                else:
                    section_dict["comments"].append(pl["comment"])
        return section_dict

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
text = '''
    [Section!]
    Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding
    Style: Default,華康魏碑體,45,&H00FFFFFF,&H000000FF,&H00353535,&H00000000,0,0,0,0,100,100,0,0,1,2,1,2,10,10,15,1
    Style: 註釋,華康魏碑體,35,&H00FFFFFF,&H000000FF,&H00353535,&H00000000,0,0,0,0,100,100,0,0,1,2,1,7,10,10,15,1
    Style: 標,@華康魏碑體,45,&H00FFFFFF,&H000000FF,&H00353535,&H00000000,0,0,0,0,100,100,0,-90,1,0,0,2,10,10,15,1
    Style: OPJP,DFPGyoSho-Lt,45,&H00FFFFFF,&H000000FF,&H00353535,&H00000000,-1,0,0,0,100,100,0,0,1,2,1,1,10,10,10,1
    Style: OPCH,華康行楷體W5(P),45,&H00FFFFFF,&H000000FF,&H00353535,&H00000000,0,0,0,0,100,100,0,0,1,2,1,7,10,10,10,1
    ; This is comment
    '''
text_parsed = SSAScanner.parse_section(text, formatted=True)
for parsed in text_parsed:
    print(parsed, text_parsed[parsed])
