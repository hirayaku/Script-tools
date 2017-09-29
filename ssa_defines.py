#!/usr/bin/python3
# -*- coding: utf-8 -*-
# Common format field names in SSA spec

COMMENT_MARKS = [";", "!:"]
SPLIT = ','
field_names = {
    "Script Info": ["Title", "Origianl Script","Script Type", "Collisions", "PlayResY", "PlayResX", "PlayDepth", "Timer", "WrapStyle"],
    "V4 Style": ["Name", "Fontname", "Fontsize", "PrimaryColour", "SecondaryColour", "OutlineColour", "BackColour", "Bold", "Italic", "Underline", "StrikeOut", "ScaleX", "ScaleY", "Spacing", "Angle", "BorderStyle", "Outline", "Shadow", "Alignment", "MarginL", "MarginR", "MarginV", "AlphaLevel", "Encoding"],
    "V4+ Style": ["Name", "Fontname", "Fontsize", "PrimaryColour", "SecondaryColour", "OutlineColour", "BackColour", "Bold", "Italic", "Underline", "StrikeOut", "ScaleX", "ScaleY", "Spacing", "Angle", "BorderStyle", "Outline", "Shadow", "Alignment", "MarginL", "MarginR", "MarginV", "Encoding"],
    "Events": ["Marked", "Start", "End", "Style", "Name", "MarginL", "MarginR", "MarginV", "Effect", "Text"],
    "Fonts": [],
    "Graphics": []
    }
