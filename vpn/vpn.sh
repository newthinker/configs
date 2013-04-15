#!/bin/sh

#########################################################
PEM="vpn.pem"
IP="*.*.*.*"
USER="<user_name>"
HOST="<host_name>"

#########################################################
function fn_yum_install () {

  PKG=$1

  echo -n ">Check package ${PKG}..."
  if [ `rpm -qa | grep ^${PKG}-[0-9] | wc -l` -eq 0 ]
  then
    #need install
    echo -e "\tnot installed,now will install ${PKG} ${E_TAG}"
    yum -y install ${PKG}
    if [  $? -ne 0 ]
    then
      echo
      echo "yum install package ${PKG} error"
      echo "Quit for fn_yum_install ${PKG}"
      echo
      exit 1
    else
      echo -e "\t Install ${PKG} succeed ${E_TAG}"
    fi
  else
    echo -e "\tinstalled ${E_TAG}"
    rpm -qa | grep ^${PKG}[0-9]
  fi
}

function fn_vpn_support() {
#invoke when VPN_SUPPORT is 1

  if [ -d ~/.ssh -a -f ~/.ssh/config -a -f ~/.ssh/${PEM} ]
  then
     echo ">vpn config OK"
     if [ `ps -ef | grep "ssh ${HOST}" | grep -v grep | wc -l` -ne 1 ]
     then
       echo "please run 'ssh aws' in another terminal"
       exit 1
     fi
  else
    echo ">vpn not config,generate vpn config now..."

    mkdir -p ~/.ssh
    if [ ! -d ~/.ssh ]
    then
      echo "~/.ssh can not be created,create vpn config failed!"
      echo 2
    fi
    cd ~/.ssh

    #gen config
    echo "Host ${HOST}
HostName ${IP}
User ${USER}
IdentityFile ~/.ssh/${PEM}
CompressionLevel 6
DynamicForward localhost:3128" > config

   #generate pem file
   echo "-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEArIjkR+Rz6gxRSdChNB62enJH9MF92xfgtuf2ENZLmJdsUuhiwKgBdjPO/h9r
tgBa4zz02jNOsuk3ecHtdhejn+PJCH5Hi+gJK90oXUhr7D6ckUR2iy1VlDHnb1paY1INwM1aAEWc
vyyPTrh/v9BKuJEZfdlPuVpRNT9sXraZlzgmqIJEsQjCmMR70VfRGKekWkoYHn0J3/sLtJ/bhnS4
C3nywh6JCNOOTYeWb0u1CySzw+I8MtjP7Rq28ff6EUYWdDcM67T+sqJsPpL4AeLRklEuv3bafO/V
hQ86gApw9rXaD/mi3tnaOp4YfmibFd3MAmfileqXs4G1sR0TtIv1/wIDAQABAoIBAQCAzIB+GtFd
e2yDijeNTRA0QHPvBzMJB749TNSopREyDHhVPB3cbI8KyopPsu0ZpRI0aSDwczTg4rEDN/4pFmST
y9wbdwm6K7INCMBFQvcuGV+QImfMZj9orghzXCP12R9jOulhIpZtMLqarajQbJIbTlaVWFDnscDF
217vJalq9Mo+jXhKuhePBKoVbT7O5Rk5x5h7f5WWCAWrwgZzOTzrHIUKNcdWp8k4LSPV5J/uB5bs
RlwQpcIItnOrKCKSy97V0Bbg2XiauJzrrDLbjmvQVqbcd9yvmctytz/O1dVQG121XG4Zplm0K9Ww
T6iLhPlSnjpzNXPXnbXJEGl+DheBAoGBANI0K4/7NSknz8nW9tI5KQ+2h2wM2nFFCNdOZk980wWM
JIb6YEh8B2cPS7g5r5BIjDMdxEDTVM9f4wi/F0FIiVboCW/rIJUhz5LGnUma5aW/FVwhOIExsjdq
/jaBQkpCjWjOsW6vProJgHsPNfxbSrGLNa1s+Fg4RAqjqdjWU8LxAoGBANIfyAIhgEjKXpOTfQqH
0UFSUNyRxVW+uo1gLXAMD6o6YZ9mvKHlJj0NhDQXjSs2uF/ku/aFvvhVf4hZHmUMDsQaAiMel5YQ
EwDLnNw4ZCGYvb324/xzCZGP0+1r3NRlKbsH6+dMMc6nmEHtAOKG2PxT856/FKmdLpHr6HgDimfv
AoGBAIK28of8nRhUq4BGbwJXjVM6HIhyjbx2Q4MwO6seYlNGzMgrFoi8qBXMizeql6RPmO+IiSwO
vuSeKh6cRifQpacncAbq3j4e4mfRnqnQ6xHg+7Vo6yxb7QlNPXxDcSegrzMHpYrA627gzca4tMeT
NaWmfeC0rNKfWqCLGem/jiLhAoGAVKgBSPp+WNVPrV1qr2dw40Rq17LTMmyZdIQfSllRpl/HHRWj
Qga0lTxw2xvyAEsXlWruX7Aa9Kpdq21cVZG6ET/5RHT61ba8MUHXfNIrZW3IZFSoHfmrDT5JQAqI
+fmYCoZygMmt93iGW2lFRf7WRTL9oCOUC5IMRTYqfs/OX3kCgYAmLYZ/G1h5UEJfViHD7JN3pp5H
aO0FcNJLWIZD1mfIT/N65GWSx40piL5uJp+vrvUE8j843t0SNOaVgnHiV7v5wKeeifa/ajE9FmWV
/FAPZzg8P+ckfl4JMJqLPMzTF9nWTSE4yjZhWYRE/HUVkgAtw5vYzG9NxF2vu1wvtTy4/w==
-----END RSA PRIVATE KEY-----" > ${PEM}
    chmod 600 ${PEM}
    fn_yum_install tsocks
    echo "server = 127.0.0.1
server_type = 5
server_port = 3128" > /etc/tsocks.conf

    echo "config vpn ok, please run 'ssh ${HOST}' in another terminal"

  fi

}


#######################################
######## main #########################

fn_vpn_support


