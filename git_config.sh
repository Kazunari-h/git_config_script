#!/bin/bash

echo "メールアドレスを入力してください: "
read email

echo "ユーザー名を入力してください(githubアカウント名): "
read username

echo "github access tokenを入力してください: "
read GITHUB_TOKEN

git config --global user.name $username
git config --global user.username $username
git config --global user.email $email
git config --global color.diff auto
git config --global color.status auto
git config --global color.branch auto
git config --global push.default simple
git config --global core.quotepath false

if [ -e ~/.ssh/ ]; then
    # 存在する場合
else
    # 存在しない場合
    mkdir ~/.ssh
    touch ~/.ssh/config
    echo "... created ssh folder"
    echo "... created ssh config file"
fi

cd ~/.ssh

if [ -e ~/.ssh/github_rsa ]; then
    # 存在する場合
else
    # 存在しない場合
    ssh-keygen -t rsa -C $email -f github_rsa
    chmod 600 id_rsa
    echo "... created ssh key"
fi
sshkey=$(cat ~/.ssh/github_rsa.pub)
curl -v -H "Authorization: token $GITHUB_TOKEN" -H "Content-Type: application/json" -X POST -d '{ "title": "config_generator", "key": "'$sshkey'" }' https://api.github.com/user/keys

if [ -e ~/.ssh/config ]; then
    # 存在する場合
else
    # 存在しない場合
    touch ~/.ssh/config
    echo "... created ssh config file"
fi
chmod +x ~/.ssh/config

cat << EOT >> ~/.ssh/config
Host github
    HostName github.com
    IdentityFile ~/.ssh/github_rsa
    User git
EOT

echo "上記の設定後 ssh -T git@github.com を実行して、接続を確認できれば完了です。"