public class DocuSignObjects {
    public class Envelope {
        public Envelope() {
            recipients = new DocuSignObjects.Recipient();
            documents = new List<DocuSignObjects.Document>();
            enforceSignerVisibility = 'true';
        }

        public String status { get; set; }
        public String emailSubject { get; set; }
        public String emailBlurb { get; set; }
        public String enforceSignerVisibility { get; set; }
        public DocuSignObjects.Recipient recipients { get; set; }
        public List<DocuSignObjects.Document> documents { get; set; }
    }

    public class Document {
        public Integer documentId { get; set; }
        public String name { get; set; }
        public String documentBase64 { get; set; }
        public String fileExtension { get; set; }
        public Id contentDocumentId { get; set; }

        public Document(){}

        public Document(ContentVersion content, Integer idArquivo){
            this.documentBase64 = EncodingUtil.base64Encode(content.VersionData);
            this.fileExtension = content.PathOnClient.substringAfter('.');
            this.name = content.Title;
            this.documentId = idArquivo;
            //this.contentDocumentId = content.ContentDocumentId;
        }

        public Document(ContentDocumentLink link, Integer idArquivo){
            this.documentBase64 = EncodingUtil.base64Encode(link.ContentDocument.LatestPublishedVersion.VersionData);
            this.fileExtension = link.ContentDocument.LatestPublishedVersion.FileExtension;
            this.name = link.ContentDocument.LatestPublishedVersion.Title;
            this.documentId = idArquivo;
            this.contentDocumentId = link.ContentDocument.LatestPublishedVersion.ContentDocumentId;
        }

        public Document(Id contentDocumentId, Integer idArquivo){
            this.documentId = idArquivo;
            this.contentDocumentId = contentDocumentId;
        }
    }

    public class Recipient {
        public List<DocuSignObjects.Signer> signers { get; set; }
        public List<DocuSignObjects.Signer> inPersonSigners { get; set; }
        public List<DocuSignObjects.Signer> carbonCopies { get; set; }
        public List<DocuSignObjects.Signer> certifiedDeliveries { get; set; }
        public List<DocuSignObjects.Signer> intermediaries { get; set; }
        public List<DocuSignObjects.Signer> editor { get; set; }
        public List<DocuSignObjects.Signer> agents { get; set; }
        public List<DocuSignObjects.Signer> seal { get; set; }
        public List<DocuSignObjects.Signer> witnesses { get; set; }

        public Recipient() {
            signers = new List<DocuSignObjects.Signer>();
            inPersonSigners = new List<DocuSignObjects.Signer>();
            carbonCopies = new List<DocuSignObjects.Signer>();
            certifiedDeliveries = new List<DocuSignObjects.Signer>();
            intermediaries = new List<DocuSignObjects.Signer>();
            editor = new List<DocuSignObjects.Signer>();
            agents = new List<DocuSignObjects.Signer>();
            seal = new List<DocuSignObjects.Signer>();
            witnesses = new List<DocuSignObjects.Signer>();
        }
    }

    public class Signer {
        public Signer() {
            tabs = new DocuSignObjects.Tab();
            excludedDocuments = new List<Integer>();
            idsDocumentos = new Set<Id>();
            tagsRubricas = new Set<String>();
        }

        public String email { get; set; }
        public String name { get; set; }
        public String recipientId { get; set; }
        public String routingOrder { get; set; }
        public String signingGroupId { get; set; }
        public DocuSignObjects.Tab tabs { get; set; }
        public List<Integer> excludedDocuments { get; set; }
        public transient String tipoSignatario { get; set; }
        public transient Set<Id> idsDocumentos { get; set; }
        public transient Set<String> tagsRubricas { get; set; }
        public List<String> customFields { get; set; }

        public DocuSignObjects.RecipientEmailNotification emailNotification { get; set; }
    }

    public class Tab {
        public Tab() {
            signHereTabs = new List<DocuSignObjects.SignHereTab>();
            initialHereTabs = new List<DocuSignObjects.InitialHereTab>();
            textTabs = new List<DocuSignObjects.TextTab>();
            dateSignedTabs = new List<DocuSignObjects.DateSignedTab>();
            fullNameTabs = new List<DocuSignObjects.FullNameTab>();
        }
        public List<DocuSignObjects.SignHereTab> signHereTabs { get; set; }
        public List<DocuSignObjects.InitialHereTab> initialHereTabs { get; set; }
        public List<DocuSignObjects.TextTab> textTabs { get; set; }
        public List<DocuSignObjects.DateSignedTab> dateSignedTabs { get; set; }
        public List<DocuSignObjects.FullNameTab> fullNameTabs { get; set; }

    }

    public class SignHereTab {
        public String name { get; set; }
        public String tabId { get; set; }
        public String optional { get; set; }
        public String documentId { get; set; }
        public Integer recipientId { get; set; }
        public String pageNumber { get; set; }

        //Preencher caso o posicionamento seja fixo
        public Integer xPosition { get; set; } //usar numeros
        public Integer yPosition { get; set; } //usar numeros

        //Preencher se quiser ancorar em um determinado texto
        public String anchorString { get; set; }
        public Integer anchorXOffset { get; set; } //usar numeros
        public Integer anchorYOffset { get; set; } //usar numeros
        public String anchorIgnoreIfNotPresent { get; set; } //usar true ou false
        public String anchorUnits { get; set; } //user Pixels, Mms, Cms ou Inches
    }

    public class FullNameTab {
        public String name { get; set; }
        public String tabId { get; set; }
        public String optional { get; set; }
        public String documentId { get; set; }
        public Integer recipientId { get; set; }
        public String pageNumber { get; set; }

        //Preencher caso o posicionamento seja fixo
        public Integer xPosition { get; set; } //usar numeros
        public Integer yPosition { get; set; } //usar numeros

        //Preencher se quiser ancorar em um determinado texto
        public String anchorString { get; set; }
        public Integer anchorXOffset { get; set; } //usar numeros
        public Integer anchorYOffset { get; set; } //usar numeros
        public String anchorIgnoreIfNotPresent { get; set; } //usar true ou false
        public String anchorUnits { get; set; } //user Pixels, Mms, Cms ou Inches
    }

    public class InitialHereTab {
        public Integer recipientId { get; set; }
        public String name { get; set; }
        public String tabId { get; set; }
        public String optional { get; set; }
        public String anchorIgnoreIfNotPresent { get; set; } //usar true ou false
        public Integer documentId { get; set; }
        public Integer pageNumber { get; set; }

        //Preencher caso o posicionamento seja fixo
        public String xPosition { get; set; } //usar numeros
        public String yPosition { get; set; } //usar numeros

        //Preencher se quiser ancorar em um determinado texto
        public String anchorString { get; set; }
        public Integer anchorXOffset { get; set; } //usar numeros
        public Integer anchorYOffset { get; set; } //usar numeros
        public String anchorUnits { get; set; } //user Pixels, Mms, Cms ou Inches
    }

    public class TextTab {
        public Integer recipientId { get; set; }
        public String value { get; set; }
        public String tabLabel { get; set; }
        public Boolean required { get; set; }
        public Boolean locked { get; set; }
        public String anchorIgnoreIfNotPresent { get; set; } //usar true ou false
        public Integer documentId { get; set; }
        public Integer pageNumber { get; set; }

        //Preencher se quiser ancorar em um determinado texto
        public String anchorString { get; set; }
        public Integer anchorXOffset { get; set; } //usar numeros
        public Integer anchorYOffset { get; set; } //usar numeros
        public String anchorUnits { get; set; } //user Pixels, Mms, Cms ou Inches
    }

    public class DateSignedTab {
        public Integer recipientId { get; set; }
        public String value { get; set; }
        public String tabLabel { get; set; }
        public Boolean required { get; set; }
        public Boolean locked { get; set; }
        public String anchorIgnoreIfNotPresent { get; set; } //usar true ou false
        public Integer documentId { get; set; }
        public Integer pageNumber { get; set; }

        //Preencher se quiser ancorar em um determinado texto
        public String anchorString { get; set; }
        public Integer anchorXOffset { get; set; } //usar numeros
        public Integer anchorYOffset { get; set; } //usar numeros
        public String anchorUnits { get; set; } //user Pixels, Mms, Cms ou Inches
    }
    public class RecipientEmailNotification {
        public String emailSubject { get; set; }
        public String emailBody { get; set; }
    }
}