#!/usr/bin/env bash

# `o` 打开目录
function o()
{
    if [ $# -eq 0 ]; then
        local opath=.
    else
        local opath="$@"
    fi

    # Windows
    command -v cygstart > /dev/null && cygstart $opath && return
    # Windows
    command -v cmd > /dev/null && cmd /c start $opath && return
    # Centos
    command -v nautilus > /dev/null && nautilus --browser $opath && return
    # Linux Mint Cinnamon
    command -v nemo > /dev/null && nemo $opath && return
    # Mac
    command -v open > /dev/null && open $opath && return
}

# print the header (the first line of input)
# and then run the specified command on the body (the rest of the input)
# use it in a pipeline, e.g. ps | body grep somepattern
# see http://unix.stackexchange.com/a/11859/47774
body() {
    IFS= read -r header
    printf '%s\n' "$header"
    "$@"
}

# 显示exe文件包含的dll
# objdump a.exe -p|grep DLL\ [^:]\*|sed 's/^\s*//g'
# objdump rex_pcre.dll -p|sed 's/^\s*DLL[^:：]*[:：]\s*\(.*\)/\t\1/p' -n
incdll()
{
    for i in "$@"
    do
        if [ -f "$i" ]
        then
            echo $i: included
            # objdump $i -p|grep DLL\ [^:]:|sed 's/^.*:/\t/g'
            objdump $i -p|sed 's/^\s*DLL[^:：]*[:：]\s*\(.*\)/\t\1/p' -n
            echo 
        else
            echo incdll:\'$i\' file not exists or permission deny
        fi
    done
}


# Create a new directory and enter it
function mkd()
{
    mkdir -p "$@" && cd "$@"
}

# 输出颜色
colorname()
{
    echo "colorname:"
    echo -e "30 \e[00;30m Balck \e[01;30m Dark Gray \e[00m"
    echo -e "31 \e[00;31m Red \e[01;31m Light Red \e[00m"
    echo -e "32 \e[00;32m Green \e[01;32m Light Green \e[00m"
    echo -e "33 \e[00;33m Yellow \e[01;33m Yellow \e[00m"
    echo -e "34 \e[00;34m Blue \e[01;34m Light Blue \e[00m"
    echo -e "35 \e[00;35m Purple \e[01;35m Light Purple \e[00m"
    echo -e "36 \e[00;36m Cyan \e[01;36m Light Cyan \e[00m"
    echo -e "37 \e[00;37m Light Gray \e[01;37m White \e[00m"
    echo -e "\e[00m"
}


# Determine size of a file or total size of a directory
function fs()
{
    if du -b /dev/null > /dev/null 2>&1; then
        local arg=-sbh
    else
        local arg=-sh
    fi
    if [[ -n "$@" ]]; then
        du $arg -- "$@"
    else
        du $arg .[^.]* *
    fi
}

# Use Git’s colored diff when available
hash git &>/dev/null
if [ $? -eq 0 ]; then
    function diff() {
    git diff --no-index --color-words "$@"
}
fi

# Create a data URL from a file
function dataurl() 
{
    local mimeType=$(file -b --mime-type "$1")
    if [[ $mimeType == text/* ]]; then
        mimeType="${mimeType};charset=utf-8"
    fi
    echo "data:${mimeType};base64,$(openssl base64 -in "$1" | tr -d '\n')"
}

# Create a git.io short URL
function gitio() 
{
    if [ -z "${1}" -o -z "${2}" ]; then
        echo "Usage: \`gitio slug url\`"
        return 1
    fi
    curl -i http://git.io/ -F "url=${2}" -F "code=${1}"
}

# Start a PHP server from a directory, optionally specifying the port
# (Requires PHP 5.4.0+.)
function phpserver() 
{
    local port="${1:-4000}"
    local ip=$(ipconfig getifaddr en1)
    sleep 1 && open "http://${ip}:${port}/" &
    php -S "${ip}:${port}"
}

# Compare original and gzipped file size
function gz()
{
    local origsize=$(wc -c < "$1")
    local gzipsize=$(gzip -c "$1" | wc -c)
    local ratio=$(echo "$gzipsize * 100/ $origsize" | bc -l)
    printf "orig: %d bytes\n" "$origsize"
    printf "gzip: %d bytes (%2.2f%%)\n" "$gzipsize" "$ratio"
}

# Escape UTF-8 characters into their 3-byte format
function escape()
{
    printf "\\\x%s" $(printf "$@" | xxd -p -c1 -u)
    # print a newline unless we’re piping the output to another program
    if [ -t 1 ]; then
        echo # newline
    fi
}

# Decode \x{ABCD}-style Unicode escape sequences
function unidecode() 
{
    perl -e "binmode(STDOUT, ':utf8'); print \"$@\""
    # print a newline unless we’re piping the output to another program
    if [ -t 1 ]; then
        echo # newline
    fi
}

# Get a character’s Unicode code point
function codepoint() 
{
    perl -e "use utf8; print sprintf('U+%04X', ord(\"$@\"))"
    # print a newline unless we’re piping the output to another program
    if [ -t 1 ]; then
        echo # newline
    fi
}



# Install Grunt plugins and add them as `devDependencies` to `package.json`
# Usage: `gi contrib-watch contrib-uglify zopfli`
function gi() 
{
    local IFS=,
    eval npm install --save-dev grunt-{"$*"}
}

# `v` with no arguments opens the current directory in Vim, otherwise opens the
# given location
function v() 
{
    if [ $# -eq 0 ]; then
        vim .
    else
        vim "$@"
    fi
}

# `np` with an optional argument `patch`/`minor`/`major`/`<version>`
# defaults to `patch`
function np() 
{
    git pull --rebase && \
        npm install && \
        npm test && \
        npm version ${1:=patch} && \
        npm publish && \
        git push origin master && \
        git push origin master --tags
}

# `tre` is a shorthand for `tree` with hidden files and color enabled, ignoring
# the `.git` directory, listing directories first. The output gets piped into
# `less` with options to preserve color and line numbers, unless the output is
# small enough for one screen.
function tre() 
{
    tree -aC -I '.git|node_modules|bower_components' --dirsfirst "$@" | less -FRNX
}

# Instant Server for Current Directory
# https://gist.github.com/JeffreyWay/1525217
function server()
{
	local port=${1:-8000}
	iscmd python && {
		(sleep 1 && o "http://localhost:${port}/")&
		python -m SimpleHTTPServer ${port}
	}

	iscmd npm && (npm -g ls --depth=0 | grep server@) >/dev/null && {
		# Use npm server
		(sleep 1 && o "http://localhost:${port}/")&
		server ${port}
	}

	iscmd php && {
		(sleep 1 && o "http://localhost:${port}/")&
		php -S localhost:${port}
	}
}
# vim: set foldmarker={{,}} foldlevel=0 foldmethod=marker:
