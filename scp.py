#!/usr/bin/python3

import sys, os
import argparse
import subprocess

class ExecError(Exception):
    pass

# path of scp, has defaults; source file; dest file; upload or download
def arg_parser():
    parser = argparse.ArgumentParser(description='SCP(Secure Copy)-made-easy python script')
    parser.add_argument('-p', '--path', help='Path to scp or pscp (default: $PATH or %%PATH%%)') # Add an optional parameter
    parser.add_argument('src', metavar='if=...', help='Path to the source file') # Add a positional parameter
    parser.add_argument('dest', metavar='of=...', help='Path to the destination file')
    # Add a must-have non-positional parameter with limited choices
    parser.add_argument('-d', '--direction', required=True, help='Direction of file transfer', choices=['upload', 'download']) 
    # Add an optional parameter with default value and store_const action
    parser.add_argument('-r', dest='is_dir', action='store_const', const=True, default=False, help='Directory transfer');
    parser.add_argument('--default', dest='load_default', action='store_const', const=True, default=False, help='Load default file configuration')
    return parser

def check_exec(args):
    exec_path = args['path']
    if exec_path is not None: # If path is assigned in args
        if not os.access(exec_path, os.F_OK|os.X_OK) or os.path.isdir(exec_path):
            raise ExecError("Cannot execute " + exec_path)
    else: # If default value of path is used
        exec_path = 'pscp.exe' if os.name == 'nt' else 'scp'
        bin_paths = os.environ['PATH'].split(';')
        found = False
        for item in bin_paths:
            if os.path.isdir(item):
                if exec_path in os.listdir(item): # If executable is found in current directory
                    found = True
                    exec_path = os.path.join(item, exec_path)
                    break
            else:
                if os.path.basename(item) == exec_path: # If executable exists in PATH environ vars
                    found = True
                    exec_path = item
                    break
        if found:
            if not os.access(exec_path, os.X_OK):
                raise ExecError("Cannot execute " + exec_path)
        else:
            raise ExecError("Cannot find " + exec_path)

    return exec_path

if __name__ == '__main__':
    default = "xxx"

    parser = arg_parser()
    args = vars(parser.parse_args())
# Set executable path and check permission
    try:
        exec_path = check_exec(args)
    except ExecError as e:
        print("ExecError: ", e)
        sys.exit()

# Set the paths of src and dest files; set transfer direction
    direction = args['direction']
    is_dir = args['is_dir']
    src, dest = args['src'], args['dest']
    if src.startswith('if=') and dest.startswith('of='):
        '''do nothing'''
    elif src.startswith('of=') and dest.startswith('if='):
        src, dest = dest, src
    else:
        print("Use `if=' and `of=' to assign src and dest")
        parser.print_help()
        sys.exit()
    src, dest = src.lstrip('if='), dest.lstrip('of=')
    
    # Load defaults
    if args['load_default'] == True:
        host, folder = tuple(default.split(':'))
        if direction == 'upload':
            dest = os.path.join(folder, dest)
            dest = host + ':' + dest
        else:
            src = os.path.join(folder, src)
            src = host + ':' + src

# Check the existence and permission of src/dest directory/file is tricky
# Leave the work to pscp.exe/scp

# exec_path; direction, src, dest; is_dir
    commands = [exec_path]
    if is_dir:
        commands.append('-r')
    commands = commands + [src, dest]
    proc = subprocess.Popen(commands, stdout=subprocess.PIPE, stdin=subprocess.PIPE, stderr=subprocess.PIPE)
    stdout, stderr = proc.communicate(input=b'xxx\n')
    print(stdout.decode())
    print(stderr.decode())
    proc.kill()
    sys.exit()
