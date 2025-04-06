# Deploy de Aplicação no Kubernetes com Integração em Pipeline CI/CD
!
**🎯 Objetivo**:

O objetivo deste projeto é implementar uma solução completa para o deploy de uma aplicação no Kubernetes, utilizando uma pipeline CI/CD que automatize todo o processo de:

- ✅ Build da imagem Docker
- 📦 Publicação da imagem no Docker Hub
- 🧪 Execução de testes
- 🚀 Deploy automatizado da aplicação em cloud

## 🧰 Requisitos

- 💻 Uma aplicação base (neste projeto foi utilizada a Fake Shop do @fabricioveronez, já que o foco aqui não é o desenvolvimento da aplicação)
- 🐳 Docker instalado para criação e gerenciamento das imagens
- ☸️ kubectl para interação com o cluster Kubernetes
- ☁️ Um provedor de cloud de sua preferência (neste projeto utilizamos a DigitalOcean por ser mais econômica)
- ⚙️ Uma ferramenta de CI/CD (neste projeto usamos o GitHub Actions para orquestrar o processo automatizado)

## 📦 Documentação

**1️⃣ Análise da aplicação e criação do Dockerfile**

O primeiro passo é analisar a aplicação para entender como ela funciona, e assim criar um Dockerfile funcional. Em alguns projetos o Dockerfile já é fornecido pelo time de desenvolvimento, mas é essencial saber construir e revisar esse arquivo, pois ele pode conter erros ou precisar de atualizações futuras.

[1](./print/2025-04-05_13-57.png)

``` FROM python:3.11.0 ```
Define a imagem base que será usada. Neste caso, é uma imagem oficial do Python na versão 3.11.0.

```EXPOSE 5000```
Informa que a aplicação escuta na porta 5000 (útil para mapeamento de portas, embora não exponha de fato a porta por si só).

```COPY requirements.txt .```
Copia o arquivo requirements.txt (com as dependências Python) para o diretório raiz da imagem.

```RUN python -m pip install -r requirements.txt```
Instala todas as dependências listadas no requirements.txt.

```WORKDIR /app```
Define o diretório de trabalho dentro do container. Tudo a partir daqui será executado dentro de /app.

```COPY . /app```
Copia todos os arquivos do projeto local para o diretório /app dentro do container.

```RUN chmod +x /app/entrypoint.sh```
Garante que o script de entrada (entrypoint.sh) tenha permissão de execução.

```ENV PROMETHEUS_MULTIPROC_DIR=/tmp/metrics```
Define uma variável de ambiente necessária para o funcionamento do Prometheus com multiprocessamento.

```RUN mkdir -p /tmp/metrics```
Cria o diretório /tmp/metrics, onde o Prometheus armazenará os dados de métricas.

```CMD ["/app/entrypoint.sh"]```
Define o comando que será executado quando o container for iniciado. Neste caso, ele executa o script entrypoint.sh.

**🧱 Passo 2: Criação do manifesto Kubernetes**

Neste passo, criamos os manifestos YAML para orquestrar o deployment da aplicação Fake Shop e do banco de dados PostgreSQL no cluster Kubernetes.

- O manifesto define 4 recursos principais:
- Deployment do PostgreSQL
- Service interno para o PostgreSQL
- Service externo (LoadBalancer) para a aplicação
- Deployment da aplicação Fake Shop

🧾 Explicação dos componentes:

🗂️ Deployment do PostgreSQL

[1](./print/2025-04-05_14-06.png)

Cria um container com a imagem oficial do PostgreSQL.

Define variáveis de ambiente para configurar o banco de dados (user, password, database).

Expõe a porta 5432, padrão do PostgreSQL.

🔗 Service ClusterIP para PostgreSQL

[1](./print/2025-04-05_14-07.png)

Tipo ClusterIP, ou seja, acessível apenas internamente dentro do cluster.

Expõe a porta 5432.

Usa um selector para apontar para o deployment do PostgreSQL.

🌐 Service LoadBalancer para a Fake Shop
Tipo LoadBalancer, que expõe a aplicação para fora do cluster (ideal em ambientes de cloud).

A porta 80 é usada externamente e mapeada para 5000 (porta usada pela aplicação Flask).

Define nodePort: 30001 para permitir acesso direto se necessário.

🛍️ Deployment da aplicação Fake Shop
[1](./print/2025-04-05_14-22.png)


Usa uma imagem customizada hospedada no Docker Hub.

Expõe a porta 5000.

Define variáveis de ambiente para conectar ao banco de dados PostgreSQL.

Usa imagePullPolicy: Always para sempre baixar a versão mais recente da imagem.

**⚙️ Passo 3: Pipeline CI/CD (GitHub Actions)**

Neste projeto, foi implementada uma pipeline de CI/CD usando GitHub Actions com o objetivo de automatizar o build da imagem Docker, o push para o Docker Hub e o deploy da aplicação no Kubernetes.

🔁 Quando a pipeline é executada?

Push na branch main
ou
Manual via workflow_dispatch

🧪 Pipeline: Estrutura e Explicação
A pipeline está dividida em dois jobs principais:

[1](./print/2025-04-05_15-32.png)

🚧 Job 1: docker – Build e push da imagem

Explicação das etapas:

Checkout: Clona o repositório para o ambiente da ação.

Login no Docker Hub: Autentica no Docker Hub usando as credenciais armazenadas em vars e secrets.

Setup QEMU: Configura o QEMU para permitir builds multiplataforma.

Setup Docker Buildx: Prepara o ambiente para builds avançados com o Buildx.

Build e push: Constrói a imagem Docker com o contexto e Dockerfile especificados e a envia para o Docker Hub com duas tags: latest e uma versão baseada no número da execução.

🚀 Job 2: Deploy – Deploy da aplicação no Kubernetes

Explicação das etapas:

Checkout: Clona novamente o repositório.

Configuração do contexto do Kubernetes: Utiliza o kubeconfig armazenado em secrets para se conectar ao cluster.

Deploy no Kubernetes: Aplica os manifestos YAML (localizados em ./K8s/deployment.yaml) e atualiza a imagem do deployment com a imagem mais recente.

Instalação do kubectl: Instala a ferramenta kubectl, caso não esteja presente.

Rollout restart: Reinicia o deployment fakeshop para forçar a aplicação da nova imagem.

☁️ Passo 4: Criação do Cluster Kubernetes na Cloud
Neste passo, vamos criar o cluster Kubernetes na DigitalOcean, onde a aplicação será hospedada. A DigitalOcean é uma ótima opção por oferecer um bom custo-benefício e facilidade de uso.

🚀 Criação do Cluster

[1](./print/2025-04-05_14-29.png)
Acesse o Painel da DigitalOcean:
Faça login na sua conta DigitalOcean e acesse a seção de Kubernetes.

Crie um novo cluster:
Siga as instruções na interface para criar um novo cluster Kubernetes. Escolha a região, o tamanho dos nós e as configurações de rede conforme sua necessidade.

Confirme a criação:
Após a configuração, confirme e aguarde a criação do cluster.

🔗 Configurando o Acesso com Kubeconfig

[1](./print/2025-04-05_14-53.png)
Para facilitar a manutenção, é essencial configurar seu terminal para se comunicar com o cluster via kubeconfig. Dessa forma, você poderá visualizar os pods, namespaces, logs e realizar atualizações com facilidade.

Baixe o arquivo kubeconfig:
No painel da DigitalOcean, após a criação do cluster, baixe o arquivo kubeconfig.

Configure sua máquina local:
Salve o arquivo em um local seguro (por exemplo, ~/.kube/config) e exporte a variável de ambiente, se necessário:

**🔥 Conclusão 🔥**

Neste projeto, implementamos uma solução completa para o deploy de uma aplicação no Kubernetes, integrando diversas tecnologias e práticas modernas de DevOps. Resumindo:

- Análise e criação do Dockerfile:
Aprendemos como construir e revisar um Dockerfile para garantir que a aplicação seja empacotada corretamente.

- Definição dos manifestos Kubernetes:
Configuramos os recursos necessários (Deployments e Services) para orquestrar tanto o banco de dados PostgreSQL quanto a aplicação Fake Shop, garantindo comunicação interna e acesso externo.

- Automatização com GitHub Actions:
Estabelecemos uma pipeline CI/CD que automatiza o build da imagem Docker, o push para o Docker Hub e o deploy no cluster Kubernetes, facilitando a entrega contínua da aplicação.

- Criação do Cluster na Cloud:
Utilizamos a DigitalOcean para hospedar o cluster Kubernetes, destacando a importância de configurar o kubeconfig para facilitar a manutenção e monitoramento do ambiente.

- Essa abordagem integrada não só melhora a eficiência do processo de deploy, como também oferece maior segurança e facilidade para futuras manutenções e atualizações. O projeto demonstra como unir Docker, Kubernetes e CI/CD para criar um ambiente de produção moderno e escalável.

- Com tudo isso, obtivemos uma aplicação escalável e resiliente, e nossa pipeline possibilita a troca de versões da aplicação sem downtime.

[1](./print/Gravação%20de%20tela%20de%2005-04-2025%2016_44_51.gif)

⌨️ com ❤️ por [Elias Assunção](https://github.com/Hooligam) 🔥

