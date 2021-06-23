#!/bin/sh

git filter-branch -f --env-filter '

OLD_EMAIL=""
CORRECT_NAME="nguyennhat2711"
CORRECT_EMAIL="ngeyennhat2711@outlook.com"


    export GIT_COMMITTER_NAME="$CORRECT_NAME"
    export GIT_COMMITTER_EMAIL="$CORRECT_EMAIL"

    export GIT_AUTHOR_NAME="$CORRECT_NAME"
    export GIT_AUTHOR_EMAIL="$CORRECT_EMAIL"

' --tag-name-filter cat -- --branches --tags
