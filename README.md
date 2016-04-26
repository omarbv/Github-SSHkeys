# Github-SSHkeys
GitHub exposes public ssh keys for its users: https://changelog.com/github-exposes-public-ssh-keys-for-its-users/

With this script, you can list the public SSH keys for organisation members in MD5 format.
Those "vulnerable keys", shorter than 2048 bits will be identified with the tag WEAK in the output.

Author: @omarbv

Platform: Bash 3, OS X

## Usage

     $ ./github-ssh-keys.sh https://github.com/<organisation>
