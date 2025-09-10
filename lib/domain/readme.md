## 🧩 Camada de Domínio

A camada de domínio do projeto **Denun** foi implementada em Dart/Flutter, representando as principais entidades do sistema de denúncias urbanas.  

### 📌 Usuario
Representa o cidadão, agente ou administrador do sistema.  
- **Atributos**: `idUsuario`, `nome`, `email`, `cpf`, `senhaHash`, `papel`, `emailConfirmado`.  
- **Métodos principais**: getters/setters com validações, `confirmarEmail()`.  
- **Regras de negócio**: garante encapsulamento de dados e validação mínima de email, senha e CPF.  

### 📌 Denuncia
Representa uma denúncia registrada por um usuário.  
- **Atributos**: `idDenuncia`, `titulo`, `descricao`, `dataCriacao`, `endereco`, `localizacao`, `statusAtual`, `prioridade`, `autorId`, `arquivos`.  
- **Métodos principais**: setters com validação, `setStatus()`, `setPrioridade()`, `adicionarArquivo()`.  
- **Regras de negócio**: controla status e prioridade da denúncia, além de associar anexos e autor.  

### 📌 Arquivo
Representa um arquivo anexo a uma denúncia (foto, vídeo ou áudio).  
- **Atributos**: `idArquivo`, `urlArquivo`, `tipo`, `dataUpload`.  
- **Métodos principais**: serialização `toJson()` e `fromJson()`.  
- **Regras de negócio**: mantém apenas metadados do arquivo (o conteúdo bruto é armazenado no Firebase Storage).  

### 📌 Localizacao
Value Object que representa a geolocalização de uma denúncia.  
- **Atributos**: `latitude`, `longitude`.  
- **Métodos principais**: serialização `toJson()` e `fromJson()`.  
- **Regras de negócio**: usado para integração futura com serviços de mapa (Google Maps).  

---
