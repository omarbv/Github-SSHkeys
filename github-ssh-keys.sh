#!/bin/bash
# Script for Mac OS X :)
# Example: ./github-ssh-keys.sh https://github.com/rails

script_name=$(basename "$0")
url=$1
project=""
users=""
page=1

cleaning()
{
    find . -type f -not -name '*.sh' | xargs rm
}

get_project_name()
{
    project=$(echo $url | cut -d/ -f4)
}

check_url()
{
    local valid_url_regexp
    readonly valid_url_regexp='(https?)://github.com/[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]'

    if ! [[ $url =~ $valid_url_regexp ]]
    then
        echo "Error: The URL provided is not valid."
        usage
    fi
}

check_valid()
{
    local string1
    readonly string1="Joined on"
    if curl -s "$url" | grep -q "$string1"
    then
        echo "Error: The URL provided is not a valid Github project."
        usage
    fi
}

check_404() 
{
    local string2
    readonly string2='{"error":"Not Found"}'
    if curl -s "$url" | grep -q "$string2"
    then
       echo "Error: The URL provided is not a valid Github project."
       usage
    fi
}

get_users_per_page()
{
    curl -s https://github.com/orgs/$project/people?page=$page|grep member-link|cut -d'"' -f2|cut -d'/' -f2
}


check_next_page()
{
    curl -s https://github.com/orgs/$project/people?page=$page|grep "This organization has no public members." > /dev/null
}

next_page()
{
    page=$((page+1))
}

get_users_for_all_pages_per_project()
{
    local ret

    check_next_page
    readonly ret=$?

    get_users_per_page
    next_page

    if [ "$ret" -eq 0 ]
    then
        return
    else
        get_users_for_all_pages_per_project
    fi
}

split_keys_from_user()
{
    local user
    readonly user=$1

    curl -s https://github.com/$user.keys > tmp
    split -l 1 tmp

    n=0
    for file in xa*
        do mv -f "${file}" "${n}" 2>/dev/null; ((n++))
    done
}

print_user()
{
    local user
    readonly user=$1

    echo "=== $user ==="
}

print_keys_from_user()
{
    if test -f "0";
    then
        ssh-keygen -E md5 -lf 0 | cut -d' ' -f1,2,4 > tmp_2
        crypto=`cat tmp_2 | cut -d" " -f1`

        if [[ "$crypto" -lt "2048 " ]]
        then
            echo "`cat tmp_2` WEAK"
        else
            cat tmp_2
        fi
    else
        echo "Sorry!! No key available for this user."
    fi

    let key=1
    let END=100 #Maximum number of keys shown by user

    while ((i<=END)) && [ -f $key ]
    do
        ssh-keygen -E md5 -lf $key | cut -d' ' -f1,2,4 > tmp_2
        crypto=`cat tmp_2 | cut -d" " -f1`
        if [[ "$crypto" -lt "2048 " ]]
        then
            echo "`cat tmp_2` WEAK"
        else
            cat tmp_2
        fi
        let key++
    done

    echo ""
}

usage()
{
    echo ""
    echo "  Usage:"
    echo "  ./$script_name <url>"
    echo ""
    echo "  Where:"
    echo "  <url> is an address like this: https://github.com/<project>"
    echo ""
    exit
}

main()
{
    if [[ $# != 1 ]]; then
        echo "Error: invalid number of arguments"
        usage
    fi

    check_url 
    check_valid 
    check_404
    get_project_name 
    all_users=$(get_users_for_all_pages_per_project)

    for user in $all_users
    do
        print_user $user
        split_keys_from_user $user
        print_keys_from_user
        cleaning
    done
}

main "$@"
