#!/bin/sh

update () {
    rm CMSP-dot$1.xml
    wget --no-check-certificate \
    http://www2.camara.sp.gov.br/Dados_abertos/CMSP-dot$1.xml
#    perl sp_camera_to_redis.pl $1 CMSP-dot$1.xml
    perl sp_camera_to_redis.pl $1
}

update_pag () {
    rm CMSP-pag2010-2012.xml
    wget --no-check-certificate \
    "http://ws.giap.com.br/WSFinanceiro/FinanceiroServlet?tipoInformacao=PAG&dtInicio=01/01/2010&dtFinal=31/12/2012" \
    -O CMSP-pag2010-2012.xml
}

update_pag
update 2012

