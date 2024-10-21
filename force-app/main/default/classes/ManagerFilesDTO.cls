public class ManagerFilesDTO {
    public class File {
        @AuraEnabled public String nomeDocumento { get; set; }
        @AuraEnabled public String urlDocumento { get; set; }
        @AuraEnabled public String urlDocumentoVisualizador { get; set; }
        @AuraEnabled public String type { get; set; }
        @AuraEnabled public String identificadorRegistro { get; set; }
        @AuraEnabled public String nomeRegistro { get; set; }
        @AuraEnabled public String proprietario { get; set; }
        @AuraEnabled public Double tamanhoArquivo { get; set; }
        @AuraEnabled public String tamanhoArquivoFormatado { get; set; }
        @AuraEnabled public String statusArquivo { get; set; }
        @AuraEnabled public String integrado { get; set; }
        @AuraEnabled public DateTime ultimaModificacao { get; set; }
        @AuraEnabled public String ultimaModificacaoFormatada { get; set; }

        public File(String nomeDocumento, String urlDocumento, String urlDocumentoVisualizador, String type,
        String identificadorRegistro, String nomeRegistro, String proprietario, Double tamanhoArquivo, String statusArquivo,
        DateTime ultimaModificacao) {
            this.nomeDocumento = nomeDocumento;
            this.urlDocumento = urlDocumento;
            this.urlDocumentoVisualizador = urlDocumentoVisualizador;
            this.type = type;
            this.identificadorRegistro = identificadorRegistro;
            this.nomeRegistro = nomeRegistro;
            this.proprietario = proprietario;
            this.tamanhoArquivo = tamanhoArquivo == null ? 0 : tamanhoArquivo;
            this.tamanhoArquivoFormatado = String.valueOf(this.tamanhoArquivo) + ' KB';
            this.statusArquivo = statusArquivo;
            this.integrado = statusArquivo == 'Created' ? 'SIM' : 'NÃO';
            this.ultimaModificacao = ultimaModificacao;
            String dateStr = ultimaModificacao.format();
            this.ultimaModificacaoFormatada = dateStr;
        }
    }
}