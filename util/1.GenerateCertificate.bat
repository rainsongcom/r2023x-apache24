@echo off

set ROOT=%~dp0

rem Apache Path
set ApachePath=%ROOT:~0,-6%

rem OutputPath
set OutputPath=%ApachePath%\conf\ssl

rem RootCA file name
set RootCAName=rsrootca

rem Domain Certificate file name
set DomainName=star.r2023x.rs.com

rem Domain Name
set Domain=*.r2023x.rs.com

rem ###################################################################################
rem SSL
set OPENSSL_CONF=%ApachePath%\conf\openssl.cnf
set OpenSslCommand=%ApachePath%\bin\openssl.exe

rem Generate RootCA Certificate
set RootCAKey=%OutputPath%\%RootCAName%.key
set RootCACertificate=%OutputPath%\%RootCAName%.crt
set RootCASerial=%OutputPath%\%RootCAName%.srl

if exist %RootCACertificate% (
    echo RootCA file exist. Skip RootCA file generation.
) else (
    "%OpenSSLCommand%" genrsa -des3 -out "%RootCAKey%" -passout pass:qwer1234!@#$ 3650
    "%OpenSSLCommand%" req -new -x509 -sha256 -nodes -days 3650 -key "%RootCAKey%" -out "%RootCACertificate%" -passin pass:qwer1234!@#$ -subj "/C=KO/ST=Seoul/L=Gangnam/O=DSK/OU=BTCC/CN=%RootCAName%"
)

rem Generate Domain Certificate
set DomainKey=%OutputPath%\%DomainName%.key
set DomainCertifcateRequest=%OutputPath%\%DomainName%.csr
set DomainCertifcateExtension=%OutputPath%\%DomainName%.ext
set DomainCertifcate=%OutputPath%\%DomainName%.crt
set DomainPkcs12Keystore=%OutputPath%\%DomainName%.p12

echo authorityKeyIdentifier=keyid,issuer > "%DomainCertifcateExtension%"
echo basicConstraints=CA:FALSE >> "%DomainCertifcateExtension%"
echo keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment >> "%DomainCertifcateExtension%"
echo subjectAltName = @alt_names >> "%DomainCertifcateExtension%"
echo [alt_names] >> "%DomainCertifcateExtension%"
echo DNS.1=%Domain% >> "%DomainCertifcateExtension%"

if exist %DomainCertifcate% (
    echo DomainCertifcate file exist. Skip DomainCertifcate file generation.
) else (
    "%OpenSSLCommand%" genrsa -out "%DomainKey%" 2048
    "%OpenSSLCommand%" req -new -sha256 -key "%DomainKey%" -out "%DomainCertifcateRequest%" -subj "/C=KO/ST=Seoul/L=Gangnam/O=DSK/OU=BTCC/CN=%Domain%"
    "%OpenSSLCommand%" x509 -req -sha256 -days 3650 -in "%DomainCertifcateRequest%" -out "%DomainCertifcate%" -extfile "%DomainCertifcateExtension%" -CA "%RootCACertificate%" -CAkey "%RootCAKey%" -passin pass:qwer1234!@#$ -CAcreateserial -CAserial "%RootCASerial%"
)

if exist %DomainPkcs12Keystore% (
    echo DomainPkcs12Keystore file exist. Skip DomainPkcs12Keystore file generation.
) else (
    "%OpenSSLCommand%" pkcs12 -export -in "%DomainCertifcate%" -inkey "%DomainKey%" -out "%DomainPkcs12Keystore%" -name %DomainName%
)

echo Done.