# github-ssh-keys
Script used to list the public SSH keys for organisation members in MD5 format.
"Vulnerable keys", shorter than 2048 bits will be identified with the tag WEAK in the output.

Author: @omarbv

Platform: Bash 3, OS X

## Usage

     $ ./github-ssh-keys.sh https://github.com/<organisation>
