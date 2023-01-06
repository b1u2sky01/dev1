#!/bin/bash

BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$BRANCH" != "main" ]; then
    echo 'main 브랜치에서만 배포 가능합니다.'
    exit
fi

LATEST_TAG=$(git tag | sort -V | tail -1)
echo "현재 최신 버전의 태그는 $LATEST_TAG 입니다."
echo "생성할 태그명을 입력하세요."
read -p "생성할 태그명 : v" input_tag

git tag -m "v$input_tag" "v$input_tag"
git push --tags
echo "v$input_tag 태그를 생성하였습니다."

exit
