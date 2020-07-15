# Deploy

## Certificate Authentication 設定

- Control Node 安裝 ansible & pywinrm

```cmd
sudo apt install python3
sudo apt install python3-pip
pip3 install ansible
pip3 install "pywinrm>=0.3.0"
```

- Control Node 使用 OPENSSH 指令產生 certificate

```cmd
$ USERNAME="username"    //username請填要登入managed node的使用者名稱
$ cat > openssl.conf << EOL
distinguished_name = req_distinguished_name
[req_distinguished_name]
[v3_req_client]
extendedKeyUsage = clientAuth
subjectAltName = otherName:1.3.6.1.4.1.311.20.2.3;UTF8:$USERNAME@localhost
EOL
$ export OPENSSL_CONF=openssl.conf
$ openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -out cert.pem -outform PEM -keyout cert_key.pem -subj "/CN=$USERNAME" -extensions v3_req_client
$ rm openssl.conf
```

## 設定 Managed Node Winrm

- Copy ConfigureRemotingCert 檔案至 Windows Managed Node, 修改 username, password 後執行
