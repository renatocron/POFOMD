#!/bin/sh


update_sp () {
    rm DespesasDownload.zip

    wget --no-check-certificate \
    "https://www.fazenda.sp.gov.br/SigeoLei131/Paginas/DownloadReceitas.aspx?flag=2&ano=$1"\
    -O DespesasDownload.zip

    unzip DespesasDownload.zip
    perl sp_to_redis.pl $1 despesa$1.csv
}

#update_sp 2010
#update_sp 2011
update_sp 2012

