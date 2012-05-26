
var antibiotics = ["planejado", "executado"];
var bacteria = [];

$(document).ready(function(){

    $.ajax({
    url: '/eficiencia/sp/camaramunicipal/2012/data/modalidades',
    success: function(data) {
        bacteria = data.orcamento;
    }
    });

});



