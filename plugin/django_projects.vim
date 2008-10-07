" Author: Gregor Müllegger <gregor@muellegger.de>
" Version: 0.1.0
"
" Description:
"   Use the script to run simple django specific tasks. You can run management
"   commands from in vim.
"
" Requirements:
"   The script will only work on a unix-like system.
"
" Installation:
"   Put this file (django_projects.vim) in your plugin directory and tell the
"   script what django projects you are working on.
"   
"   To install a single django project use the g:DjangoInstall() function. Put a
"   lines similar to the following in your vimrc file:
"
"     call g:DjangoInstall('myproject', '/home/username/projects/myproject/', 'settings', 'manage.py', ['/usr/local/pythonlibs', 'apps/'], '.')
"
"   The arguments mean the following things:
"     1. argument (name): This is the projects name. It is used with the DjangoInit
"     command to tell the script on which project you work on.
"
"     2. argument (project root): This should be an absolute path to your 
"     project. It is used to complete relative paths in the `manage_file`,
"     `paths` and `cd` argument. This argument must end with a slash.
"
"     3. argument (settings module): Specify here the name of your settings
"     module. This value is used to set the $DJANGO_SETTINGS_MODULE variable.
"
"     4. argument (manage.py file): Specify here the path of your manage.py
"     file. The project root path is prepended to this argument if a relative
"     path is given (e.g. the argument does not start with '/')
"
"     5. argument (python paths): This argument must be a list of strings. The
"     script will add these paths to your sys.path variable. If a path is
"     relative, the project root argument will be prepended.
"
"     6. argument (cd): Specify a directory in which the script will jump while
"     calling g:DjangoInit('myproject'). If not specified (e.g. it is an empty
"     string) no cd is performed.
"
"   Note: Maybe you need to include the source of this file into your .vimrc
"   (if the plugin is loaded after your g:DjangoInstall() calls). The simplest
"   way to do this is to put this line right before your g:DjangoInstall
"   calls:
"
"     source ~/.vim/plugin/django_projects.vim
"
" Usage:
"   When you have specified all your django projects you can now tell the script
"   that you want now to work with one of them. Let's expect you want to work
"   with your 'fancyblog' project.
"   
"   At first you have to initalize this project:
"     :DjangoInit fancyblog
"
"   Now you can use all the cool commands to work with your project. Use
"   `:DjangoManage <command>` to execute a command with your manage.py file.
"
"     :DjangoManage syncdb
"
"   Use the `:DjangoTerminalManage <command>` command to execute a manage.py
"   command in an external terminal to free the vim command line for new
"   commands. This can be used to run django's development server from within
"   vim.
"
" Configuration:
"   There are a few global variables you can change to fit the script your
"   preferences:
"
"   g:django_terminal_program
"     Set this variable to a terminal programm which shall execute the commands
"     in :DjangoTerminalManage. Default is 'xterm -e'.
"
" Shortcuts:
"   There are already shortcuts for every builtin command to prevent you from
"   performing too many keystrokes:
"
"     :DjangoAdminindex
"     :DjangoCleanup
"     :DjangoCompileMessages
"     :DjangoCreateCachetable
"     :DjangoCreateSuperuser
"     :DjangoDBShell
"     :DjangoDiffsettings
"     :DjangoDumpdata
"     :DjangoFlush
"     :DjangoHelp command
"     :DjangoInspectDB
"     :DjangoLoaddata
"     :DjangoMakeMessages
"     :DjangoReset appname
"     :DjangoRunfcgi
"     :DjangoRunserver
"     :DjangoShell
"     :DjangoSql
"     :DjangoSqlall
"     :DjangoSqlclear
"     :DjangoSqlcustom
"     :DjangoSqlflush
"     :DjangoSqlindexes
"     :DjangoSqlinitialdata
"     :DjangoSqlreset
"     :DjangoSqlsequencereset
"     :DjangoStartapp newappname
"     :DjangoSyncdb
"     :DjangoTest [appnames]
"     :DjangoTestserver
"     :DjangoValidate
"
"   You can also use the commands from the django-commands-extension app if you
"   have installed it.
"
"     :DjangoCreateapp
"     :DjangoCreatecommand
"     :DjangoCreatejobs
"     :DjangoDescribeform
"     :DjangoDumpscript
"     :DjangoExportemails
"     :DjangoGenerateSecretKey
"     :DjangoGraphmodels
"     :DjangoPasswd
"     :DjangoPrintUserForSession
"     :DjangoResetDB
"     :DjangoRunjob
"     :DjangoRunjobs
"     :DjangoRunprofile
"     :DjangoRunscript
"     :DjangoRunserverPlus
"     :DjangoSetfakepasswords
"     :DjangoShellPlus
"     :DjangoShowurls
"     :DjangoSqldiff
"
" License:
"   Software License Agreement (BSD License)
"
"   Copyright (c) 2008, Gregor Müllegger
"   All rights reserved.
"
"   Redistribution and use of this software in source and binary forms, with
"   or without modification, are permitted provided that the following
"   conditions are met:
"
"   * Redistributions of source code must retain the above
"     copyright notice, this list of conditions and the
"     following disclaimer.
"
"   * Redistributions in binary form must reproduce the above
"     copyright notice, this list of conditions and the
"     following disclaimer in the documentation and/or other
"     materials provided with the distribution.
"
"   * Neither the name of Gergely Kontra or Eric Van Dewoestine nor the names
"   of its contributors may be used to endorse or promote products derived
"   from this software without specific prior written permission of Gergely
"   Kontra or Eric Van Dewoestine.
"
"   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
"   IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
"   THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
"   PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
"   CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
"   EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
"   PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
"   PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
"   LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
"   NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
"   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
"
if exists('s:django_project_loaded')
  finish
endif
let s:django_project_loaded = 1
let s:python_paths = []

if !exists('g:django_projects')
  let g:django_projects = {}
endif
if !exists('g:django_current_project')
  let g:django_current_project = ""
endif
if !exists('g:django_terminal_program')
  let g:django_terminal_program = "xterm -e"
endif



command! -nargs=+ -bar DjangoInit call g:DjangoInit('<args>')
command! -nargs=0 -bar DjangoUninit call g:DjangoUninit()

command! -nargs=+ -bar DjangoManage call g:DjangoManage('<args>')
command! -nargs=+ -bar DjangoTerminalManage call g:DjangoTerminalManage('<args>')

command! -nargs=* -bar DjangoAdminindex call g:DjangoManage('adminindex <args>')
command! -nargs=* -bar DjangoCleanup call g:DjangoManage('cleanup <args>')
command! -nargs=* -bar DjangoCompileMessages call g:DjangoManage('compilemessages <args>')
command! -nargs=* -bar DjangoCreateCachetable call g:DjangoManage('createcachetable <args>')
command! -nargs=* -bar DjangoCreateSuperuser call g:DjangoManage('createsuperuser <args>')
command! -nargs=* -bar DjangoDBShell call g:DjangoTerminalManage('dbshell <args>')
command! -nargs=* -bar DjangoDiffsettings call g:DjangoManage('diffsettings <args>')
command! -nargs=* -bar DjangoDumpdata call g:DjangoManage('dumpdata <args>')
command! -nargs=* -bar DjangoFlush call g:DjangoManage('flush <args>')
command! -nargs=* -bar DjangoHelp call g:DjangoManage('help <args>')
command! -nargs=* -bar DjangoInspectDB call g:DjangoManage('inspectdb <args>')
command! -nargs=* -bar DjangoLoaddata call g:DjangoManage('loaddata <args>')
command! -nargs=* -bar DjangoMakeMessages call g:DjangoManage('makemessages <args>')
command! -nargs=+ -bar DjangoReset call g:DjangoManage('reset <args>')
command! -nargs=+ -bar DjangoRunfcgi call g:DjangoManage('runfcgi <args>')
command! -nargs=* -bar DjangoRunserver call g:DjangoTerminalManage('runserver <args>')
command! -nargs=* -bar DjangoShell call g:DjangoTerminalManage('shell <args>')
command! -nargs=+ -bar DjangoStartapp call g:DjangoManage('startapp <args>')
command! -nargs=* -bar DjangoSyncdb call g:DjangoManage('syncdb <args>')
command! -nargs=* -bar DjangoSql call g:DjangoManage('sql <args>')
command! -nargs=* -bar DjangoSqlall call g:DjangoManage('sqlall <args>')
command! -nargs=* -bar DjangoSqlclear call g:DjangoManage('sqlclear <args>')
command! -nargs=* -bar DjangoSqlcustom call g:DjangoManage('sqlcustom <args>')
command! -nargs=* -bar DjangoSqlflush call g:DjangoManage('sqlflush <args>')
command! -nargs=* -bar DjangoSqlindexes call g:DjangoManage('sqlindexes <args>')
command! -nargs=* -bar DjangoSqlinitialdata call g:DjangoManage('sqlinitialdata <args>')
command! -nargs=* -bar DjangoSqlreset call g:DjangoManage('sqlreset <args>')
command! -nargs=* -bar DjangoSqlsequencereset call g:DjangoManage('sqlsequencereset <args>')
command! -nargs=* -bar DjangoTest call g:DjangoManage('test <args>')
command! -nargs=* -bar DjangoTestserver call g:DjangoTerminalManage('testserver <args>')
command! -nargs=* -bar DjangoValidate call g:DjangoManage('validate <args>')

" django-command-extensions commands
command! -nargs=* -bar DjangoCreateapp call g:DjangoManage('create_app <args>')
command! -nargs=* -bar DjangoCreatecommand call g:DjangoManage('create_command <args>')
command! -nargs=* -bar DjangoCreatejobs call g:DjangoManage('create_jobs <args>')
command! -nargs=* -bar DjangoDescribeform call g:DjangoManage('describe_form <args>')
command! -nargs=* -bar DjangoDumpscript call g:DjangoManage('dumpscript <args>')
command! -nargs=* -bar DjangoExportemails call g:DjangoManage('export_emails <args>')
command! -nargs=* -bar DjangoGenerateSecretKey call g:DjangoManage('generate_secret_key <args>')
command! -nargs=* -bar DjangoGraphmodels call g:DjangoManage('graph_models <args>')
command! -nargs=* -bar DjangoPasswd call g:DjangoManage('passwd <args>')
command! -nargs=* -bar DjangoPrintUserForSession call g:DjangoManage('print_user_for_session <args>')
command! -nargs=* -bar DjangoResetDB call g:DjangoManage('reset_db <args>')
command! -nargs=* -bar DjangoRunjob call g:DjangoManage('runjob <args>')
command! -nargs=* -bar DjangoRunjobs call g:DjangoManage('runjobs <args>')
command! -nargs=* -bar DjangoRunprofile call g:DjangoTerminalManage('runprofileserver <args>')
command! -nargs=* -bar DjangoRunscript call g:DjangoManage('runscript <args>')
command! -nargs=* -bar DjangoRunserverPlus call g:DjangoTerminalManage('runserver_plus <args>')
command! -nargs=* -bar DjangoSetfakepasswords call g:DjangoManage('set_fake_passwords <args>')
command! -nargs=* -bar DjangoShellPlus call g:DjangoTerminalManage('shell_plus <args>')
command! -nargs=* -bar DjangoShowurls call g:DjangoManage('show_urls <args>')
command! -nargs=* -bar DjangoSqldiff call g:DjangoManage('sqldiff <args>')


function! s:GetCurrentProject()
  return g:django_projects[g:django_current_project]
endfunction

function! s:ProjectExists(...)
  if a:0 == 1
    let name = a:1
  else
    let name = g:django_current_project
  endif
  if exists('g:django_projects[name]')
    return 1
  else
    echohl WarningMsg
    if name != ""
      echo 'No django project called ' . name
    else
      echo 'No django project selected'
    endif
    echohl None
    return 0
  endif
endfunction

function! s:PythonPathAdd(path)
  if !has('python')
    return
  endif
  for path in s:python_paths
    if a:path == path
      return
    endif
  endfor
  exe "python import sys"
  exe "python sys.path.insert(0, '" . a:path . "')"
  let s:python_paths += [a:path]
endfunction

function! s:PythonPathRemove(path)
  if !has('python')
    return
  endif
  for path in s:python_paths
    if a:path == path
      exe "python import sys"
      exe "python sys.path.remove('" . a:path . "')"
      let s:python_paths = remove(s:python_paths, a:path)
      return
    endif
  endfor
endfunction

function! g:DjangoInstall(name, project_root, settings, manage_file, paths, cd)
  " name: Project name
  " project_root: Directory of the django project, must end with / or must be
  " empty
  " settings: Name of the settings module, the DJANGO_SETTINGS_MODULE env
  " variable will be set to this value
  " manage_file: file name of the manage.py file, if it is a relative path it
  " will be prepended with project_root
  " paths: list of paths that will be added to the python path. If a path is
  " not absolute it will be prepended with project_root
  if exists('g:django_projects[a:name]')
    echohl WarningMsg
    echo "Already a project registered called " . a:name . ". Use g:DjangoUninstall('" . a:name . "') to uninstall the project."
    echohl None
    return
  endif
  let p = {}
  let p['settings'] = a:settings
  let project_root = a:project_root

  let manage_file = a:manage_file
  if manage_file[0] != '/'
    let manage_file = project_root . manage_file
  endif
  let paths = []
  for path in a:paths
    if path == '.'
      let paths += [project_root]
    elseif path[0] != '/'
      let paths += [project_root . path]
    else
      let paths += [path]
    endif
  endfor
  let cd = a:cd
  if cd == '.'
    let cd = project_root
  elseif cd == ""
    let cd = ""
  elseif cd[0] != '/'
    let cd = project_root . cd
  endif
  let p['manage_file'] = manage_file
  let p['paths'] = paths
  let p['project_root'] = project_root
  let p['cd'] = cd
  let g:django_projects[a:name] = p
endfunction

function! g:DjangoUninstall(name)
  if exists('g:django_projects[a:name]')
    unlet g:django_projects[a:name]
    echo "Django project '" . a:name . "' uninstalled"
  else
    echo "No such Django project: " . a:name
  endif
endfunction



function! g:DjangoInit(name)
  let g:django_current_project = a:name
  if s:ProjectExists(a:name) == 0
    return
  endif
  let p = g:django_projects[a:name]
  let $DJANGO_SETTINGS_MODULE = p["settings"]
  " change directory
  if p["cd"] != ""
    exe "cd " . p["cd"]
  endif
  " set paths
  for path in p["paths"]
    call s:PythonPathAdd(path)
  endfor
endfunction

function! g:DjangoUninit()
  if !exists('g:django_current_project')
    return
  endif
  if !exists('g:django_projects[g:django_current_project]')
    return
  endif
  let p = s:GetCurrentProject()
  for path in p['paths']
    call s:PythonPathRemove(path)
  endfor
endfunction



function! g:DjangoManage(arguments)
  if !s:ProjectExists()
    return
  endif
  let p = s:GetCurrentProject()
  exe "!python " . p['manage_file'] . " " . a:arguments
endfunction

function! g:DjangoTerminalManage(arguments)
  if !s:ProjectExists()
    return
  endif
  let p = s:GetCurrentProject()
  exe "!" . g:django_terminal_program . " \"python " . p['manage_file'] . " " . a:arguments . "\" &"
endfunction
