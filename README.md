
# Documentação do Projeto: Implantação de Cluster EKS na AWS com Acesso via EC2 e Kubectl

## Índice

- [Introdução](#introdução)
- [Pré-requisitos](#pré-requisitos)
- [Configuração do Ambiente](#configuração-do-ambiente)
  - [1. Configuração da AWS CLI](#1-configuração-da-aws-cli)
  - [2. Configuração do Terraform](#2-configuração-do-terraform)
- [Provisionamento da Infraestrutura](#provisionamento-da-infraestrutura)
  - [1. Configuração do VPC](#1-configuração-do-vpc)
  - [2. Criação do Cluster EKS](#2-criação-do-cluster-eks)
  - [3. Configuração do Node Group](#3-configuração-do-node-group)
- [Configuração do Kubectl](#configuração-do-kubectl)

## Introdução

Este documento fornece um guia passo a passo para a implantação de um cluster Kubernetes gerenciado pelo Amazon Elastic Kubernetes Service (EKS) na AWS. Além disso, aborda a configuração do kubectl para gerenciar o cluster e a criação de uma instância EC2 que terá acesso ao cluster EKS.

## Pré-requisitos

Antes de iniciar, certifique-se de que você possui os seguintes pré-requisitos:

- **Conta AWS Ativa**: Uma conta AWS com permissões adequadas para criar recursos como VPCs, EC2, EKS, IAM Roles, etc.
- **AWS CLI Configurada**: A AWS Command Line Interface deve estar instalada e configurada com as credenciais apropriadas.
- **Terraform Instalado**: Terraform instalado na versão compatível com os provedores que serão utilizados.
- **Kubectl Instalado**: Ferramenta de linha de comando kubectl instalada para gerenciar recursos Kubernetes.
- **Conhecimento Básico de Kubernetes e AWS**: Entendimento básico de como o Kubernetes e a AWS funcionam.

## Configuração do Ambiente

### 1. Configuração da AWS CLI

**Passo 1:** Instale a AWS CLI seguindo as instruções oficiais: [AWS CLI Installation](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html).

**Passo 2:** Configure a AWS CLI com suas credenciais:

```bash
aws configure
```

Insira as seguintes informações quando solicitado:

- **AWS Access Key ID**
- **AWS Secret Access Key**
- **Default region name** (ex: us-east-1)
- **Default output format** (recomenda-se json)

**Passo 3:** Verifique se a configuração está correta executando:

```bash
aws sts get-caller-identity
```

### 2. Configuração do Terraform

**Passo 1:** Instale o Terraform seguindo as instruções oficiais: [Terraform Installation](https://learn.hashicorp.com/tutorials/terraform/install-cli).

**Passo 2:** Verifique a instalação executando:

```bash
terraform version
```

**Passo 3:** Crie um diretório para o projeto e navegue até ele:

```bash
mkdir aws-eks-project
cd aws-eks-project
```

**Passo 4:** Inicialize um arquivo `main.tf` que conterá as configurações do Terraform.

## Provisionamento da Infraestrutura

### 1. Configuração do VPC

Criaremos uma VPC personalizada que será usada pelo cluster EKS.

**Passo 1:** No arquivo `main.tf`, adicione o seguinte código para configurar o provedor AWS:

```hcl
provider "aws" {
  region = "us-east-1"
}
```

**Passo 2:** Adicione o recurso para criar uma VPC:

```hcl
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "eks-vpc"
  }
}
```

**Passo 3:** Crie subnets públicas e privadas:

```hcl
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "eks-public-subnet"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "eks-private-subnet"
  }
}
```

**Passo 4:** Configure o Internet Gateway e a tabela de rotas para a subnet pública:

```hcl
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "eks-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "eks-public-rt"
  }
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public_subnet" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
```

**Passo 5:** Configure o NAT Gateway e a tabela de rotas para a subnet privada:

```hcl
resource "aws_eip" "nat" {
  vpc = true
  tags = {
    Name = "eks-nat-eip"
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id
  tags = {
    Name = "eks-nat-gateway"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "eks-private-rt"
  }
}

resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main.id
}

resource "aws_route_table_association" "private_subnet" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}
```

### 2. Criação do Cluster EKS

Usaremos o módulo oficial do EKS para criar o cluster.

**Passo 1:** Adicione o módulo EKS ao seu `main.tf`:

```hcl
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "18.29.0"

  cluster_name    = "my-eks-cluster"
  cluster_version = "1.21"
  vpc_id          = aws_vpc.main.id
  subnet_ids      = [aws_subnet.public.id, aws_subnet.private.id]

  node_groups = {
    default = {
      desired_capacity = 2
      max_capacity     = 3
      min_capacity     = 1

      instance_types = ["t3.medium"]

      subnets = [aws_subnet.private.id]

      tags = {
        Name = "eks-node-group"
      }
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
```

**Passo 2:** Inicialize o Terraform e aplique as configurações:

```bash
terraform init
terraform apply
```

Confirme a execução quando solicitado. O processo pode levar alguns minutos.

### 3. Configuração do Node Group

O módulo EKS já configura um Node Group conforme especificado. Certifique-se de que os nós estejam ativos após a criação do cluster.

**Passo 1:** Verifique o status dos nós:

Após a aplicação do Terraform, execute:

```bash
aws eks --region us-east-1 update-kubeconfig --name my-eks-cluster
kubectl get nodes
```

Você deve ver uma lista de nós disponíveis no cluster.

## Configuração do Kubectl

### 1. Instalação do Kubectl

**Passo 1:** Baixe a versão mais recente do kubectl:

```bash
curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.21.14/2022-10-31/bin/linux/amd64/kubectl
```

**Passo 2:** Torne o binário executável:

```bash
chmod +x ./kubectl
```

**Passo 3:** Mova o binário para um diretório no PATH:

```bash
sudo mv ./kubectl /usr/local/bin/
```

**Passo 4:** Verifique a instalação:

```bash
kubectl version --short --client
```

### 2. Configuração do Kubeconfig

**Passo 1:** Configure o kubeconfig para acessar o cluster EKS:

```bash
aws eks --region us-east-1 update-kubeconfig --name my-eks-cluster
```

**Passo 2:** Verifique a conexão:

```bash
kubectl get svc
```

Você deve ver a lista de serviços no cluster.

## Acesso ao Cluster via EC2

### 1. Criação da Instância EC2

**Passo 1:** Adicione o seguinte recurso ao `main.tf` para criar uma instância EC2:

```hcl
resource "aws_instance" "eks_access" {
  ami                         = "ami-0c94855ba95c71c99" # Amazon Linux 2 AMI
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public.id
  associate_public_ip_address = true
  key_name                    = "my-key-pair"

  tags = {
    Name = "eks-access-instance"
  }
}
```

**Passo 2:** Atualize o Terraform:

```bash
terraform apply
```

**Passo 3:** Certifique-se de que a instância EC2 tenha um Security Group que permita acesso SSH (porta 22) e saída na porta 443.

### 2. Instalação e Configuração do Kubectl na EC2

**Passo 1:** Conecte-se à instância EC2 via SSH:

```bash
ssh -i "my-key-pair.pem" ec2-user@<EC2_PUBLIC_IP>
```

**Passo 2:** Instale o kubectl na instância EC2:

```bash
curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.21.14/2022-10-31/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/
```

**Passo 3:** Configure o kubeconfig na instância EC2:

```bash
aws eks --region us-east-1 update-kubeconfig --name my-eks-cluster
```

**Passo 4:** Verifique a conexão:

```bash
kubectl get nodes
```

Se configurado corretamente, você verá a lista de nós do cluster.

## Implantação de Aplicações no Cluster

### 1. Implantação de um Aplicativo de Exemplo

**Passo 1:** Crie um arquivo de implantação `nginx-deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: nginx:1.21.6
          ports:
            - containerPort: 80
```

**Passo 2:** Aplique o manifesto:

```bash
kubectl apply -f nginx-deployment.yaml
```

**Passo 3:** Verifique os pods implantados:

```bash
kubectl get pods
```

**Passo 4:** Exponha o deployment como um serviço:

```bash
kubectl expose deployment nginx-deployment --type=LoadBalancer --name=nginx-service
```

**Passo 5:** Obtenha o endereço do serviço:

```bash
kubectl get svc nginx-service
```

Acesse o endereço externo fornecido para ver a página padrão do Nginx.

## Solução de Problemas Comuns

### 1. Erro de Timeout ao Acessar o Cluster

**Solução:**
- Verifique as configurações de rede, incluindo as tabelas de rotas e grupos de segurança.
- Certifique-se de que a instância EC2 e o cluster EKS estejam na mesma VPC ou que haja peering entre as VPCs.
- Verifique se as permissões IAM estão corretamente configuradas.

### 2. Erro de Autenticação ao Usar o Kubectl

**Solução:**
- Verifique se o kubeconfig está configurado corretamente e aponta para o cluster correto.
- Certifique-se de que as credenciais AWS usadas têm permissões adequadas.
- Regenerate o token de autenticação usando a AWS CLI.

## Pontos de Melhoria

1. **Ajustes na Rede da VPC**:
   - **Descrição**: Realizar ajustes na configuração da VPC para incluir uma VPN, o que melhoraria a conectividade e segurança na comunicação com o cluster EKS.
   - **Benefícios**: Garantir uma conexão segura e otimizada entre o ambiente local e o cluster EKS na AWS.

2. **Adição de Observabilidade**:
   - **Descrição**: Integrar ferramentas de observabilidade, como Prometheus e AWS CloudWatch, para monitorar e coletar métricas do cluster EKS.
   - **Benefícios**: Fornecer visibilidade em tempo real sobre o desempenho e saúde do cluster, permitindo a detecção proativa de problemas.

3. **Criação de um Plano de Recuperação de Desastres (DRP)**:
   - **Descrição**: Desenvolver e implementar um Plano de Recuperação de Desastres (DRP) que cubra falhas críticas, incluindo a recuperação de dados e restauração de serviços em caso de incidentes graves.
   - **Benefícios**: Garantir a continuidade dos negócios e a resiliência dos serviços em situações de desastre.

4. **Salvar o Estado do Terraform em um Bucket na AWS**:
   - **Descrição**: Configurar o backend do Terraform para salvar o estado em um bucket S3 na AWS, garantindo a persistência e segurança do estado da infraestrutura.
   - **Benefícios**: Permitir que a equipe trabalhe de forma colaborativa, evitando conflitos e perda de dados no estado do Terraform.

## Conclusão

Este documento forneceu um guia detalhado para a configuração e implantação de um cluster EKS na AWS, incluindo a configuração de acesso via kubectl tanto localmente quanto por meio de uma instância EC2. Além disso, abordou a implantação de uma aplicação de exemplo e soluções para problemas comuns que podem ser encontrados durante o processo.

## Referências

- [Amazon EKS Documentation](https://docs.aws.amazon.com/eks/index.html)
- [Terraform AWS EKS Module](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest)
- [Kubectl Installation Guide](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [AWS CLI Installation Guide](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
