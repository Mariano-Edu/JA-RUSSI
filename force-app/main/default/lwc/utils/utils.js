export function formatData(data){
    const partes = data.split('-');
    if (partes.length !== 3) return null;

    const ano = parseInt(partes[0], 10);
    const mes = parseInt(partes[1], 10);
    const dia = parseInt(partes[2], 10);

    if (isNaN(ano) || isNaN(mes) || isNaN(dia)) return null;

    return `${dia}/${mes}/${ano}`;
}

export function formatDataISO(data) {
    const partes = data.split('/');
    if (partes.length !== 3) return null;
    
    const dia = partes[0];
    const mes = partes[1];
    const ano = partes[2];
    
    if (isNaN(dia) || isNaN(mes) || isNaN(ano)) return null;
    
    return `${ano}-${mes}-${dia}`;
}

export function calcularInicioPagamentoSeriePagamentos(serieDePagamentos){
    let mesesParaInicio = serieDePagamentos.InicioPagamento__c != null ? serieDePagamentos.InicioPagamento__c : 0;


    let dataInicio = new Date();

    dataInicio.setMonth(dataInicio.getMonth() + mesesParaInicio);

    let day = String(dataInicio.getDate()).padStart(2, '0');
    let month = String(dataInicio.getMonth() + 1).padStart(2, '0'); 
    let year = dataInicio.getFullYear();
    
    let dataInicioFormatada = `${day}/${month}/${year}`;


    return dataInicioFormatada;
}

export function calcularPorcParcelaSeriePagamento(porcValorTotal, qtdParcela){
    return porcValorTotal / qtdParcela;
}

export function calcularValorParcelaSeriePagamento(porcParcela, valorNominal){
    return porcParcela / 100 * valorNominal;
}

export function calcularValorTotalSeriePagamento(porcTotal, valorNominal){
    return porcTotal / 100 * valorNominal;
}

export function calcularDiferencaMeses(data) {

    let partes = data.split("/")
    let dataIso = `${partes[2]}-${partes[1]}-${partes[0]}`

    let dataObjetoFinal = new Date(dataIso);
    let dataAtual = new Date();


    let diferencaMilissegundos = dataObjetoFinal.getTime() - dataAtual.getTime();


    let diferencaDias = Math.floor(diferencaMilissegundos / (1000 * 60 * 60 * 24));

    let diferencaMeses = Math.floor(diferencaDias / 30);

    

    return diferencaMeses;
}

export function showNotification(title, message, variant) {
    this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
}